local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.animalbattle.src"
local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd = appdf.req(module_pre .. ".models.CMD_Game")
local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local GameServer_CMD = appdf.req(appdf.HEADER_SRC.."CMD_GameServer")
local GameFrame = appdf.req(appdf.GAME_SRC.."yule.animalbattle.src.models.GameFrame")
local g_var = ExternalFun.req_var
local QueryDialog = require("app.views.layer.other.QueryDialog")

--时间标识
local IDI_FREE			=		99									--空闲时间
local IDI_PLACE_JETTON	=		100									--下注时间
local IDI_DISPATCH_CARD	=		301									--发牌时间
local IDI_OPEN_CARD		=		302								    --发牌时间
local IDI_ANDROID_BET	=		1000	
local function assignArray(destTable,...) --只改变table的array部分
	local var={...}
	if var[1]==nil then
		for i=1,#destTable do
			destTable[i]=nil
		end
	elseif type(var[1])=="table" then
		for i=1,#var[1] do
			destTable[i]=var[1][i]
		end
		destTable[#var[1]+1]=nil
	elseif type(var[1])=="number" then
		for i=1,var[1] do
			destTable[i]=var[2]
		end
		destTable[var[1]+1]=nil
	end
end

--onreset

function GameLayer:ctor( frameEngine,scene ) 
    self._dataModle = GameFrame:create() 
    GameLayer.super.ctor(self, frameEngine, scene)
    self:initData()
    self._roomRule = self._gameFrame._dwServerRule
    --self.originalFPS=cc.Director:getInstance():getAnimationInterval()
    --cc.Director:getInstance():setAnimationInterval(1/30)
    
    self.messageBgPosUp   = cc.p(290, 770)
    self.messageBgPosMid  = cc.p(290, 720)
    self.messageBgPosDown = cc.p(290, 670)

    self.m_pIconMessageBg:setPosition(self.messageBgPosDown)
    self.m_pIconMessageBg:setContentSize(cc.size(340, 34))
    local bgSize = self.m_pIconMessageBg:getContentSize()
    self.m_pBtnMessage:setContentSize(cc.size(bgSize.width*0.9, bgSize.height*1.5))
    self.m_pBtnMessage:setPosition(bgSize.width/2, bgSize.height/2)
    self.m_pStencil:setTextureRect(cc.rect(0, 0, 340-40, 34))
    self.m_pClipNode:setPosition(cc.p(30, 17))
    self.m_pIconTrumpet:setPosition(13.5, bgSize.height/2)
end

--获取gamekind
function GameLayer:getGameKind()
    return cmd.KIND_ID
end

function GameLayer:initData()
	self.tabMyBets={}
	self.tabTotalBets={}
	self.m_nCumulativeScore=0 --总得分
	self.m_nAllPlayBet=0  --此次下注总和
	self.m_nCurrentNote=nil
     --区域限制
    self.m_lAreaLimitScore = 0

	--self.bAllowOpeningAni=true
end

function GameLayer:CreateView()
	local this=self
    return GameViewLayer:create(this)
        :addTo(this)
end

function GameLayer:clearBets()
	self.m_nAllPlayBet=0
	for i=1,cmd.AREA_COUNT do
		self.tabMyBets[i]=0
		self.tabTotalBets[i]=0
	end
	self._gameView:updateMyBets(self.tabMyBets)    
	self._gameView:updateTotalBets(self.tabTotalBets)
end

function GameLayer:SetGameStatus(status)
	self.m_cbGameStatus=status
end

function GameLayer:onExit()
    GameLayer.super.onExit(self)
end

--退出桌子
function GameLayer:onExitTable()
	local MeItem = self:GetMeUserItem()
	if MeItem and MeItem.cbUserStatus > yl.US_FREE then
		self:showPopWait()
		self:runAction(cc.Sequence:create(
			cc.CallFunc:create(
				function ()
					self._gameFrame:StandUp(1)
				end
				),
			cc.DelayTime:create(3),
			cc.CallFunc:create(
				function ()
					self:onExitRoom()
				end
				)
			)
		)
		return
	end
	self:onExitRoom()
end

--离开房间
function GameLayer:onExitRoom()
	self._gameFrame:onCloseSocket()
	self:KillGameClock()
	--cc.Director:getInstance():setAnimationInterval(self.originalFPS)
	self._scene:onKeyBack()
end


local ithMsg=0
function GameLayer:onEventGameMessage(sub,dataBuffer)
	ithMsg=ithMsg+1
	print("ithMsg: ",ithMsg)
	if sub== cmd.SUB_S_GAME_FREE then	--空闲时间
		return self:OnSubGameFree(dataBuffer)
	elseif sub==cmd.SUB_S_GAME_START then	--游戏开始
		return self:OnSubGameStart(dataBuffer)
	elseif sub==cmd.SUB_S_PLACE_JETTON then	--游戏结束
		return self:OnSubPlaceJetton(dataBuffer)
    elseif sub == cmd.SUB_S_APPLY_BANKER then
		return self:onSubApplyBanker(dataBuffer);
    elseif sub == cmd.SUB_S_CANCEL_BANKER then
        return self:onSubCancelBanker(dataBuffer);
    elseif sub == cmd.SUB_S_CHANGE_BANKER then 
		return self:onSubChangeBanker(dataBuffer);
	elseif sub==cmd.SUB_S_GAME_END then	--玩家下注
		return self:OnSubGameEnd(dataBuffer)
    elseif sub == cmd.SUB_S_SEND_RECORD then
        self:onSubGameRecord(dataBuffer)
	elseif sub==cmd.SUB_S_PLACE_JETTON_FAIL then--下注失败
		return self:OnSubPlaceJettonFail(dataBuffer)
	elseif sub==cmd.SUB_S_CEAN_JETTON then	--清除下注
		return self:OnSubClearJetton(dataBuffer)
	elseif sub==cmd.SUB_S_CONTINU_JETTON then	--更新下注
		return self:OnSubContinueJetton(dataBuffer)
	end
end


function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
	if cbGameStatus==cmd.GAME_STATUS_FREE then
		local pStatusFree = ExternalFun.read_netdata(cmd.CMD_S_StatusFree, dataBuffer)

		self.m_nCurrentNote=0
		--设置状态
		self:SetGameStatus(cmd.GAME_STATUS_FREE)
		self._gameView:SetGameStatus(cmd.GAME_STATUS_FREE)
		self._gameView:updateAsset(self:GetMeScore())
		self._gameView:updateCurrentScore(0)
		self._gameView:enable_NoteNum_Clear_ContinueBtn(false)

		self:SetGameClock(self:GetMeChairID(),IDI_FREE,pStatusFree.cbTimeLeave)
        print("onEventGameScene : GAME_STATUS_FREE"..pStatusFree.wBankerUser)
        self._gameView:setBankerInfo(pStatusFree.wBankerUser,pStatusFree.lBankerScore,pStatusFree.cbBankerTime)
		self._gameView:setSharkComeTime(pStatusFree.dwGoldSharkTime,pStatusFree.dwSharkTime)	
		self._gameView:updateStorage( pStatusFree.lBonus) --lStorageStart全部改成lBonus
	    
        --刷新庄家信息
        self.m_bEnableSystemBanker = pStatusFree.bEnableSysBanker
        self._gameView:onChangeBanker(pStatusFree.wBankerUser, pStatusFree.lBankerScore,self.m_bEnableSystemBanker);
        --从申请列表移除
        self._dataModle:removeApplyUser(pStatusFree.wBankerUser)
		--玩家信息
		self.m_lMeMaxScore=pStatusFree.lUserMaxScore

		self.m_lAreaLimitScore=pStatusFree.lAreaLimitScore

        --申请按钮状态
        self._gameView.m_enApplyState = self._gameView._apply_state.kCancelState
        self._gameView:setBtnBankerType(self._gameView._apply_state.kCancelState)

	elseif cbGameStatus==cmd.GS_PLACE_JETTON or cbGameStatus==cmd.GS_GAME_END then
		local pStatusPlay = ExternalFun.read_netdata(cmd.CMD_S_StatusPlay, dataBuffer)

		self:SetGameStatus(cbGameStatus)
		if cbGameStatus==cmd.GS_PLACE_JETTON then
			self._gameView:SetGameStatus(cmd.GS_PLACE_JETTON)
			self._gameView:enableAllBtns(true)
			self._gameView:updateCurrentScore(0)
		elseif cbGameStatus==cmd.GS_GAME_END then
			self.m_nCurrentNote=0
			self._gameView:SetGameStatus(cmd.GS_GAME_END)
			self._gameView:enableAllBtns(false)
		end

		local nTimerID = (pStatusPlay.cbGameStatus==cmd.GS_GAME_END) and IDI_OPEN_CARD or IDI_PLACE_JETTON
		self:SetGameClock(self:GetMeChairID(), nTimerID, pStatusPlay.cbTimeLeave)
		self._gameView:updateAsset(self:GetMeScore()-self.m_nAllPlayBet) 
        for k, v in ipairs(pStatusPlay.lAllJettonScore) do
           self._gameView:updateTotalBets(v) 
        end

        self._gameView:setBankerInfo(pStatusPlay.wBankerUser,pStatusPlay.lBankerScore,pStatusPlay.cbBankerTime)
        self._gameView:setSharkComeTime(pStatusPlay.dwGoldSharkTime,pStatusPlay.dwSharkTime)	
		self._gameView:updateStorage( pStatusPlay.lBonus)

         --刷新庄家信息
        self.m_bEnableSystemBanker = pStatusPlay.bEnableSysBanker
        self._gameView:onChangeBanker(pStatusPlay.wBankerUser, pStatusPlay.lBankerScore, self.m_bEnableSystemBanker);
        --从申请列表移除
        self._dataModle:removeApplyUser(pStatusPlay.wBankerUser)
		--玩家积分
		self.m_lMeMaxScore=pStatusPlay.lUserMaxScore;		
		self.m_lAreaLimitScore=pStatusPlay.lAreaLimitScore;

        --申请按钮状态
        if pStatusPlay.wBankerUser ~= self:GetMeChairID()then
            self._gameView.m_enApplyState = self._gameView._apply_state.kCancelState
            self._gameView:setBtnBankerType(self._gameView._apply_state.kCancelState)
        end
	end
end
 function GameLayer:getBankerStatus()
     return self.m_bEnableSystemBanker
 end

 --记录
 function GameLayer:onSubGameRecord( dataBuffer )
    local recordCount = math.floor(dataBuffer:getlen()/13)
    local conversionAniTb = {7,0,1,2,3,4,5,6,8,9,10,11} 
    local isAddSilverShark = false
    if recordCount >= 1 then
        for i=1,recordCount do
          local record = ExternalFun.read_netdata(cmd.tagServerGameRecord,dataBuffer, ExternalFun.DisableAssert)
          for key, var in pairs(record.bWinMen[1]) do
            if record.bWinMen[1][9] ~= 4 then
                if var == 4 then
                    self._gameView:AddTurnTableRecord(conversionAniTb[key])
                    break;
                end
            else                          --开中银鲨
                if isAddSilverShark == false then
                    isAddSilverShark = true
                    self._gameView:AddTurnTableRecord(conversionAniTb[9])
                end
                
                if var == 4 and key~= 9 then
                    self._gameView:AddTurnTableRecord(conversionAniTb[key])
                    break;
                end 
            end
          end 
        end
        self._gameView:updateShowTurnTableRecord(0)
    end
end

--取消申请
function GameLayer:onSubCancelBanker( dataBuffer )
    print("cancel banker")
    self.cmd_cancelbanker = ExternalFun.read_netdata(cmd.CMD_S_CancelBanker, dataBuffer)

    if self.cmd_cancelbanker.wCancelUser == self.m_wCurrentRobApply then
        self._gameView.m_wCurrentRobApply = yl.INVALID_CHAIR
        self.m_wCurrentRobApply = yl.INVALID_CHAIR
    end
    --从申请列表移除
    self._dataModle:removeApplyUser(self.cmd_cancelbanker.wCancelUser)
    self._gameView:onGetCancelBanker()
end

--切换庄家
function GameLayer:onSubChangeBanker( dataBuffer )
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_ChangeBanker,dataBuffer);

    self.cmd_changebanker = cmd_table;
    self._dataModle:removeApplyUser(cmd_table.wBankerUser)  --从申请列表移除
    self._gameView:onChangeBanker(cmd_table.wBankerUser, cmd_table.lBankerScore, self.m_bEnableSystemBanker)
    self._gameView:showChangeBanker()
    self._gameView:refreshApplyList()   -- 申请列表更新
    -- 这里
