local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")

local GameLayer = class("GameLayer", GameModel)

local cmd = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.models.GameLogic")
local GameViewLayer = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.views.layer.GameViewLayer")
local QueryDialog   = require("app.views.layer.other.QueryDialog")
local GameServer_CMD = appdf.req(appdf.HEADER_SRC.."CMD_GameServer")
local ExternalFun   = appdf.req(appdf.EXTERNAL_SRC.."ExternalFun")
-- 初始化界面
function GameLayer:ctor(frameEngine,scene)
    GameLayer.super.ctor(self, frameEngine, scene)
    frameEngine:SetDelaytime(5*60*1000)
    print("GameLayer........enter~~")
	local this = self
    self._msgModel = require(appdf.GAME_SRC .. "yule.oxsixex.src.netMsgBean.NNGameNetModel"):create()

	self._gameFrame = frameEngine
    self._scene = scene
	
    self:onInitData()
    self:enableNodeEvents()
    self:addBackKey()

    
    self.messageBgPosUp   = cc.p(667, 780)
    self.messageBgPosMid  = cc.p(667, 730)
    self.messageBgPosDown = cc.p(667, 680)

    self.m_pIconMessageBg:setPosition(self.messageBgPosDown)
end
--创建场景
function GameLayer:CreateView()
    return GameViewLayer:create(self)
        :addTo(self)
end

function GameLayer:onExit()
    self.m_tStatusFree_ = nil
    self.m_tStatusGold_ = nil
    self.m_tStatusPlay_ = nil
    self.m_tHandCardData_ = nil
    self.m_tPlayStatues_ = nil
    self.m_tOx_ = nil
    self.m_nBankerUser_ = nil

    self.m_eGameStatues_ = nil

    if self._ClockFun then
        --注销时钟
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._ClockFun) 
        self._ClockFun = nil
    end
    GameLayer.super.onExit(self)
end

function GameLayer:addBackKey()
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(function(keyCode, event)
            if keyCode == cc.KeyCode.KEY_BACK then
                event:stopPropagation()
                self:onBtnSendMessage(GameViewLayer.UiTag.eBtnBack)
            end
            end, cc.Handler.EVENT_KEYBOARD_RELEASED )
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

-- 初始化游戏数据
function GameLayer:onInitData()
    GameLayer.super.OnInitGameEngine(self)
    self.m_tStatusFree_ = {}
    self.m_tStatusPlay_ = {}
    self.m_tHandCardData_ = {}
    self.m_tPlayStatues_ = {}
    self.m_tOx_ = {0,0,0,0,0,0}
    self.m_nBankerUser_ = 0
    self.m_maskPopWait = nil
    self.m_eGameStatues_ = cmd.GameStatues.FREE_STATUES

    --计时器
    self._ClockFun = nil
    self._ClockID = yl.INVALID_ITEM
    self._ClockTime = 0
    self._ClockChair = yl.INVALID_CHAIR
    self._ClockViewChair = yl.INVALID_CHAIR
end

-- 重置游戏数据
function GameLayer:onResetData()
    GameLayer.super.OnResetGameEngine(self)
    -- body
    self.m_tStatusFree_ = {}
    self.m_tStatusPlay_ = {}
    self.m_tHandCardData_ = {}
    self.m_tPlayStatues_ = {}
    self.m_tOx_ = {0,0,0,0,0,0}
    self.m_nBankerUser_ = 0
    self.m_maskPopWait = nil
    self.m_eGameStatues_ = cmd.GameStatues.FREE_STATUES
    --设置倒计时
    self:SetGameClock(self:GetMeChairID(),cmd.IDI_START_GAME,cmd.TIME_USER_START_GAME)
end

function GameLayer:getHandCardData()
    return self.m_tHandCardData_
end

function GameLayer:getPlayStatues()
    return self.m_tPlayStatues_
end

function GameLayer:getBankUser()
    return self.m_nBankerUser_
end

function GameLayer:getOx()
    return self.m_tOx_
end

function GameLayer:getGameStatues()
    return self.m_eGameStatues_
end

function GameLayer:getGameGoldStatues()
    return self.m_tStatusGold_
end

--获取gamekind
function GameLayer:getGameKind()
    return cmd.KIND_ID
end

-- 时钟处理
function GameLayer:OnEventGameClockInfo(chair,time,clockid)
    if clockid == cmd.IDI_START_GAME then
        if time <= 0 then   
            print("clockid==IDI_START_GAME")
            self._gameFrame:setEnterAntiCheatRoom(false)--退出防作弊
            self:onExitTable()--及时退出房间
            return true
        end
    elseif clockid == cmd.IDI_TIME_OPEN_CARD then
        if time == 0 then
            if self._gameView.m_bAutoGame_ then
                self._gameView:OnOpenCard()
            end
            return true
        elseif time <= 5 then
            ExternalFun.playSoundEffect("oxsixex_game_warn.mp3")
        end
    end
