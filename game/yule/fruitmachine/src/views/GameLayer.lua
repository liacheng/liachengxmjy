local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.fruitmachine.src"
local cmd = appdf.req(module_pre .. ".models.CMD_Game")
--local cmd = module_pre .. ".models.CMD_Game"

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local scheduler = cc.Director:getInstance():getScheduler()
local QueryDialog = require("app.views.layer.other.QueryDialog")

function GameLayer:getParentNode( )
    return self._scene
end

function GameLayer:getFrame( )
    return self._gameFrame
end

--创建网络消息包
local function create_netdata(keyTable) 
	local len = 0;
	for i=1,#keyTable do
		local keys = keyTable[i];
		local keyType = string.lower(keys["t"]);

		--todo 数组长度计算
		local keyLen = 0;
		if "byte" == keyType or "bool" == keyType then
			keyLen = 1;
		elseif "score" == keyType or "double" == keyType then
			keyLen = 8;
		elseif "word" == keyType or "short" == keyType then
			keyLen = 2;
		elseif "dword" == keyType or "int" == keyType or "float" == keyType then
			keyLen = 4;
		elseif "string" == keyType then
			keyLen = keys["s"];
		elseif "tchar" == keyType then
			keyLen = keys["s"] * 2
		elseif "ptr" == keyType then
			keyLen = keys["s"]
		else
			--print("error keytype ==> ", keyType);
		end

		local multi=1
		local lenTable=keys["l"]
		if lenTable then
			dbg_assert("string" ~= keyType and "tchar" ~= keyType and "ptr" ~= keyType)
			for i=1,#lenTable do
				multi=multi*lenTable[i]
			end
		end

		len = len + keyLen*multi
	end

	return CCmd_Data:create(len);
end

function GameLayer:ctor( frameEngine,scene )
    ExternalFun.registerNodeEvent(self)
    self.m_bLeaveGame = false
    GameLayer.super.ctor(self,frameEngine,scene)
    self._cbPaoHuoCheCount = 0
    self.messageBgPosUp   = cc.p(-30, appdf.HEIGHT / 2 + 120)
    self.messageBgPosMid  = cc.p(20, appdf.HEIGHT / 2 + 120)
    self.messageBgPosDown = cc.p(70, appdf.HEIGHT / 2 + 120)

    self.m_pIconMessageBg:setRotation(-90)
    self.m_pIconMessageBg:setPosition(self.messageBgPosDown)
    self.m_pIconTrumpet:setPosition(13.5, self.m_pIconTrumpet:getPositionY())
    local bgSize = self.m_pIconMessageBg:getContentSize()
    self.m_pBtnMessage:setContentSize(cc.size(bgSize.width*0.9, bgSize.height*1.5))
    --self:getFrame():SetDelaytime(5*60000) --5分钟
    --self:addAnimationEvent()  --监听加载完动画的事件
end

function GameLayer:OnInitGameEngine()
    GameLayer.super.OnInitGameEngine(self)
end

function GameLayer:ResetAction( )
   
end

function GameLayer:resetData()
   
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()
   
end

function GameLayer:onExit()
    self:KillGameClock()
    self:dismissPopWait()
	GameLayer.super.onExit(self)
end

--退出房间
function GameLayer:onExitRoom()
    print("退出房间")
    self:getFrame():onCloseSocket()
    self:stopAllActions()
    self:KillGameClock()
    self._scene:onKeyBack()
end

--退出桌子
function GameLayer:onExitTable()
    print("退出桌子")
    if self.m_querydialog then
        return
    end
    self:KillGameClock()
    self:showPopWait()
    local MeItem = self:GetMeUserItem()
    if MeItem and MeItem.cbUserStatus > yl.US_FREE then
        self:runAction(cc.Sequence:create(          
            cc.CallFunc:create(
                function ()   
                    self._gameFrame:StandUp(1)
                end
                ),
			cc.DelayTime:create(5),
            cc.CallFunc:create(
                function ()
                    --强制离开游戏(针对长时间收不到服务器消息的情况)
                    print("delay leave")
                    self:onExitRoom()
                end
                )
            )
        )
        return
    end
   self:onExitRoom()
end

--创建场景
function GameLayer:CreateView()
     self._gameView = GameViewLayer:create(self)
     self:addChild(self._gameView,0,2001)
     return self._gameView
end

--获取游戏KIND_ID,用于设置搜索路径
function GameLayer:getGameKind()
    return cmd.KIND_ID
end

