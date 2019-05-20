local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")

local GameLayer = class("GameLayer", GameModel)

local cmd = appdf.req(appdf.GAME_SRC.."yule.oxex.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.oxex.src.models.GameLogic")
local GameViewLayer = appdf.req(appdf.GAME_SRC.."yule.oxex.src.views.layer.GameViewLayer")
local GameServer_CMD = appdf.req(appdf.HEADER_SRC.."CMD_GameServer")
local QueryDialog = require("app.views.layer.other.QueryDialog")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

function GameLayer:ctor(frameEngine, scene)
    GameLayer.super.ctor(self, frameEngine, scene)
    frameEngine:SetDelaytime(5*60*1000)
end

function GameLayer:CreateView()
    return GameViewLayer:create(self):addTo(self)
end

function GameLayer:OnInitGameEngine()
    GameLayer.super.OnInitGameEngine(self)
    self.cbPlayStatus = {0, 0}
    self.cbCardData = {}
    self.wBankerUser = yl.INVALID_CHAIR
end

function GameLayer:OnResetGameEngine()
    GameLayer.super.OnResetGameEngine(self)
end

function GameLayer:SwitchViewChairID(chair)
    local viewid = yl.INVALID_CHAIR
    local meChairID = self:GetMeChairID()
    if chair ~= yl.INVALID_CHAIR and chair < 2 then
        viewid = 0 == meChairID and chair + 1 or chair + 2
        if viewid == 3 then
        	viewid = 1
        end
    end
    return viewid
end

--获取gamekind
function GameLayer:getGameKind()
    return cmd.KIND_ID
end

function GameLayer:onExit()
    GameLayer.super.onExit(self)
end

--退出桌子yxz
function GameLayer:onExitTable()
    self:KillGameClock()
    local MeItem = self:GetMeUserItem()
    if MeItem and MeItem.cbUserStatus > yl.US_FREE then
        self:showPopWait()
        self:runAction(cc.Sequence:create(
            cc.CallFunc:create(
                function () 
                    self._gameFrame:StandUp(1)
                end),
            cc.DelayTime:create(10),
            cc.CallFunc:create(
                function ()
                    print("delay leave")
                    self:onExitRoom()
                end)))
        return
    end

   self:onExitRoom()
end

--离开房间yxz
function GameLayer:onExitRoom()
    self:KillGameClock()
    self._scene:onKeyBack()
end
-- 计时器响应
function GameLayer:OnEventGameClockInfo(chair,time,clockId)
    -- body    
    if time == 5 then
        ExternalFun.playSoundEffect("oxex_game_warn.mp3")
    end

    if clockId == cmd.IDI_NULLITY then
    elseif clockId == cmd.IDI_START_GAME then
        if time <= 0 then
            self._gameFrame:setEnterAntiCheatRoom(false)--退出防作弊
            self:onExitTable();--及时退出房间
        end
    elseif clockId == cmd.IDI_CALL_BANKER then
        if time < 1 then
            self._gameView.btCallBanker:setVisible(false)
            self._gameView.btCancel:setVisible(false)
            --self._gameView:onButtonClickedEvent(GameViewLayer.BT_CANCEL)
        end
    elseif clockId == cmd.IDI_TIME_USER_ADD_SCORE then
        if time < 1 then  
            for i = 1, 4 do
	            self._gameView.btChip[i]:setVisible(false)
	        end      
            --self._gameView:onButtonClickedEvent(GameViewLayer.BT_CHIP + 4)
        end
    elseif clockId == cmd.IDI_TIME_OPEN_CARD then
        if time < 1 then
            self._gameView.bCanMoveCard = false
	        self._gameView.btOpenCard:setVisible(false)
            --self._gameView:onButtonClickedEvent(GameViewLayer.BT_OPENCARD)
        end
    end
end

--用户聊天
function GameLayer:onUserChat(chat, wChairId)
    self._gameView:userChat(self:SwitchViewChairID(wChairId), chat.szChatString)
end

--用户表情
function GameLayer:onUserExpression(expression, wChairId)
    self._gameView:userExpression(self:SwitchViewChairID(wChairId), expression.wItemIndex)
end