end

---------------------------------------------------------发送消息-----------------------------------------------------------
--发送摊牌消息
function GameLayer:sendOpenCard(sendData)
    if sendData == nil then
        return 
    end
    local dataBuffer = CCmd_Data:create(6)
	dataBuffer:setcmdinfo(GameServer_CMD.MDM_GF_GAME,cmd.SUB_C_OPEN_CARD)
    dataBuffer:pushbyte(sendData.bOX)
    for i,v in pairs(sendData.cbOxCardData) do
        dataBuffer:pushbyte(v)
    end
	
	return self._gameFrame:sendSocketData(dataBuffer)
end

--发送获取中奖用户请求
function GameLayer:sendWinUser()
    local dataBuffer = CCmd_Data:create(0)
	dataBuffer:setcmdinfo(GameServer_CMD.MDM_GF_GAME,cmd.SUB_C_WIN_USER)
	return self._gameFrame:sendSocketData(dataBuffer)
end

function GameLayer:onBtnSendMessage(msgId,tData)
    if msgId == GameViewLayer.UiTag.eBtnBack then
        if self.m_eGameStatues_ == cmd.GameStatues.START_STATUES or self.m_eGameStatues_ == cmd.GameStatues.OPENCARD_STATUES then
            self:onQueryExitGame(1)
        else
            self:onQueryExitGame()
        end  
    elseif msgId == GameViewLayer.UiTag.eBtnStart then
        self._gameFrame:SendUserReady() 
        ExternalFun.playSoundEffect("BOY/oxsixex_ready.mp3")
        if self._gameFrame.bEnterAntiCheatRoom == true and GlobalUserItem.isForfendGameRule() then
            self:dismissPopWait()
	        if self._gameFrame:SitDown(yl.INVALID_TABLE,yl.INVALID_CHAIR) then
		        self._gameView:ShowMyPopWait("正为您配桌, 请稍后...", function()
			        self:onQueryAntiCheatExitGame()
		        end)
	        end
        end  
    elseif msgId == GameViewLayer.UiTag.eBtnLiangPai then
        self:sendOpenCard(tData)
    elseif msgId == GameViewLayer.UiTag.eBtnWinUser then
        self:sendWinUser()
    elseif msgId == GameViewLayer.UiTag.eBtnChangeDesk then
         --防作弊判断
        if self._scene._gameFrame.bEnterAntiCheatRoom == true and GlobalUserItem.isForfendGameRule() then
            showToast(cc.Director:getInstance():getRunningScene(), "游戏进行中无法换桌...", 2)
        elseif self.m_eGameStatues_ == cmd.GameStatues.START_STATUES and self:GetMeUserItem().cbUserStatus == yl.US_PLAYING then
            showToast(cc.Director:getInstance():getRunningScene(), "游戏进行中无法换桌...", 2)
        else
            self._gameFrame:QueryChangeDesk() 
            self._gameView:onResetView()
        end
    end
end
---------------------------------------------------------接收消息-----------------------------------------------------------
-- 场景信息
function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
    --辅助读取int64
	if cbGameStatus == cmd.GS_TK_FREE	then				    --空闲状态
        self:onSubFreeStatues(dataBuffer)
	elseif cbGameStatus == cmd.GS_TK_PLAYING	then			--游戏状态
        self:onSubPlayingStatues(dataBuffer)
	end
    self._gameView:MoveHead()
    self:dismissPopWait()
end

function GameLayer:onSubFreeStatues(dataBuffer)
    local tData = self._msgModel:readSubFreeStatues(dataBuffer)
    self.m_tStatusFree_ = tData
    self.m_tStatusGold_ = tData.bIsSuportBonus
    self.m_eGameStatues_ = cmd.GameStatues.FREE_STATUES

    --ui
    self._gameView:setCellScore(tData.lCellScore)
    if self.m_tStatusGold_ then
        self._gameView:setGoldScore(tData.lBonus)
    end
    print("free........",tData.lBonus)
    self._gameView:showFreeStatues()
end