end

function GameLayer:OnSubGameFree(dataBuffer)
	local pGameFree = ExternalFun.read_netdata(cmd.CMD_S_GameFree, dataBuffer)

	self.m_nCurrentNote=nil
	self.m_nAllPlayBet=0

	self:SetGameStatus(cmd.GAME_STATUS_FREE)
	self._gameView:SetGameStatus(cmd.GAME_STATUS_FREE)
    --设置时间
	self:SetGameClock(self:GetMeChairID(),IDI_FREE,pGameFree.cbTimeLeave)
	self._gameView:enableBetBtns(true)
	self._gameView:enable_NoteNum_Clear_ContinueBtn(false)

	self._gameView:updateAsset(self:GetMeScore())
	
	self._gameView:updateStorage(pGameFree.lBonus) --彩池数字

	assignArray(self.tabMyBets,cmd.AREA_COUNT-1,0)     --清空个人下注
	assignArray(self.tabTotalBets,cmd.AREA_COUNT-1,0)   --清空总下注
	self._gameView:updateMyBets(self.tabMyBets)    
	self._gameView:updateTotalBets(self.tabTotalBets)
	self._gameView:updateCurrentScore(0)
end

function GameLayer:OnSubGameStart(dataBuffer)
	local pGameStart = ExternalFun.read_netdata(cmd.CMD_S_GameStart, dataBuffer)
	print("pGameStart.cbTimeLeave: ",pGameStart.cbTimeLeave)

     --刷新庄家信息
    self._gameView:onChangeBanker(pGameStart.wBankerUser, pGameStart.lBankerScore, self.m_bEnableSystemBanker);

	--设置状态
	self:SetGameStatus(cmd.GS_PLACE_JETTON)
	self._gameView:SetGameStatus(cmd.GS_PLACE_JETTON)
	self._gameView:enableAllBtns(true) 

	local startIndex=nil
	for i=1,7 do
		local noteNum=math.pow(10,i+1)
        if i==6 then
            noteNum = 5000000
        elseif i == 7 then
            noteNum=math.pow(10,7)
        end
		if (self:GetMeScore()-self.m_nAllPlayBet)/noteNum<1 then
			startIndex=i
			break
		end
	end

    if pGameStart.wBankerUser == self:GetMeChairID() then
        self._gameView:disableNoteNumBtns(1)
	elseif nil~=startIndex then
		self._gameView:disableNoteNumBtns(startIndex)
	end
    
	self._gameView:updateBtnLight()

	self._gameView:updateAsset(self:GetMeScore())
	self._gameView:updateStorage( pGameStart.lBonus ) --更新彩池数字
	self._gameView:updateCurrentScore(0)
	--玩家信息
	self.m_lMeMaxScore=pGameStart.lUserMaxScore;  

	--设置时间
	self:SetGameClock(self:GetMeChairID(),IDI_PLACE_JETTON,pGameStart.cbTimeLeave);