-- 场景信息
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)
	local tableId = self._gameFrame:GetTableID()
    self.m_cbGameStatus = cbGameStatus
	if cbGameStatus == cmd.GS_TK_FREE	then				--空闲状态
        self:onSceneFree(dataBuffer)
	elseif cbGameStatus == cmd.GS_TK_CALL	then			--叫分状态
        self._gameView.btStart:setVisible(false)
        self:onSceneCall(dataBuffer)
	elseif cbGameStatus == cmd.GS_TK_SCORE	then			--下注状态
        self._gameView.btStart:setVisible(false)
        self:onSceneScore(dataBuffer)
    elseif cbGameStatus == cmd.GS_TK_PLAYING  then            --游戏状态
        self._gameView.btStart:setVisible(false)
        self:onScenePlaying(dataBuffer)
	end
    self._gameView:MoveHead()
    self:dismissPopWait()
end

--换位操作
function GameLayer:onChangeDesk()
    self._gameFrame:QueryChangeDesk()
end

--空闲场景
function GameLayer:onSceneFree(dataBuffer)
    print("onSceneFree")
    local int64 = Integer64.new()
    local lCellScore = dataBuffer:readscore(int64):getvalue()
    local lRoomStorageStart = dataBuffer:readscore(int64):getvalue()
    local lRoomStorageCurrent = dataBuffer:readscore(int64):getvalue()

    local lTurnScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnScore[i] = dataBuffer:readscore(int64):getvalue()
    end

    local lCollectScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lCollectScore[i] = dataBuffer:readscore(int64):getvalue()
    end

    local lRobotScoreMin = dataBuffer:readscore(int64):getvalue()
    local lRobotScoreMax = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGet = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGetBanker = dataBuffer:readscore(int64):getvalue()
    local lRobotBankStoMul = dataBuffer:readscore(int64):getvalue()

    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        local tableID = self._gameFrame:GetTableID()
        local userItem = self._gameFrame:getTableUserItem(tableID,i-1)
        if nil ~= userItem then
            self._gameView:OnUpdateUser(wViewChairId, userItem)     
        end
    end

--  self._gameView:setCellScore(lCellScore)
    if not GlobalUserItem.isAntiCheat() then    --非作弊房间
--      self._gameView:setClockPosition(cmd.MY_VIEWID)
        self._gameView.btStart:setVisible(true)        
        self._gameView:setHeadClock(cmd.MY_VIEWID,cmd.TIME_USER_START_GAME)
        self:SetGameClock(self:GetMeChairID(), cmd.IDI_START_GAME, cmd.TIME_USER_START_GAME)        
    end
end
--叫庄场景
function GameLayer:onSceneCall(dataBuffer)
    print("onSceneCall")
    local int64 = Integer64.new()
    local wCallBanker = dataBuffer:readword()
    self.cbDynamicJoin = dataBuffer:readbyte()
    for i = 1, cmd.GAME_PLAYER do
        self.cbPlayStatus[i] = dataBuffer:readbyte()
    end
    local cbTimeLeave = dataBuffer:readbyte()
    local lTurnScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnScore[i] = dataBuffer:readscore(int64):getvalue()
    end
    local lCollectScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lCollectScore[i] = dataBuffer:readscore(int64):getvalue()
        local wViewChairId = self:SwitchViewChairID(i - 1)
        local tableID = self._gameFrame:GetTableID()
        local userItem = self._gameFrame:getTableUserItem(tableID,i-1)
        if nil ~= userItem then
            self._gameView:OnUpdateUser(wViewChairId, userItem)     
        end
    end
       
    local lRoomStorageStart = dataBuffer:readscore(int64):getvalue()
    local lRoomStorageCurrent = dataBuffer:readscore(int64):getvalue()
    local lRobotScoreMin = dataBuffer:readscore(int64):getvalue()
    local lRobotScoreMax = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGet = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGetBanker = dataBuffer:readscore(int64):getvalue()
    local lRobotBankStoMul = dataBuffer:readscore(int64):getvalue()
    local wViewBankerId = self:SwitchViewChairID(wCallBanker)

--  self._gameView:setClockPosition(wViewBankerId)
    self._gameView:gameCallBanker(self:SwitchViewChairID(wCallBanker))
    self._gameView:setHeadClock(self:SwitchViewChairID(wCallBanker),cbTimeLeave)
    self:SetGameClock(wCallBanker, cmd.IDI_CALL_BANKER, cbTimeLeave)    