function GameLayer:onSubPlayingStatues(dataBuffer)
    local tData = self._msgModel:readSubPlayingStatues(dataBuffer)

    self.m_tStatusPlay_ = tData
    self.m_tStatusGold_ = tData.bIsSuportBonus
    self.m_tHandCardData_ = tData.cbHandCardData
    self.m_nBankerUser_ = tData.wBankerUser
    self.m_tPlayStatues_ = tData.cbPlayStatus
    self.m_tOx_ = tData.bOxCard
    self.m_eGameStatues_ = cmd.GameStatues.START_STATUES

    --ui
    self._gameView:setCellScore(tData.lCellScore)
    if self.m_tStatusGold_ then
        self._gameView:setGoldScore(tData.lBonus)
    end
    self._gameView:showPlayStatues(tData)
end

function GameLayer:onEventUserStatus(useritem,newstatus,oldstatus)
    if self._gameView then 
        if useritem.dwUserID ~= GlobalUserItem.tabAccountInfo.dwUserID then
            if oldstatus.cbUserStatus == nil then
                oldstatus.cbUserStatus = yl.US_NULL
            end
            
            if newstatus.cbUserStatus <= yl.US_FREE and oldstatus.cbUserStatus > yl.US_FREE and self._gameFrame:GetTableID() == oldstatus.wTableID then
                print("同一桌子的人离开")
                self._gameView:updateUserInfo(oldstatus.wChairID)
            elseif newstatus.cbUserStatus >= yl.US_SIT and self._gameFrame:GetTableID() == useritem.wTableID then
                print("同一桌子的人进入")
                self._gameView:updateUserInfo(useritem.wChairID)
            end
        else 
            if newstatus.cbUserStatus == yl.US_READY then
                self.m_eGameStatues_ = cmd.GameStatues.READY_STATUES
                 --ui
                self._gameView:showReady()      
            end
        end
    end
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub,dataBuffer)
	if sub == cmd.SUB_S_GAME_START then 
		self:onSubGameStart(dataBuffer)
	elseif sub == cmd.SUB_S_OPEN_CARD then 
		self:OnSubOpenCard(dataBuffer)
    elseif sub == cmd.SUB_S_GAME_WIN_USER then
        self:OnSubWinUserInfo(dataBuffer)
	elseif sub == cmd.SUB_S_PLAYER_EXIT then 
		self:OnSubPlayerExit(dataBuffer)
	elseif sub == cmd.SUB_S_GAME_END then 
		self:OnSubGameEnd(dataBuffer)
	elseif sub == cmd.SUB_S_ADMIN_STORAGE_INFO then 
		self:onSubAdminStorageInfo(dataBuffer)
	elseif sub == cmd.SUB_S_REQUEST_QUERY_RESULT then 
		self:OnSubRequestQueryResult(dataBuffer)
	elseif sub == cmd.SUB_S_USER_CONTROL then 
		self:onSubUserControl(dataBuffer)
    elseif sub == cmd.SUB_S_USER_CONTROL_COMPLETE then 
		self:onSubUserControlComplete(dataBuffer)
    elseif sub == cmd.SUB_S_OPERATION_RECORD then 
		self:onSubOperationRecord(dataBuffer)
    elseif sub == cmd.SUB_S_REQUEST_UDPATE_ROOMINFO_RESULT then 
		self:onSubUpdateRoomInfo(dataBuffer)
	else
		print("unknow gamemessage sub is"..sub)
	end
end

--游戏开始
function GameLayer:onSubGameStart(dataBuffer)
    --防作弊判断
    if self._gameFrame.bEnterAntiCheatRoom == true and GlobalUserItem.isForfendGameRule() then
        self:dismissPopWait()
        self._gameView:CloseMyPopWait()
    end
    local tData = self._msgModel:readSubGameStart(dataBuffer)
    self.m_tHandCardData_ = tData.cbCardData
    self.m_nBankerUser_ = tData.wBankerUser
    self.m_tPlayStatues_ = tData.cbPlayStatus

    self.m_eGameStatues_ = cmd.GameStatues.START_STATUES
    --ui
    self._gameView:showGameStart()
end

--用户摊牌
function GameLayer:OnSubOpenCard(dataBuffer)
    -- body
    local tData = self._msgModel:readSubOpenCard(dataBuffer)

    self.m_tOx_[tData.wPlayerID+1] = tData.bOpen
    if self._gameFrame:GetChairID() == tData.wPlayerID then
         self.m_eGameStatues_ = cmd.GameStatues.OPENCARD_STATUES
    end

    --ui
    self._gameView:showOpenCard(tData)
end

--中奖用户信息
function GameLayer:OnSubWinUserInfo(dataBuffer)
     -- body
    local tData = self._msgModel:readSubWinUser(dataBuffer)

    --ui
    self._gameView:showWinUser(tData)
end