end

function GameLayer:OnSubGameEnd(dataBuffer)
	local pGameEnd = ExternalFun.read_netdata(cmd.CMD_S_GameEnd, dataBuffer)

	self:SetGameStatus(cmd.GS_GAME_END)
	self._gameView:SetGameStatus(cmd.GS_GAME_END)
	self._gameView:removeFirstOpeningAni()
	self.m_nCurrentNote=nil
	self.m_nAllPlayBet=0
	self._gameView:enableAllBtns(false) 
	self.m_GameEndTime = pGameEnd.cbTimeLeave;
	self:SetGameClock(self:GetMeChairID(),IDI_DISPATCH_CARD, pGameEnd.cbTimeLeave)  -- 设置时间
	self.m_nCumulativeScore=self.m_nCumulativeScore+pGameEnd.lUserScore
    self._gameView:setBankerInfo(pGameEnd.wBankerUser,pGameEnd.lBankerScore,pGameEnd.nBankerTime)
	self._gameView:GameOver(pGameEnd,self.m_nCumulativeScore);
end

function GameLayer:getPlayerList()
    return self._gameFrame._UserList
end

--申请上庄
function GameLayer:sendApplyBanker()
	local cmddata = CCmd_Data.create(0)
	self:SendData(cmd.SUB_C_APPLY_BANKER, cmddata)