end
--下注场景
function GameLayer:onSceneScore(dataBuffer)
    print("onSceneScore")
    local int64 = Integer64.new()
    for i = 1, cmd.GAME_PLAYER do
        self.cbPlayStatus[i] = dataBuffer:readbyte()
    end
    self.cbDynamicJoin = dataBuffer:readbyte()
    local cbTimeLeave = dataBuffer:readbyte()
    local lTurnMaxScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnMaxScore[i] = dataBuffer:readscore(int64):getvalue()
    end
    local lTableScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTableScore[i] = dataBuffer:readscore(int64):getvalue() 
        local wViewChairId = self:SwitchViewChairID(i - 1)
        if self.cbPlayStatus[i] == 1 then  
            if self:SwitchViewChairID(self.wBankerUser) ~= wViewChairId then 
                self._gameView:setHeadClock(wViewChairId,cbTimeLeave)
            else
                self._gameView:stopHeadClock(wViewChairId)
            end        
            self._gameView:setUserTableScore(wViewChairId, lTableScore[i])
        end
        local tableID = self._gameFrame:GetTableID()
        local userItem = self._gameFrame:getTableUserItem(tableID,i-1)
        if nil ~= userItem then
            self._gameView:OnUpdateUser(wViewChairId, userItem)     
        end  
    end
    self.wBankerUser = dataBuffer:readword()
    local lRoomStorageStart = dataBuffer:readscore(int64):getvalue()
    local lRoomStorageCurrent = dataBuffer:readscore(int64):getvalue()
    --机器人配置
    local lRobotScoreMin = dataBuffer:readscore(int64):getvalue()
    local lRobotScoreMax = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGet = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGetBanker = dataBuffer:readscore(int64):getvalue()
    local lRobotBankStoMul = dataBuffer:readscore(int64):getvalue()

    local lTurnScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnScore[i] = dataBuffer:readscore(int64):getvalue()
    end
    local lCollectScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lCollectScore[i] = dataBuffer:readscore(int64):getvalue()
    end

--  self._gameView:setClockPosition()
    local viewBankerId = self:SwitchViewChairID(self.wBankerUser)
    self._gameView:setBankerUser(viewBankerId,self.cbDynamicJoin)
    self._gameView:setTurnMaxScore(lTurnMaxScore)
    self._gameView:gameStart(viewBankerId)   
    self:SetGameClock(self.wBankerUser, cmd.IDI_TIME_USER_ADD_SCORE, cbTimeLeave)
end
--游戏场景
function GameLayer:onScenePlaying(dataBuffer)
    print("onScenePlaying")
    local int64 = Integer64.new()
    for i = 1, cmd.GAME_PLAYER do
        self.cbPlayStatus[i] = dataBuffer:readbyte()
    end
    self.cbDynamicJoin = dataBuffer:readbyte()
    local cbTimeLeave = dataBuffer:readbyte()
    local lTurnMaxScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnMaxScore[i] = dataBuffer:readscore(int64):getvalue()
    end
    local lTableScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTableScore[i] = dataBuffer:readscore(int64):getvalue()
        local wViewChairId = self:SwitchViewChairID(i - 1)
        if self.cbPlayStatus[i] == 1 and lTableScore[i] ~= 0 then            
            self._gameView:gameAddScore(wViewChairId, lTableScore[i],false)
        end

        local tableID = self._gameFrame:GetTableID()
        local userItem = self._gameFrame:getTableUserItem(tableID,i-1)
        if nil ~= userItem then           
            self._gameView:OnUpdateUser(wViewChairId, userItem)     
        end  
    end

    self._gameView:setTurnMaxScore(lTurnMaxScore)
    self._gameView:setGoldNum()

    self.wBankerUser = dataBuffer:readword()
    for i = 1, cmd.GAME_PLAYER do
        self.cbCardData[i] = {}
        for j = 1, 5 do
            self.cbCardData[i][j] = dataBuffer:readbyte()
        end
    end

    local bOxCard = {}
    self._gameView:stopHeadClock()
    for i = 1, cmd.GAME_PLAYER do
        bOxCard[i] = dataBuffer:readbyte()
        local wViewChairId = self:SwitchViewChairID(i - 1)
        if self.cbPlayStatus[i] == 1 then
            self._gameView:setHeadClock(wViewChairId,cbTimeLeave)
        end
    end

    local lTurnScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnScore[i] = dataBuffer:readscore(int64):getvalue()
    end
    local lCollectScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lCollectScore[i] = dataBuffer:readscore(int64):getvalue()
    end

    local lRoomStorageStart = dataBuffer:readscore(int64):getvalue()
    local lRoomStorageCurrent = dataBuffer:readscore(int64):getvalue()
    local lRobotScoreMin = dataBuffer:readscore(int64):getvalue()
    local lRobotScoreMax = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGet = dataBuffer:readscore(int64):getvalue()
    local lRobotBankGetBanker = dataBuffer:readscore(int64):getvalue()
    local lRobotBankStoMul = dataBuffer:readscore(int64):getvalue()

    --显示牌并开自己的牌
    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        for j = 1, 5 do
            local card = self._gameView.nodeCard[wViewChairId]:getChildByTag(j)
            card:setVisible(true)
            if wViewChairId == cmd.MY_VIEWID then          --是自己则打开牌
                local value = GameLogic:getCardValue(self.cbCardData[i][j])
                local color = GameLogic:getCardColor(self.cbCardData[i][j])
                self._gameView:setCardTextureRect(wViewChairId, j, value, color)
            end
        end
    end