local ithMsg=0
function GameLayer:onEventGameMessage(sub,dataBuffer)
	ithMsg=ithMsg+1
	print("-----------------------------------------------------------------------------ithMsg: ",ithMsg)

	if sub==cmd.SUB_S_GAME_START then	            --游戏开始
		return self:OnSubGameStart(dataBuffer)
	elseif sub==cmd.SUB_S_BIG_SMALL then            --比大小
		return self:OnSubBigSmall(dataBuffer)
	elseif sub==cmd.SUB_S_GAME_END then           --游戏结束
		return self:OnSubGameEnd(dataBuffer)
    end
end

-- 猜大小
function GameLayer:OnSubBigSmall(dataBuffer)
    print("-----OnSubBigSmall-----")
    local pBigSmall = ExternalFun.read_netdata(cmd.CMD_S_BigSmall, dataBuffer)
    self._gameView:OverBigSmall(pBigSmall.cbBigSmall)
	if (pBigSmall.lUserWinScore <= 0) then
        pBigSmall.lUserWinScore = 0
    end

	if pBigSmall.lUserWinScore > 0 then
        ExternalFun.playSoundEffect("fruitmachine_randombetwin.mp3")
	else
		ExternalFun.playSoundEffect("fruitmachine_fail.mp3")
    end

    --刷新分数
	self._gameView:refreshGameScore(pBigSmall.lUserScore-pBigSmall.lUserWinScore, pBigSmall.lUserWinScore)
end

-- 游戏结束，计算输赢
function GameLayer:OnSubGameStart(dataBuffer)
	local pGameStart = ExternalFun.read_netdata(cmd.CMD_S_GameStart, dataBuffer)

	self._gameView:SetGameStatus(cmd.GAME_STATUS_FREE)
    if (pGameStart.lUserWinScore <= 0) then
        pGameStart.lUserWinScore = 0
    end
    self.lBigSmallScore = pGameStart.lUserWinScore 
    --刷新彩金
	self._gameView:RefreshCaiJin(pGameStart.lCaiJin)
	
	--刷新分数
	self._gameView:refreshGameScore(pGameStart.lUserScore-pGameStart.lUserWinScore, pGameStart.lUserWinScore)
	self._gameView:autoStart()
	--self._gameView:enableAllBtns(false) 
	--self._gameView:GameOver(pGameEnd.cbTableCardArray[1], pGameEnd.lUserScore, self.m_nCumulativeScore,pGameEnd.cbShaYuAddMulti);
end

function GameLayer:OnSubGameEnd(dataBuffer)
    local pGameEnd = ExternalFun.read_netdata(cmd.CMD_S_GameEnd, dataBuffer)

    self._gameView:SetGameStatus(cmd.GAME_STATUS_END)
    --保存数据
    self._cbGoodLuckType = pGameEnd.cbGoodLuckType
    self._cbPaoHuoCheCount = pGameEnd.cbPaoHuoCheCount
    self._cbPaoHuoCheArea = {0,0,0,0,0,0}
    for i=1, self._cbPaoHuoCheCount do
        self._cbPaoHuoCheArea[i] = pGameEnd.cbPaoHuoCheArea[1][i]
    end 

    self._gameView:RefreshPlaceJetton(true, pGameEnd.dwChipRate, pGameEnd.lUserAreaScore)
    self._gameView:Run(pGameEnd.cbWinArea, pGameEnd.cbGoodLuckType, pGameEnd.cbPaoHuoCheCount, pGameEnd.cbPaoHuoCheArea)

    --刷新彩金和分数
    self._gameView:RefreshCaiJin(pGameEnd.lCaiJin)
    --self._gameView:refreshGameScore(pGameEnd.lUserScore,0)
    
    --保存玩家成绩,播放玩动画后再刷新
    self.lUserScore = pGameEnd.lUserScore
    self.lUserWinScore = pGameEnd.lUserWinScore
    --停止中LUCK的声音
    if self.hitsound~=nil then
            AudioEngine.stopEffect(self.hitsound)
    end

--    --防止锁定解锁
--    local function waitOperation()
--            if self._gameView.GameStatus == cmd.GAME_STATUS_END then
--                self.RunOver()
--            end
--			if nil ~= self._waitOperation then
--				scheduler:unscheduleScriptEntry(self._waitOperation)
--				self._waitOperation = nil
--			end
--	end

--    if self._waitOperation == nil then
--        self._waitOperation = scheduler:scheduleScriptFunc(waitOperation, 7.0, false)
--    end
end

function GameLayer:OnSubGameFree(dataBuffer)
end