end

--申请上庄
function GameLayer:onSubApplyBanker(dataBuffer)
	local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_ApplyBanker,dataBuffer)
    self.cmd_applybanker = cmd_table;
    self._dataModle:addApplyUser(cmd_table.wApplyUser,false) 

    self._gameView:onGetApplyBanker()
end

function GameLayer:getUserList(  )
    return self._gameFrame._UserList
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()
    self.m_bOnGame = false
    self._gameView.m_enApplyState = self._gameView._apply_state.kCancelState
    self._dataModle:removeAllUser()
    self._dataModle:initUserList(self:getUserList())
    self._gameView:refreshApplyList()
    self._gameView:refreshUserList()
    self._gameView:refreshApplyBtnState()
    --self._gameView:cleanJettonArea()
end

--取消申请
function GameLayer:sendCancelApply(  )
    local cmddata = CCmd_Data:create(0)
    self:SendData(cmd.SUB_C_CANCEL_BANKER, cmddata)
end

function GameLayer:getDataMgr( )
    return self._dataModle
end

function GameLayer:OnSubPlaceJetton(dataBuffer)  --done
	if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		return
	end

	local pPlaceJetton = ExternalFun.read_netdata(cmd.CMD_S_PlaceJetton, dataBuffer)
	local index=pPlaceJetton.cbJettonArea 
	dbg_assert(pPlaceJetton.lJettonScore)
	self.tabTotalBets[index]=self.tabTotalBets[index] or 0
	self.tabTotalBets[index]=self.tabTotalBets[index]+pPlaceJetton.lJettonScore
	self._gameView:updateTotalBet(index,self.tabTotalBets[index])
    self._gameView:updateTotalBets(self.tabTotalBets)
    local index1 = self:getJettonIndex(pPlaceJetton.lJettonScore)
    self._gameView:runJettonAni(index1,pPlaceJetton.cbJettonArea, pPlaceJetton.wChairID == self:GetMeChairID())

	if pPlaceJetton.wChairID == self:GetMeChairID() then
		self.tabMyBets[index]=self.tabMyBets[index] or 0
		self.tabMyBets[index]=self.tabMyBets[index]+pPlaceJetton.lJettonScore
		self._gameView:updateMyBet(index,self.tabMyBets[index])
		self.m_nAllPlayBet=self.m_nAllPlayBet+self.m_nCurrentNote
		self._gameView:updateAsset(self:GetMeScore()-self.m_nAllPlayBet)
		local startIndex=nil
		for i=1,7 do
			local noteNum=math.pow(10,i+1)
            if i==6 then
                noteNum = 5000000
            elseif i == 7 then
                noteNum=math.pow(10,7)
            end
			if (self:GetMeScore()-self.m_nAllPlayBet)/noteNum<1 then
				startIndex=i
				break
			end
		end

		if nil~=startIndex then
			self._gameView:disableNoteNumBtns(startIndex)
		end
	end