--  self._gameView:setClockPosition()
    self._gameView:setBankerUser(self:SwitchViewChairID(self.wBankerUser),self.cbDynamicJoin)
    self._gameView:gameScenePlaying()   
    self:SetGameClock(self.wBankerUser, cmd.IDI_TIME_OPEN_CARD,cbTimeLeave)
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub,dataBuffer)  
    self.m_cbGameStatus = cmd.GS_TK_PLAYING
	if sub == cmd.SUB_S_CALL_BANKER then 
		self:onSubCallBanker(dataBuffer)
	elseif sub == cmd.SUB_S_GAME_START then 
		self:onSubGameStart(dataBuffer)
	elseif sub == cmd.SUB_S_ADD_SCORE then 
		self:onSubAddScore(dataBuffer)
	elseif sub == cmd.SUB_S_SEND_CARD then 
		self:onSubSendCard(dataBuffer)
	elseif sub == cmd.SUB_S_OPEN_CARD then 
		self:onSubOpenCard(dataBuffer)
	elseif sub == cmd.SUB_S_PLAYER_EXIT then 
		self:onSubPlayerExit(dataBuffer)
	elseif sub == cmd.SUB_S_GAME_END then 
        self.m_cbGameStatus = cmd.GS_TK_FREE
		self:onSubGameEnd(dataBuffer)
	else
		print("unknow gamemessage sub is"..sub)
	end
end

--用户叫庄
function GameLayer:onSubCallBanker(dataBuffer)
    local wCallBanker = dataBuffer:readword()
    local bFirstTimes = dataBuffer:readbool()

    if bFirstTimes then
	    for i = 1, cmd.GAME_PLAYER do
	        local userItem = self._gameFrame:getTableUserItem(self._gameFrame:GetTableID(), i - 1)
	        if userItem and self.cbDynamicJoin ~= 1 then
	        	self.cbPlayStatus[i] = 1
	        end
	    end
    end

    self._gameView:gameCallBanker(self:SwitchViewChairID(wCallBanker), bFirstTimes)
    if bFirstTimes == false then
        self._gameView:stopHeadClock()
    end    
    self:SetGameClock(wCallBanker, cmd.IDI_CALL_BANKER, cmd.TIME_USER_CALL_BANKER)
    self._gameView:setHeadClock(self:SwitchViewChairID(wCallBanker),cmd.TIME_USER_CALL_BANKER)
--  self._gameView:setClockPosition(self:SwitchViewChairID(wCallBanker))
end

--游戏开始
function GameLayer:onSubGameStart(dataBuffer)
    local int64 = Integer64:new()
    local lTurnMaxScore = {}
    for i = 1 , cmd.GAME_PLAYER do
        lTurnMaxScore[i] = dataBuffer:readscore(int64):getvalue()
    end
    self.wBankerUser = dataBuffer:readword()
    local bankerViewId = self:SwitchViewChairID(self.wBankerUser)
    self._gameView:setBankerUser(bankerViewId,self.cbDynamicJoin)
    self._gameView:setTurnMaxScore(lTurnMaxScore)
    self._gameView:gameStart(bankerViewId)
    self._gameView:stopHeadClock(bankerViewId)