--玩家加减倍
function GameLayer:LeftOrRight(cbLeftRight)
    --构建网络数据包
    --[[local cmddata = create_netdata(cmd.CMD_C_LeftRight)
    cmddata:pushbyte(cbLeftRight)
    local ret=self:SendData(cmd.SUB_C_LEFT_RIGHT,cmddata) 
    print("----------------self:SendData--ret: ",ret)--]]
    if nil == self.lUserWinScore or 0 == self.lUserWinScore or nil == self._ChipRate or 0 == self._ChipRate then
        return
    end

    self._gameView:LeftOrRight(cbLeftRight, self.lUserWinScore, self._ChipRate)
end

--猜大小
function GameLayer:BigSmall(cbBigSmall, lScore)
    --构建网络数据包
    local cmddata = create_netdata(cmd.CMD_C_BigSmall)
    cmddata:pushbool(cbBigSmall)
    --cmddata:pushbyte(cbBigSmall)
    cmddata:pushint(lScore)

    local ret=self:SendData(cmd.SUB_C_BIG_SMALL,cmddata)
    print("----------------self:SendData--ret: ",ret)
end

--跑灯结束
function GameLayer:RunOver()  
    --构建网络数据包
    --[[local cmddata = create_netdata(cmd.CMD_C_RunOver)
    cmddata:pushbyte(0)
    local ret=self:SendData(cmd.SUB_C_RUN_OVER,cmddata) 
    print("----------------self:SendData--ret: ",ret)--]]

    --播放中LUCK声音
    local function operation()
          if self._cbPaoHuoCheCount >= 1 then
             local luck_key = self._cbPaoHuoCheArea[self._cbPaoHuoCheCount]
             if (luck_key==5 or luck_key==6 or luck_key==11 or luck_key==17 or luck_key==23) then
                ExternalFun.playSoundEffect("fruitmachine_Y101.mp3")
             elseif (luck_key==1 or luck_key==12 or luck_key==13) then
                ExternalFun.playSoundEffect("fruitmachine_Y102.mp3")
             elseif (luck_key==7 or luck_key==18 or luck_key==19) then
                ExternalFun.playSoundEffect("fruitmachine_Y103.mp3")
             elseif (luck_key==2 or luck_key==14 or luck_key==24) then
                ExternalFun.playSoundEffect("fruitmachine_Y104.mp3") 
             elseif (luck_key==8 or luck_key==9) then
                ExternalFun.playSoundEffect("fruitmachine_Y105.mp3")
             elseif (luck_key==20 or luck_key==21) then
                ExternalFun.playSoundEffect("fruitmachine_Y106.mp3") 
             elseif (luck_key==15 or luck_key==16) then
                ExternalFun.playSoundEffect("fruitmachine_Y107.mp3") 
             elseif (luck_key==3 or luck_key==4) then
                ExternalFun.playSoundEffect("fruitmachine_Y108.mp3") 
             elseif (luck_key==10 or luck_key==22) then 
             end

            self._cbPaoHuoCheCount = self._cbPaoHuoCheCount - 1
        else
            if self.hitsound ~= nil then
                AudioEngine.stopEffect(self.hitsound)
                self.hitsound = nil
            end

	        local strSound = string.format("fruitmachine_C0%d.mp3",math.random(1,4))
	        self.hitsound = ExternalFun.playSoundEffect(strSound)
            self.isPlayerSound = true
			if nil ~= self.m_schedule then
				scheduler:unscheduleScriptEntry(self.m_schedule)
				self.m_schedule = nil
			end
        end 
	end

    if self._cbGoodLuckType ~= nil and self._cbGoodLuckType ~= 0 then
	    if self.m_schedule == nil then
		    self.m_schedule = scheduler:scheduleScriptFunc(operation, 2.0, false)
	    end
    end

    --播放玩动画刷新玩家成绩
    if nil ~= self.lUserScore and nil ~= self.lUserWinScore then 
        self._gameView:SetGameStatus(cmd.GAME_STATUS_FREE)
        self._gameView:refreshGameScore(self.lUserScore-self.lUserWinScore, self.lUserWinScore)
        self._gameView:autoStart()
    end
end

--加注按钮消息
function GameLayer:OnPlaceJetton(apple,orange,mango,bell,watermelon,star,seven,bar) 
    --构建网络数据包
	 local cmddata = create_netdata(cmd.CMD_C_PlaceJetton)

     local ChipRate = 1
     if self._ChipRate ~= nil then
        ChipRate = self._ChipRate
    else 
        ChipRate = 1000
     end

	cmddata:pushint(apple*ChipRate)
	cmddata:pushint(orange*ChipRate)
    cmddata:pushint(mango*ChipRate)
    cmddata:pushint(bell*ChipRate)
    cmddata:pushint(watermelon*ChipRate)
    cmddata:pushint(star*ChipRate)
    cmddata:pushint(seven*ChipRate)
    cmddata:pushint(bar*ChipRate)

	local ret=self:SendData(cmd.SUB_C_GAME_START,cmddata) 

    print("----------------ret: ",ret)
    self._gameView:SetGameStatus(cmd.GAME_STATUS_PLAY)