end

--下注失败
function GameLayer:OnSubPlaceJettonFail(dataBuffer) --done
	if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		return
	end
	local pPlaceJettonFail = ExternalFun.read_netdata(cmd.CMD_S_PlaceJettonFail, dataBuffer)
    showToast(cc.Director:getInstance():getRunningScene(),"当前区域可下注额度不足",1)
end

function GameLayer:OnSubContinueJetton(dataBuffer) --done
    if self.m_cbGameStatus ~= cmd.GS_PLACE_JETTON then
		return
	end

	local pLastJetton = ExternalFun.read_netdata(cmd.CMD_S_ContiueJetton, dataBuffer)
	for i = 1, cmd.AREA_COUNT-1 do
		self.tabTotalBets[i]=pLastJetton.lAllJettonScore[1][i+1]
	end
	self._gameView:updateTotalBets(self.tabTotalBets)

--	if self:GetMeChairID() == pLastJetton.wChairID then
        --self.m_nAllPlayBet = 0
        local curBet = 0
        local betIndex = 0

		for i = 1, cmd.AREA_COUNT-1 do
            -- 计算与上次区域投注所相差的值
            curBet = pLastJetton.lUserJettonScore[1][i+1] - self.tabMyBets[i]
            if self:GetMeChairID() == pLastJetton.wChairID then
                    self.m_nAllPlayBet = self.m_nAllPlayBet + curBet
            end
            while curBet > 0 do
                local betNum = 0
                if curBet >= math.pow(10,7) then
                    betNum = math.pow(10,7)
                    betIndex = 7
                elseif curBet >= 5000000 then
                    betNum = 5000000
                    betIndex = 6
                elseif curBet >= 1000000 then
                    betNum = 1000000
                    betIndex = 5
                elseif curBet >= 100000 then
                    betNum = 100000
                    betIndex = 4
                elseif curBet >= 10000 then
                    betNum = 10000
                    betIndex = 3
                elseif curBet >= 1000 then
                    betNum = 1000
                    betIndex = 2
                elseif curBet >= 100 then
                    betNum = 100
                    betIndex = 1
                end

                if betNum == 0 or curBet < betNum then
                    -- 数据错误
                    print("数据错误")
                    break
                end

                curBet = curBet - betNum
                if betIndex <= 0 or betIndex > 7 then
                    betIndex = 1
                end
                self._gameView:runJettonAni(betIndex, i, self:GetMeChairID() == pLastJetton.wChairID)
                
            end
            if self:GetMeChairID() == pLastJetton.wChairID then
                self.tabMyBets[i] = pLastJetton.lUserJettonScore[1][i+1]
            end
		end
		self._gameView:updateMyBets(self.tabMyBets)
		self._gameView:updateAsset(self:GetMeScore()-self.m_nAllPlayBet)

		local startIndex = nil
		for i = 1, 7 do
			local noteNum = math.pow(10,i+1)
            if i == 6 then
                noteNum = 5000000
            elseif i == 7 then
                noteNum = math.pow(10,7)
            end
            
			if (self:GetMeScore() - self.m_nAllPlayBet) / noteNum < 1 then
				startIndex=i
				break
			end
		end

		if nil ~= startIndex then
			self._gameView:disableNoteNumBtns(startIndex)
		end