--  self._gameView:setClockPosition()
    self:SetGameClock(self.wBankerUser, cmd.IDI_TIME_USER_ADD_SCORE, cmd.TIME_USER_ADD_SCORE)       
    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        if wViewChairId ~= bankerViewId then        
            if self.cbPlayStatus[i] == 1 then
                self._gameView:setHeadClock(wViewChairId,cmd.TIME_USER_ADD_SCORE)
            end
        end
    end
end

--用户下注
function GameLayer:onSubAddScore(dataBuffer)
    ExternalFun.playSoundEffect("oxex_add_score.mp3")
    local int64 = Integer64:new()
    local wAddScoreUser = dataBuffer:readword()
    local lAddScoreCount = dataBuffer:readscore(int64):getvalue()    
    local userViewId = self:SwitchViewChairID(wAddScoreUser)
    self._gameView:gameAddScore(userViewId, lAddScoreCount,true)
    self._gameView:stopHeadClock(userViewId)
    self._gameView:runChipAnimate(self._gameView:getGoldNum(lAddScoreCount),userViewId)    
end

--发牌消息
function GameLayer:onSubSendCard(dataBuffer)
    for i = 1, cmd.GAME_PLAYER do
        self.cbCardData[i] = {}
        for j = 1, 5 do
            self.cbCardData[i][j] = dataBuffer:readbyte()
        end
    end
    local bAllAndroidUser = dataBuffer:readbool()

    --打开自己的牌
    for i = 1, 5 do
        local index = self:GetMeChairID() + 1
        local data = self.cbCardData[index][i]
        local value = GameLogic:getCardValue(data)
        local color = GameLogic:getCardColor(data)
        local card = self._gameView.nodeCard[cmd.MY_VIEWID]:getChildByTag(i)
        self._gameView:setCardTextureRect(cmd.MY_VIEWID, i, value, color)
    end
    self:KillGameClock()
    self._gameView:stopHeadClock()    
    self:sendCardFinish()
    self._gameView:gameSendCard(self:SwitchViewChairID(self.wBankerUser), cmd.GAME_PLAYER*5)
    
end

--用户摊牌
function GameLayer:onSubOpenCard(dataBuffer)
    ExternalFun.playSoundEffect("oxex_open_card.mp3")
    local wPlayerID = dataBuffer:readword()
    local bOpen = dataBuffer:readbyte()
    local wViewChairId = self:SwitchViewChairID(wPlayerID)
    
    self._gameView:stopHeadClock(wViewChairId)
    if wViewChairId == cmd.MY_VIEWID then
        self:openCard(wPlayerID)
    else
        self._gameView:setOpenCardVisible(wViewChairId, true)
    end    
end

--用户强退
function GameLayer:onSubPlayerExit(dataBuffer)
    local wPlayerID = dataBuffer:readword()
    local wViewChairId = self:SwitchViewChairID(wPlayerID)
    self.cbPlayStatus[wPlayerID + 1] = 0
    self._gameView.nodePlayer[wViewChairId]:setVisible(false)
    self._gameView.bCanMoveCard = false
    self._gameView.btOpenCard:setVisible(false)
    self._gameView:setOpenCardVisible(wViewChairId, false)
end

--游戏结束
function GameLayer:onSubGameEnd(dataBuffer)
    local int64 = Integer64:new()

    local lGameTax = {}
    for i = 1, cmd.GAME_PLAYER do
        lGameTax[i] = dataBuffer:readscore(int64):getvalue()
    end

    local lGameScore = {}
    local loseScore = {0,0}
    for i = 1, cmd.GAME_PLAYER do
        lGameScore[i] = dataBuffer:readscore(int64):getvalue()
        if self.cbPlayStatus[i] == 1 then
            local wViewChairId = self:SwitchViewChairID(i - 1)
            self._gameView:runWinLoseAnimate(wViewChairId, lGameScore[i])
            loseScore[wViewChairId] = lGameScore[i]       
        end        
    end
    self._gameView:runOtherGoldAnimate(loseScore)
    --开牌
    local data = {}
    for i = 1, cmd.GAME_PLAYER do
        data[i] = dataBuffer:readbyte()
        if self.cbPlayStatus[i] == 1 then
            self:openCard(i - 1, true)
        end
    end

    for i = 1, cmd.GAME_PLAYER do
        self.cbPlayStatus[i] = 0
    end

    local index = self:GetMeChairID() + 1
    self:KillGameClock()
    self._gameView:stopHeadClock() 
    self.cbDynamicJoin = 0
    self._gameView:gameEnd(lGameScore[index])          
    self:SetGameClock(self:GetMeChairID(), cmd.IDI_START_GAME, cmd.TIME_USER_START_GAME)   
    self._gameView:setHeadClock(cmd.MY_VIEWID,cmd.TIME_USER_START_GAME) 