end

function GameLayer:onSystemMessage(wType, szString)
    local runScene = cc.Director:getInstance():getRunningScene()
    if wType == 501 or wType == 515 then
        local msg = szString or "你的游戏币不足，无法继续游戏"
        local query = QueryDialog:create(msg, function(ok)
--                if ok == true then
--                    self:onExitTable()
--                end
            end):setCanTouchOutside(false)
                :setLocalZOrder(9999)
        local x = 0
        if yl.WIDTH > yl.DESIGN_WIDTH then 
            x = (yl.WIDTH - yl.DESIGN_WIDTH)/2
        end
        query:setPositionX(query:getPositionX()+x)
        query:addTo(runScene)
    end
end

function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
    print("-----onEventGameScene-----")
	if cbGameStatus==cmd.GAME_STATUS_FREE then
		local pStatusFree = ExternalFun.read_netdata(cmd.CMD_S_StatusFree, dataBuffer)
        print("-----cmd.GAME_STATUS_FREE-----")
        --self:SendUserReady()
        self._gameView:SetGameStatus(cmd.GS_GAME_FREE)
        self._gameView:refreshGameScore(pStatusFree.lUserScore,0)
        self._gameView:RefreshCaiJin(pStatusFree.lCaiJin)

        --保存筹码比例
        self._ChipRate = pStatusFree.dwChipRate
        self._gameView:ShowChipRate(self._ChipRate)
    --[[elseif cbGameStatus==cmd.GAME_STATUS_PLAY then --服务端不会有这个状态(开牌时设置该状态后马上重设为cmd.GAME_STATUS_FREE)
        local pStatusPlay = ExternalFun.read_netdata(cmd.CMD_S_StatusPlay, dataBuffer)
        print("-----cmd.GAME_STATUS_PLAY-----")
        --self:SendUserReady()
        self._gameView:SetGameStatus(cmd.CMD_S_StatusPlay)
        self._gameView:refreshGameScore(pStatusPlay.lUserScore,0)
        self._gameView:RefreshCaiJin(pStatusPlay.lCaiJin)

        --保存筹码比例
        self._ChipRate = pStatusPlay.dwChipRate
        self._gameView:ShowChipRate(self._ChipRate)

        --下注信息
        self._gameView.num_apple:setString(tostring(pStatusPlay.lUserAreaScore[1][8]))
        self._gameView.num_orange:setString(tostring(pStatusPlay.lUserAreaScore[1][7]))
        self._gameView.num_mango:setString(tostring(pStatusPlay.lUserAreaScore[1][6]))
        self._gameView.num_bing:setString(tostring(pStatusPlay.lUserAreaScore[1][5]))
        self._gameView.num_watermelon:setString(tostring(pStatusPlay.lUserAreaScore[1][4]))
        self._gameView.num_star:setString(tostring(pStatusPlay.lUserAreaScore[1][3]))
        self._gameView.num_seven:setString(tostring(pStatusPlay.lUserAreaScore[1][2]))
        self._gameView.num_bar:setString(tostring(pStatusPlay.lUserAreaScore[1][1]))

        --LUCK赠送的区域也要加1
	    for i=1, pStatusPlay.cbPaoHuoCheCount do
		    pStatusPlay.cbPaoHuoCheArea[1][i] = pStatusPlay.cbPaoHuoCheArea[1][i] + 1
	    end

        --保存数据
        self._cbGoodLuckType = pStatusPlay.cbGoodLuckType
	    self._cbPaoHuoCheCount = pStatusPlay.cbPaoHuoCheCount
	    self._cbPaoHuoCheArea = {0,0,0,0,0,0}
        for i=1, self._cbPaoHuoCheCount do
            self._cbPaoHuoCheArea[i] = pStatusPlay.cbPaoHuoCheArea[1][i]
        end 

	    self._gameView:Run(pStatusPlay.cbWinArea+1, pStatusPlay.cbGoodLuckType, pStatusPlay.cbPaoHuoCheCount, pStatusPlay.cbPaoHuoCheArea)

        --停止中LUCK的声音
        if self.hitsound~=nil then
                AudioEngine.stopEffect(self.hitsound)
        end--]]
    end

end
return GameLayer