--	end
end

function GameLayer:OnSubClearJetton(dataBuffer) --清除下注 --done
	if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		return
	end

	local  pCleanJetton=ExternalFun.read_netdata(cmd.CMD_S_CeanJetton, dataBuffer)
	for i=1,cmd.AREA_COUNT-1 do
		self.tabTotalBets[i]=pCleanJetton.lAllCPlaceScore[1][i+1]
	end

	self._gameView:updateTotalBets(self.tabTotalBets)

	if self:GetMeChairID()==pCleanJetton.wChairID then
		for i=1,cmd.AREA_COUNT-1 do
			self.m_nAllPlayBet=self.m_nAllPlayBet-(self.tabMyBets[i] or 0)
		end
		
		self._gameView:updateAsset(self:GetMeScore()-self.m_nAllPlayBet)
		assignArray(self.tabMyBets,cmd.AREA_COUNT-1,0)
		self._gameView:updateMyBets(self.tabMyBets)
	
		dbg_assert(0==self.m_nAllPlayBet)
		local endIndex=nil
		for i=5,1,-1 do
			local noteNum=math.pow(10,i+1)
			if (self:GetMeScore()-self.m_nAllPlayBet)>=noteNum then
				endIndex=i
				break
			end
		end

		if nil~=endIndex then
			self._gameView:enableNoteNumBtns(endIndex)
		end

	end
end


--银行消息
function GameLayer:onSocketInsureEvent( sub,dataBuffer )
    self:dismissPopWait()
    if sub == GameServer_CMD.SUB_GR_USER_INSURE_SUCCESS then
        local cmd_table = ExternalFun.read_netdata(GameServer_CMD.CMD_GR_S_UserInsureSuccess, dataBuffer)
        self.bank_success = cmd_table
        GlobalUserItem.tabAccountInfo.lUserScore = cmd_table.lUserScore
    	GlobalUserItem.tabAccountInfo.lUserInsure = cmd_table.lUserInsure
        GlobalUserItem.lUserInsure = cmd_table.lUserInsure
        self._gameView:updateAsset(self:GetMeScore()-self.m_nAllPlayBet)
        self._gameView:onBankSuccess()
    elseif sub == GameServer_CMD.SUB_GR_USER_INSURE_FAILURE then
        local cmd_table = ExternalFun.read_netdata(GameServer_CMD.CMD_GR_S_UserInsureFailure, dataBuffer)
        self.bank_fail = cmd_table

        self._gameView:onBankFailure()
    elseif sub == GameServer_CMD.SUB_GR_USER_INSURE_INFO then --银行资料
        local cmdtable = ExternalFun.read_netdata(GameServer_CMD.CMD_GR_S_UserInsureInfo, dataBuffer)
        dump(cmdtable, "cmdtable", 6)
        GlobalUserItem.tabAccountInfo.lUserScore = cmdtable.lUserScore  
    	GlobalUserItem.tabAccountInfo.lUserInsure = cmdtable.lUserInsure
        GlobalUserItem.lUserInsure = cmdtable.lUserInsure 
        self._gameView:onGetBankInfo(cmdtable)
    else
        print("unknow gamemessage sub is ==>"..sub)
    end
end

function GameLayer:sendNetData( cmddata )
    return self._gameFrame:sendSocketData(cmddata)
end

--申请取款
function GameLayer:sendTakeScore(lScore, szPassword )
    local cmddata = ExternalFun.create_netdata(GameServer_CMD.CMD_GR_C_TakeScoreRequest)
    cmddata:setcmdinfo(GameServer_CMD.MDM_GR_INSURE, GameServer_CMD.SUB_GR_TAKE_SCORE_REQUEST)
    cmddata:pushbyte(GameServer_CMD.SUB_GR_TAKE_SCORE_REQUEST)
    cmddata:pushscore(lScore)
    cmddata:pushstring(md5(szPassword),yl.LEN_PASSWORD)

    self:sendNetData(cmddata)
end