--  self._gameView:setClockPosition(cmd.MY_VIEWID)    
end

--开始游戏
function GameLayer:onStartGame()
    -- body
    self:KillGameClock()
    self._gameView:stopHeadClock(wViewChairId)
    self._gameView:onResetView(1)
    self._gameFrame:SendUserReady()
end

--将视图id转换为普通id
function GameLayer:isPlayerPlaying(viewId)
    if viewId < 1 or viewId > 4 then
        print("view chair id error!")
        return false
    end

    for i = 1, cmd.GAME_PLAYER do
        if self:SwitchViewChairID(i - 1) == viewId then
            if self.cbPlayStatus[i] == 1 then
                return true
            end
        end
    end

    return false
end

function GameLayer:sendCardFinish()
    --self._gameView:setClockPosition()
    self:SetGameClock(self:GetMeChairID(), cmd.IDI_TIME_OPEN_CARD, cmd.TIME_USER_OPEN_CARD)
    for i = 1, cmd.GAME_PLAYER do
        if self.cbPlayStatus[i] == 1 then
            local wViewChairId = self:SwitchViewChairID(i - 1)
            self._gameView:setHeadClock(wViewChairId,cmd.TIME_USER_OPEN_CARD)
        end
    end
end

function GameLayer:openCard(chairId, bEnded)
    --排列cbCardData
    local index = chairId + 1
    if self.cbCardData[index] == nil then
        return
    end
    if #self.cbCardData[index] == 0 then
        return
    end

    GameLogic:getOxCard(self.cbCardData[index])
    local cbOx = GameLogic:getCardType(self.cbCardData[index])

    local viewId = self:SwitchViewChairID(chairId)
    for i = 1, 5 do
        local data = self.cbCardData[index][i]
        local value = GameLogic:getCardValue(data)
        local color = GameLogic:getCardColor(data)
        local card = self._gameView.nodeCard[viewId]:getChildByTag(i)
        self._gameView:setCardTextureRectEx(viewId, i, value, color)
    end

    self._gameView:gameOpenCard(viewId, cbOx, bEnded)
end

function GameLayer:getMeCardLogicValue(num)
    local index = self:GetMeChairID() + 1

    --此段为测试错误
    if nil == index then
        showToast(cc.Director:getInstance():getRunningScene(), "nil == index", 1)
        return false
    end
    if nil == num then
        showToast(cc.Director:getInstance():getRunningScene(), "nil == index", 1)
        return false
    end
    if nil == self.cbCardData[index][num] then
        showToast(cc.Director:getInstance():getRunningScene(), "nil == index", 1)
        return false
    end

    return GameLogic:getCardLogicValue(self.cbCardData[index][num])
end

function GameLayer:getOxCard(cbCardData)
    return GameLogic:getOxCard(cbCardData)
end

--********************   发送消息     *********************--
function GameLayer:onBanker(cbBanker)
    local dataBuffer = CCmd_Data:create(1)
    dataBuffer:setcmdinfo(GameServer_CMD.MDM_GF_GAME,cmd.SUB_C_CALL_BANKER)
    dataBuffer:pushbyte(cbBanker)
    return self._gameFrame:sendSocketData(dataBuffer)
end

function GameLayer:onAddScore(lScore)
    local dataBuffer = CCmd_Data:create(8)
    dataBuffer:setcmdinfo(GameServer_CMD.MDM_GF_GAME, cmd.SUB_C_ADD_SCORE)
    dataBuffer:pushscore(lScore)
    return self._gameFrame:sendSocketData(dataBuffer)
end

function GameLayer:onOpenCard()
    local index = self:GetMeChairID() + 1
    local bOx = GameLogic:getOxCard(self.cbCardData[index])
    
    local dataBuffer = CCmd_Data:create(1)
    dataBuffer:setcmdinfo(GameServer_CMD.MDM_GF_GAME, cmd.SUB_C_OPEN_CARD)
    dataBuffer:pushbyte(bOx and 1 or 0)
    return self._gameFrame:sendSocketData(dataBuffer)
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