--用户强退
function GameLayer:OnSubPlayerExit(dataBuffer)
    local wPlayerID = self._msgModel:readSubPlayerExit(dataBuffer)
    self.m_tPlayStatues_[wPlayerID+1] = 0

    --ui
    self._gameView:dealGameExit(wPlayerID)
    print("用户强退")
end

--游戏结束
function GameLayer:OnSubGameEnd(dataBuffer)
    -- body
    local tData = self._msgModel:readSubGameEnd(dataBuffer)
    self.m_eGameStatues_ = cmd.GameStatues.END_STATUES
    --ui
    if self.m_tStatusGold_ then
        self._gameView:setGoldScore(tData.lBonus)
    end
    print("End........",tData.lBonus)
    self._gameView:showGameEnd(tData)
end

--特殊客户端信息
function GameLayer:onSubAdminStorageInfo(dataBuffer)
    local tData = self._msgModel:readSubAdminStorageInfo(dataBuffer)
end

--查询用户结果
function GameLayer:OnSubRequestQueryResult(dataBuffer)
    -- body
    local tData = self._msgModel:readSubRequestQueryResult(dataBuffer)
end

--用户控制
function GameLayer:onSubUserControl(dataBuffer)
    local tData = self._msgModel:readSubUserControl(dataBuffer)
end

--用户控制结果
function GameLayer:onSubUserControlComplete(dataBuffer)
    local tData = self._msgModel:readSubUserControlComplete(dataBuffer)
end

--操作记录
function GameLayer:onSubOperationRecord(dataBuffer)
    local tData = self._msgModel:readSubOperationRecord(dataBuffer)
end

function GameLayer:onSubUpdateRoomInfo(dataBuffer)
   local tData = self._msgModel:readSubUpdateRoomInfo(dataBuffer)
end

function GameLayer:onUserChat(chatData)
    --ui
    self._gameView:showChat(chatData)
end

function GameLayer:onUserExpression(chatPresData)
    --ui
    self._gameView:showChat(chatPresData)
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
----------------------------------------------------------------逻辑-------------------------------------------------------------------
--取整
function GameLayer:getIntPart(x)
    if x <= 0 then
       return math.ceil(x);
    end

    if math.ceil(x) == x then
       x = math.ceil(x);
    else
       x = math.ceil(x) - 1;
    end
    return x;
end
--转换钱
function GameLayer:convertMoneyToString(money,nWan)
    local iWan = nWan or 10000
    if type(money) == "string" then
        money = tonumber(money)
    end
	if money < iWan then
		return tostring(money)
	elseif money >= iWan and money < 100000000 then
        local dstStr = ""
		local sWan = "万"
		local oneNum = money / 10000;
        oneNum = self:getIntPart(oneNum)
		local twoNum = (money - oneNum * 10000) / 100
        twoNum = self:getIntPart(twoNum)
		if twoNum == 0 then
			dstStr = tostring(oneNum)
			dstStr = dstStr .. sWan
		else
			if twoNum > 10 then
                local a1 = twoNum/10
				local a2 = self:getIntPart(a1)
				if a2 == a1 then
					dstStr = string.format("%d.%d", oneNum, a2)
				else
					dstStr = string.format("%d.%d", oneNum, twoNum)
				end	
                dstStr = dstStr .. sWan
			elseif twoNum < 10 then
				dstStr = string.format("%d.0%d", oneNum, twoNum)
				dstStr = dstStr .. sWan
			else
				dstStr = string.format("%d.%d", oneNum, twoNum/10)
				dstStr = dstStr .. sWan
			end
		end

        return dstStr
	else
        local dstStr = ""
		local sYi = "亿"
		local oneNum = money / 100000000
        oneNum = self:getIntPart(oneNum)
		local twoNum = (money - oneNum * 100000000) / 1000000
        twoNum = self:getIntPart(twoNum)
		if twoNum == 0 then
			dstStr = tostring(oneNum)
			dstStr = dstStr .. sYi
		else
            if twoNum > 10 then
                local a1 = twoNum/10
				local a2 = self:getIntPart(a1)
				if a2 == a1 then
					dstStr = string.format("%d.%d", oneNum, a2)
				else
					dstStr = string.format("%d.%d", oneNum, twoNum)
				end	
                dstStr = dstStr .. sYi
			elseif twoNum < 10 then
				dstStr = string.format("%d.0%d", oneNum, twoNum)
				dstStr = dstStr .. sYi
			else
				dstStr = string.format("%d.%d", oneNum, twoNum/10)
				dstStr = dstStr .. sYi
			end
		end
        return dstStr
	end
end

return GameLayer