--请求银行信息
function GameLayer:sendRequestBankInfo()
    local cmddata = CCmd_Data:create(67)
    cmddata:setcmdinfo(GameServer_CMD.MDM_GR_INSURE,GameServer_CMD.SUB_GR_QUERY_INSURE_INFO)
    cmddata:pushbyte(GameServer_CMD.SUB_GR_QUERY_INSURE_INFO)
    cmddata:pushstring(md5(GlobalUserItem.szPassword),yl.LEN_PASSWORD)

    self:sendNetData(cmddata)
end


--清除按钮消息
function GameLayer:OnCleanJetton() --done

	if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		return
	end

	--构造数据
	local cmddata = ExternalFun.create_netdata(cmd.CMD_C_CleanMeJetton)
	cmddata:pushword(self:GetMeChairID())  

	local ret=self:SendData(cmd.SUB_C_CLEAN_JETTON,cmddata) 

end

function GameLayer:getJettonIndex(lJettonScore)
    local nJetton = {100,1000 ,10000 , 100000,1000000 ,5000000 , 10000000}
    local curindex = 1

    for k ,v in pairs(nJetton)  do
        if lJettonScore == v then    
            curindex = k
            break
        end
    end
    return curindex
    
end

--加注按钮消息
function GameLayer:OnPlaceJetton(sender) --done
	if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		return
	end
 
 	local cbJettonArea=sender.m_kind
	--合法判断
	dbg_assert(cbJettonArea>=1 and cbJettonArea<cmd.AREA_COUNT)
	if (not (cbJettonArea>=1 and cbJettonArea<cmd.AREA_COUNT)) then  return  end
	--状态判断
	if (self.m_cbGameStatus~=cmd.GS_PLACE_JETTON) then
		
		return 
	end

	if self.m_nCurrentNote==nil or self.m_nCurrentNote<100 then
		return
	end
    local nJetton = {100,1000 ,10000 , 100000,1000000 ,5000000 , 10000000}
    local curindex = self:getJettonIndex(self.m_nCurrentNote)
	while self.m_nCurrentNote>=100 do  --100为最小注额
        if self:GetMeScore() -self.m_nAllPlayBet<100 then
			return 
		elseif self:GetMeScore() -self.m_nAllPlayBet < self.m_nCurrentNote then
            curindex = curindex-1
			self.m_nCurrentNote=nJetton[curindex]
		else
			break
		end
	end

	dbg_assert(self.m_nCurrentNote>=100)

    --区域限制
    local areascore = self._gameView.m_lAreaTotalScore + self.m_nCurrentNote
    if areascore > self.m_lAreaLimitScore then
        showToast(cc.Director:getInstance():getRunningScene(),"已超过该区域最大下注值",1)
        return
    end

    --庄家限制
--    if self._gameView.m_wBankerUser ~= yl.INVALID_CHAIR then
--        local useritem = self._gameView:getDataMgr():getChairUserList()[self._gameView.m_wBankerUser + 1]
--        local areascore = self._gameView.m_lAreaTotalScore + self.m_nCurrentNote
--        if useritem~=nil then
--            if self:GetMaxBankerScore(useritem.lScore,cbJettonArea) > useritem.lScore then
--                showToast(cc.Director:getInstance():getRunningScene(),"当前区域可下注额度不足",1)
--                return
--            end
--        end
--    end

    --个人限制
    local selfscore = self.m_nAllPlayBet + self.m_nCurrentNote
    if  selfscore > self.m_lMeMaxScore then
        showToast(cc.Director:getInstance():getRunningScene(),"已超过个人最大下注值",1)
        return
    end

	local cmddata = ExternalFun.create_netdata(cmd.CMD_C_PlaceJetton)
	cmddata:pushbyte(cbJettonArea)   
	cmddata:pushscore(self.m_nCurrentNote)
	local ret=self:SendData(cmd.SUB_C_PLACE_JETTON,cmddata) 

	ExternalFun.playClickEffect()
	--dbg_assert(ret and ret~=0)
	print("ret: ",ret)
end

function GameLayer:GetMaxBankerScore(score,cbJettonArea)
    local lBankerScore = score
    local LosScore = 0
    local WinScore = 0
    local bcWinArea ={}
    bcWinArea = self:GetAllWinArea(cbJettonArea)
    
	for nAreaIndex=1,cmd.AREA_COUNT-1 do
		if bcWinArea[nAreaIndex]>1 then
			LosScore = LosScore + self.tabTotalBets[nAreaIndex]*(bcWinArea[nAreaIndex])
		else
			if bcWinArea[nAreaIndex]==0 then
				WinScore = WinScore + self.tabTotalBets[nAreaIndex]
            end
		end
	end
	
	lBankerScore = lBankerScore + WinScore - LosScore
    return lBankerScore
end

--获取牌型
function GameLayer:GetCardType(cbCardData)
  local bcOutCadDataWin = {}
  local bcData =cbCardData;
  for i=1,cmd.AREA_COUNT-1 do
      bcOutCadDataWin[i] = 0
  end
  if 1==bcData or bcData==2 or bcData==3 then
    bcOutCadDataWin[1]= 6
    bcOutCadDataWin[11]= 2
  elseif 5==bcData or bcData==6 or bcData==7 then
    bcOutCadDataWin[2]= 6
    bcOutCadDataWin[10]= 2
  elseif 8==bcData or bcData==9 or bcData==10 then
    bcOutCadDataWin[3]= 8
    bcOutCadDataWin[10]= 2
  elseif 12==bcData or bcData==13 or bcData==14 then
    bcOutCadDataWin[4]= 8
    bcOutCadDataWin[10]= 2
  elseif 15==bcData or bcData==16 or bcData==17 then 
    bcOutCadDataWin[5]= 12
    bcOutCadDataWin[10]= 2
  elseif 19==bcData or bcData==20 or bcData==21 then
    bcOutCadDataWin[6]= 12
    bcOutCadDataWin[11]= 2
  elseif 22==bcData or bcData==23 or bcData==24 then
    bcOutCadDataWin[7]= 8
    bcOutCadDataWin[11]= 2
  elseif 26==bcData or bcData==27 or bcData==28 then
    bcOutCadDataWin[8]= 8
    bcOutCadDataWin[11]= 2
  else
    if bcData == 4 then
      bcOutCadDataWin[12] =100
    elseif cbCardData == 18 then
      bcOutCadDataWin[9] =24
    elseif bcData == 11 then
      bcOutCadDataWin[11] = 255
    elseif cbCardData == 25 then
      bcOutCadDataWin[10] = 1
    end
  end
  return bcOutCadDataWin
end

function GameLayer:GetAllWinArea(InArea)
	if InArea==0xFF then
		return 
    end
    --胜利区域
    local bcWinArea = {}
    local lMaxSocre = 0
	for i=1,cmd.AREA_COUNT-1 do
        bcWinArea[i] = 0
    end

	for i = 1,28 do
		local bcData = {} 
        local bcOutCadDataWin = {}
        
        bcData[1]= i
		bcOutCadDataWin = self:GetCardType(bcData[1])

		for j= 1,cmd.AREA_COUNT-1 do
			if bcOutCadDataWin[j]>1 and j==InArea then
				local Score = 0
				for nAreaIndex=1,cmd.AREA_COUNT-1 do
					if bcOutCadDataWin[nAreaIndex]>1 then
						Score = Score + self.tabTotalBets[nAreaIndex]*(bcOutCadDataWin[nAreaIndex])
					end
				end
				if Score>=lMaxSocre then
					lMaxSocre = Score
                    for i=1, cmd.AREA_COUNT-1 do
                        bcWinArea[i] = bcOutCadDataWin[i]
                    end  
				end
				break
			end
		end
	end
    return bcWinArea
end

--续投
function GameLayer:OnLastPlaceJetton( ) --done
	if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		return
	end
	
    if self.m_nCurrentNote==nil or self.m_nCurrentNote<100 then
		return
	end

 	local cmddata = ExternalFun.create_netdata(cmd.CMD_C_ContinueJetton)
	cmddata:pushword(self:GetMeChairID())
    appdf.printTable(cmddata)
	
	--发送消息
	local ret=self:SendData(cmd.SUB_C_CONTINUE_JETTON,cmddata)
end

--切换下注大小按钮消息
function GameLayer:OnNoteSwitch(sender)
	if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		return
	end
   
	self.m_nCurrentNote=sender.m_noteNum
end

function GameLayer:onEventUserScore( item )
    self._dataModle:updateUser(item)    
    self._gameView:onGetUserScore(item)

    --刷新用户列表
    self._gameView:refreshUserList()
end

function GameLayer:onEventUserStatus(useritem,newstatus,oldstatus)
    if newstatus.cbUserStatus <= yl.US_FREE then
        self._dataModle:removeUser(useritem)
    else
        --刷新用户信息
        self._dataModle:updateUser(useritem)
    end

    --刷新用户列表
    self._gameView:refreshUserList()
end

function GameLayer:onEventUserEnter( wTableID,wChairID,useritem )
    print("add user " .. useritem.wChairID .. "; nick " .. useritem.szNickName)
    --缓存用户
    self._dataModle:addUser(useritem)

    --刷新用户列表
    self._gameView:refreshUserList()
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

return GameLayer