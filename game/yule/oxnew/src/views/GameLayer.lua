local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")

local GameLayer = class("GameLayer", GameModel)

local cmd = appdf.req(appdf.GAME_SRC.."yule.oxnew.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.oxnew.src.models.GameLogic")
local GameViewLayer = appdf.req(appdf.GAME_SRC.."yule.oxnew.src.views.layer.GameViewLayer")
local QueryDialog = appdf.req("app.views.layer.other.QueryDialog")
local GameServer_CMD = appdf.req(appdf.HEADER_SRC.."CMD_GameServer")
local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

-- 初始化界面
function GameLayer:ctor(frameEngine,scene)
    GameLayer.super.ctor(self, frameEngine, scene)
    frameEngine:SetDelaytime(5*60*1000)
end

--创建场景
function GameLayer:CreateView()
    return GameViewLayer:create(self):addTo(self)
end

-- 初始化游戏数据
function GameLayer:OnInitGameEngine()
    self.cbPlayStatus = {0, 0, 0, 0}
    self.cbCardData = {}
    self.wBankerUser = yl.INVALID_CHAIR
    self.cbDynamicJoin = 0
    self.m_tabPrivateRoomConfig = {}
    self.m_bStartGame = false

    GameLayer.super.OnInitGameEngine(self)
end

--换位
function GameLayer:onChangeDesk()
    self._gameFrame:QueryChangeDesk()
    self._gameView:onResetView()
end

-- 椅子号转视图位置,注意椅子号从0~nChairCount-1,返回的视图位置从1~nChairCount
function GameLayer:SwitchViewChairID(chair)
    local viewid = yl.INVALID_CHAIR
    local nChairCount = 4
    local nChairID = self:GetMeChairID()
    if chair ~= yl.INVALID_CHAIR and chair < nChairCount then
        viewid = math.mod(chair + math.floor(nChairCount * 3/2) - nChairID, nChairCount) + 1
    end
    return viewid
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()
    -- body
    GameLayer.super.OnResetGameEngine(self)
end

--获取gamekind
function GameLayer:getGameKind()
    return cmd.KIND_ID
end

-- 时钟处理
function GameLayer:OnEventGameClockInfo(chair,time,clockId)
    -- body
    if time == 5 then
        ExternalFun.playSoundEffect("oxnew_game_warn.mp3")
    end

    if clockId == cmd.IDI_NULLITY then
    elseif clockId == cmd.IDI_START_GAME then
        if time <= 0 then
            self._gameFrame:setEnterAntiCheatRoom(false)--退出防作弊
            self:onExitTable()--及时退出房间
        end
    elseif clockId == cmd.IDI_CALL_BANKER then
        if time < 1 then
            -- 非私人房处理叫庄
            if not GlobalUserItem.bPrivateRoom then
                self._gameView.btCallBanker:setVisible(false)
		        self._gameView.btCancel:setVisible(false)
                --self._gameView:onButtonClickedEvent(GameViewLayer.BT_CANCEL)
            end
        end
    elseif clockId == cmd.IDI_TIME_USER_ADD_SCORE then
        if time < 1 then
            if not GlobalUserItem.bPrivateRoom then
                for i = 1, 4 do
			        self._gameView.btChip[i]:setVisible(false)
		        end
                --self._gameView:onButtonClickedEvent(GameViewLayer.BT_CHIP + 4)
            end
        end
    elseif clockId == cmd.IDI_TIME_OPEN_CARD then
        if time < 1 then
            self._gameView.bCanMoveCard = false
		    self._gameView.btOpenCard:setVisible(false)
            -- 非私人房处理摊牌
            --if not GlobalUserItem.bPrivateRoom then
                --self._gameView:onButtonClickedEvent(GameViewLayer.BT_OPENCARD)
            --end
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

-- 语音播放开始
function GameLayer:onUserVoiceStart( useritem, filepath )
    local viewid = self:SwitchViewChairID(useritem.wChairID)
    self._gameView:onUserVoiceStart(viewid)
end

-- 语音播放结束
function GameLayer:onUserVoiceEnded( useritem, filepath )
    local viewid = self:SwitchViewChairID(useritem.wChairID)
    self._gameView:onUserVoiceEnded(viewid)
end

--退出桌子
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
            end)
            )
        )
        return
    end

   self:onExitRoom()
end

--离开房间
function GameLayer:onExitRoom()
    self:KillGameClock()
    self._scene:onKeyBack()
end

function GameLayer:onExit()
    self:KillGameClock()
    self:dismissPopWait()
    GameLayer.super.onExit(self)
end

function GameLayer:onGetSitUserNum()
    local num = 0
    for i = 1, cmd.GAME_PLAYER do
        if nil ~= self._gameView.m_tabUserItem[i] then
            num = num + 1
        end
    end
    return num
end

function GameLayer:getUserInfoByChairID(chairId)
    local viewId = self:SwitchViewChairID(chairId)
    return self._gameView.m_tabUserItem[viewId]
end

function GameLayer:onGetNoticeReady()
    print("牛牛 系统通知准备")
    if nil ~= self._gameView and nil ~= self._gameView.btStart then
        self._gameView.btStart:setVisible(true)
    end
end

--系统消息
function GameLayer:onSystemMessage( wType,szString )
    local runScene = cc.Director:getInstance():getRunningScene()
    if wType == 501 or wType == 515 then
        local msg = szString or "你的游戏币不足，无法继续游戏"
        local query = QueryDialog:create(msg, function(ok)
                if ok == true then
                    self:onExitTable()
                end
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

-- 场景信息
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)
--  self._gameView:onResetView()
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

    -- 刷新房卡
    if PriRoom and GlobalUserItem.bPrivateRoom then
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            self._gameView._priView:onRefreshInfo()
        end
    end
end

--空闲场景
function GameLayer:onSceneFree(dataBuffer)
    print("onSceneFree")
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_StatusFree, dataBuffer);
    self.lCellScore = cmd_table.lCellScore

    -- 坐庄模式
    self.m_tabPrivateRoomConfig.bankerMode = cmd_table.banker_config
    -- 房卡积分模式
    self.m_tabPrivateRoomConfig.bRoomCardScore = cmd_table.bRoomCardScore
    -- 积分房卡配置的下注
    self.m_tabPrivateRoomConfig.lRoomCardJetton = cmd_table.lRoomCardJetton[1]

    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        local tableID = self._gameFrame:GetTableID()
        local userItem = self._gameFrame:getTableUserItem(tableID,i-1)
        if nil ~= userItem then
            self._gameView:OnUpdateUser(wViewChairId, userItem)     
        end
    end

    if not GlobalUserItem.isAntiCheat() then
        self._gameView.btStart:setVisible(true)
--      self._gameView:setClockPosition(cmd.MY_VIEWID)
        -- 私人房无倒计时
        if not GlobalUserItem.bPrivateRoom then
            -- 设置倒计时
            self:SetGameClock(self:GetMeChairID(), cmd.IDI_START_GAME, cmd.TIME_USER_START_GAME)
            self._gameView:setHeadClock(cmd.MY_VIEWID,cmd.TIME_USER_START_GAME)
        else
            self._gameView.spriteClock:setVisible(false)
        end
    end
end
--叫庄场景
function GameLayer:onSceneCall(dataBuffer)
    print("onSceneCall")
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_StatusCall, dataBuffer);
    local wCallBanker = cmd_table.wCallBanker
    self.lCellScore = cmd_table.lCellScore
    self.cbDynamicJoin = cmd_table.cbDynamicJoin
    self.cbPlayStatus = cmd_table.cbPlayStatus[1]
    
    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        local tableID = self._gameFrame:GetTableID()
        local userItem = self._gameFrame:getTableUserItem(tableID,i-1)
        if nil ~= userItem then
            self._gameView:OnUpdateUser(wViewChairId, userItem)     
        end
    end
    -- 坐庄模式
    self.m_tabPrivateRoomConfig.bankerMode = cmd_table.banker_config
    -- 房卡积分模式
    self.m_tabPrivateRoomConfig.bRoomCardScore = cmd_table.bRoomCardScore
    -- 积分房卡配置的下注
    self.m_tabPrivateRoomConfig.lRoomCardJetton = cmd_table.lRoomCardJetton[1]

    local wViewBankerId = self:SwitchViewChairID(wCallBanker)
    
    self._gameView:gameCallBanker(self:SwitchViewChairID(wCallBanker))
--  self._gameView:setClockPosition(wViewBankerId)

    self:SetGameClock(wCallBanker, cmd.IDI_CALL_BANKER, cmd_table.cbTimeLeave)
    self._gameView:setHeadClock(self:SwitchViewChairID(wCallBanker),cmd_table.cbTimeLeave)
    -- 刷新局数
    if PriRoom and GlobalUserItem.bPrivateRoom then
        local curcount = PriRoom:getInstance().m_tabPriData.dwPlayCount
        PriRoom:getInstance().m_tabPriData.dwPlayCount = curcount - 1
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            self._gameView._priView:onRefreshInfo()
        end
    end
end
--下注场景
function GameLayer:onSceneScore(dataBuffer)
    print("onSceneScore")
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_StatusScore, dataBuffer);
    self.lCellScore = cmd_table.lCellScore
    self.cbPlayStatus = cmd_table.cbPlayStatus[1]
    self.cbDynamicJoin = cmd_table.cbDynamicJoin
    local lTurnMaxScore = cmd_table.lTurnMaxScore[1]
    local lTableScore = cmd_table.lTableScore[1]
    self.wBankerUser = cmd_table.wBankerUser  
    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        if self.cbPlayStatus[i] == 1 then
            if self:SwitchViewChairID(self.wBankerUser) ~= wViewChairId then 
                self._gameView:setBetsVisible(wViewChairId,true)
                self._gameView:setHeadClock(wViewChairId,cmd_table.cbTimeLeave)
            end
            self._gameView:setUserTableScore(wViewChairId, lTableScore[i])           
        else
            self._gameView:stopHeadClock(wViewChairId)
            self._gameView:setBetsVisible(wViewChairId,false)
        end
        local tableID = self._gameFrame:GetTableID()
        local userItem = self._gameFrame:getTableUserItem(tableID,i-1)
        if nil ~= userItem then
            self._gameView:OnUpdateUser(wViewChairId, userItem)     
        end  
    end  

    -- 坐庄模式
    self.m_tabPrivateRoomConfig.bankerMode = cmd_table.banker_config
    -- 房卡积分模式
    self.m_tabPrivateRoomConfig.bRoomCardScore = cmd_table.bRoomCardScore
    -- 积分房卡配置的下注
    self.m_tabPrivateRoomConfig.lRoomCardJetton = cmd_table.lRoomCardJetton[1]

    self._gameView:setBankerUser(self:SwitchViewChairID(self.wBankerUser),self.cbDynamicJoin)
    -- 积分房卡配置的下注
    if self.m_tabPrivateRoomConfig.bRoomCardScore then
        self._gameView:setScoreRoomJetton(self.m_tabPrivateRoomConfig.lRoomCardJetton)
    else
        local TurnMaxScore = {}
        for i = 1, cmd.GAME_PLAYER do 
            local wViewChairId = self:SwitchViewChairID(i - 1)
            TurnMaxScore[wViewChairId] = lTurnMaxScore[i]
        end      
        self._gameView:setTurnMaxScore(TurnMaxScore)
    end

    local tempStatus = {}
    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        tempStatus[wViewChairId] = self.cbPlayStatus[i]
    end

    if self.cbPlayStatus[self:GetMeChairID() + 1] == 1 then
        self._gameView:gameStart(self:SwitchViewChairID(self.wBankerUser),tempStatus)
    end

--  self._gameView:setClockPosition()
    self:SetGameClock(self.wBankerUser, cmd.IDI_TIME_USER_ADD_SCORE, cmd_table.cbTimeLeave)
end
--游戏场景
function GameLayer:onScenePlaying(dataBuffer)
    print("onScenePlaying")
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_StatusPlay, dataBuffer);
    self.lCellScore = cmd_table.lCellScore
    self.cbPlayStatus = cmd_table.cbPlayStatus[1]
    self.cbDynamicJoin = cmd_table.cbDynamicJoin
    local lTurnMaxScore = cmd_table.lTurnMaxScore[1]    
    local lTableScore = cmd_table.lTableScore[1]
    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        local tableID = self._gameFrame:GetTableID()
        local userItem = self._gameFrame:getTableUserItem(tableID,i-1)
        if nil ~= userItem then
            self._gameView:OnUpdateUser(wViewChairId, userItem)     
        end
    end
    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        if self.cbPlayStatus[i] == 1 and lTableScore[i] ~= 0 then
            self._gameView:gameAddScore(wViewChairId, lTableScore[i],false)
        end          
    end

    local MaxScore ={}
    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        local Score = lTurnMaxScore[i]
        MaxScore[wViewChairId] = math.abs(Score)
    end

    self._gameView:setTurnMaxScore(MaxScore)
    self._gameView:setGoldNum()

    self.wBankerUser = cmd_table.wBankerUser

    self.cbCardData = cmd_table.cbHandCardData 

    local bOxCard = cmd_table.bOxCard[1]

    self._gameView:stopHeadClock()
    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        if self.cbPlayStatus[i] == 1 then
            self._gameView:setHeadClock(wViewChairId,cmd_table.cbTimeLeave)
        end
    end

    -- 坐庄模式
    self.m_tabPrivateRoomConfig.bankerMode = cmd_table.banker_config
    -- 房卡积分模式
    self.m_tabPrivateRoomConfig.bRoomCardScore = cmd_table.bRoomCardScore
    -- 积分房卡配置的下注
    self.m_tabPrivateRoomConfig.lRoomCardJetton = cmd_table.lRoomCardJetton[1]
    -- 积分房卡配置的下注
    if self.m_tabPrivateRoomConfig.bRoomCardScore then
        self._gameView:setScoreRoomJetton(self.m_tabPrivateRoomConfig.lRoomCardJetton)
    else
        self._gameView:setTurnMaxScore(lTurnMaxScore)
    end

    --显示牌并开自己的牌
    for i = 1, cmd.GAME_PLAYER do
        if self.cbPlayStatus[i] == 1 then
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
    end
    self._gameView:setBankerUser(self:SwitchViewChairID(self.wBankerUser),self.cbDynamicJoin)
    self._gameView:gameScenePlaying()
--  self._gameView:setClockPosition()
    self:SetGameClock(self.wBankerUser, cmd.IDI_TIME_OPEN_CARD, cmd_table.cbTimeLeave)
    
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub,dataBuffer)
	if sub == cmd.SUB_S_CALL_BANKER then 
        self.m_cbGameStatus = cmd.GS_TK_CALL
		self:onSubCallBanker(dataBuffer)
	elseif sub == cmd.SUB_S_GAME_START then
        self.m_cbGameStatus = cmd.GS_TK_CALL 
		self:onSubGameStart(dataBuffer)
	elseif sub == cmd.SUB_S_ADD_SCORE then 
        self.m_cbGameStatus = cmd.GS_TK_SCORE
		self:onSubAddScore(dataBuffer)
	elseif sub == cmd.SUB_S_SEND_CARD then 
        self.m_cbGameStatus = cmd.GS_TK_PLAYING
		self:onSubSendCard(dataBuffer)
	elseif sub == cmd.SUB_S_OPEN_CARD then 
        self.m_cbGameStatus = cmd.GS_TK_PLAYING
		self:onSubOpenCard(dataBuffer)
	elseif sub == cmd.SUB_S_PLAYER_EXIT then 
        self.m_cbGameStatus = cmd.GS_TK_PLAYING
		self:onSubPlayerExit(dataBuffer)
	elseif sub == cmd.SUB_S_GAME_END then 
        self.m_cbGameStatus = cmd.GS_TK_PLAYING
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
            self.cbPlayStatus[i] = dataBuffer:readbyte()
        end
    end
    self._gameView:gameCallBanker(self:SwitchViewChairID(wCallBanker), bFirstTimes)
    if bFirstTimes == false then
        self._gameView:stopHeadClock()
    end
--  self._gameView:setClockPosition(self:SwitchViewChairID(wCallBanker))
    self:SetGameClock(wCallBanker, cmd.IDI_CALL_BANKER, cmd.TIME_USER_CALL_BANKER)
    self._gameView:setHeadClock(self:SwitchViewChairID(wCallBanker),cmd.TIME_USER_CALL_BANKER)
    -- 刷新房卡
    if PriRoom and GlobalUserItem.bPrivateRoom then
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            self._gameView._priView:onRefreshInfo()
        end
    end
end

--游戏开始
function GameLayer:onSubGameStart(dataBuffer)
    local int64 = Integer64:new()
    local lTurnMaxScore ={}
    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        local MaxScore = dataBuffer:readscore(int64):getvalue()
        lTurnMaxScore[wViewChairId] = MaxScore
    end
    self.wBankerUser = dataBuffer:readword()
    -- 坐庄模式
    self.m_tabPrivateRoomConfig.bankerMode = dataBuffer:readint()
    -- 房卡积分模式
    self.m_tabPrivateRoomConfig.bRoomCardScore = dataBuffer:readbool()
    -- 积分房卡配置的下注
    local tabJetton = {}
    tabJetton[1] = dataBuffer:readscore(int64):getvalue()
    tabJetton[2] = dataBuffer:readscore(int64):getvalue()
    tabJetton[3] = dataBuffer:readscore(int64):getvalue()
    tabJetton[4] = dataBuffer:readscore(int64):getvalue()
    self.m_tabPrivateRoomConfig.lRoomCardJetton = tabJetton

    local tempStatus = {}
    -- 玩家状态
    for i = 1, cmd.GAME_PLAYER do
        self.cbPlayStatus[i] = dataBuffer:readbyte()
        local wViewChairId = self:SwitchViewChairID(i - 1)
        tempStatus[wViewChairId] = self.cbPlayStatus[i]
    end

    self._gameView:setBankerUser(self:SwitchViewChairID(self.wBankerUser),self.cbDynamicJoin)

    -- 积分房卡配置的下注
    if self.m_tabPrivateRoomConfig.bRoomCardScore then
        self._gameView:setScoreRoomJetton(tabJetton)
    else
        self._gameView:setTurnMaxScore(lTurnMaxScore)
    end

    self._gameView:gameStart(self:SwitchViewChairID(self.wBankerUser),tempStatus)
    self._gameView:stopAllClock() 
--  self._gameView:setClockPosition()
    self:SetGameClock(self.wBankerUser, cmd.IDI_TIME_USER_ADD_SCORE, cmd.TIME_USER_ADD_SCORE)
    local bankerViewId = self:SwitchViewChairID(self.wBankerUser)    
    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        if wViewChairId ~= bankerViewId then        
            if self.cbPlayStatus[i] == 1 then
                self._gameView:setHeadClock(wViewChairId,cmd.TIME_USER_ADD_SCORE)
            end
        end
    end
    -- 刷新房卡
    if PriRoom and GlobalUserItem.bPrivateRoom then
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            PriRoom:getInstance().m_tabPriData.dwPlayCount = PriRoom:getInstance().m_tabPriData.dwPlayCount + 1
            self._gameView._priView:onRefreshInfo()
        end
    end
end

--用户下注
function GameLayer:onSubAddScore(dataBuffer)
    local int64 = Integer64:new()
    local wAddScoreUser = dataBuffer:readword()
    local lAddScoreCount = dataBuffer:readscore(int64):getvalue()

    local userViewId = self:SwitchViewChairID(wAddScoreUser)
    self._gameView:gameAddScore(userViewId, lAddScoreCount,true)
    self._gameView:stopHeadClock(userViewId)

    self._gameView:runChipAnimate(self._gameView:getGoldNum(lAddScoreCount,userViewId),userViewId)
    ExternalFun.playSoundEffect("oxnew_add_score.mp3")
end

--发牌消息
function GameLayer:onSubSendCard(dataBuffer)
    for i = 1, cmd.GAME_PLAYER do
        self.cbCardData[i] = {}
        for j = 1, 5 do
            self.cbCardData[i][j] = dataBuffer:readbyte()
        end
    end
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
    self:sendCardClock()
    self._gameView:gameSendCard(self:SwitchViewChairID(self.wBankerUser), self:getPlayNum()*5)
end

--用户摊牌
function GameLayer:onSubOpenCard(dataBuffer)
    local wPlayerID = dataBuffer:readword()
    local bOpen = dataBuffer:readbyte()
    local wViewChairId = self:SwitchViewChairID(wPlayerID)
    self._gameView:stopHeadClock(wViewChairId)
    if wViewChairId == cmd.MY_VIEWID then
        self:openCard(wPlayerID)
    else       
        self._gameView:setOpenCardVisible(wViewChairId, true)
    end
    ExternalFun.playSoundEffect("oxnew_open_card.mp3")
end

--用户强退
function GameLayer:onSubPlayerExit(dataBuffer)
    local wPlayerID = dataBuffer:readword()
    local wViewChairId = self:SwitchViewChairID(wPlayerID)
    self.cbPlayStatus[wPlayerID + 1] = 0
    self._gameView.bCanMoveCard = false
    self._gameView.nodePlayer[wViewChairId]:setVisible(false)
    self._gameView.btOpenCard:setVisible(false)
    self._gameView:setOpenCardVisible(wViewChairId, false)
--  self._gameView.spritePrompt:setVisible(false)
--    for i = 1, 5 do
--        self._gameView.cardFrame[i]:setVisible(false)
--        self._gameView.cardFrame[i]:setSelected(false)
--    end  
end

--游戏结束
function GameLayer:onSubGameEnd(dataBuffer)
    self.m_bStartGame = false
    self.cbDynamicJoin = 0
    local int64 = Integer64:new()

    local lGameTax = {}
    
    for i = 1, cmd.GAME_PLAYER do
        lGameTax[i] = dataBuffer:readscore(int64):getvalue()
        
    end

    local lTurnMaxScore ={}

    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        local MaxScore = dataBuffer:readscore(int64):getvalue()
        lTurnMaxScore[wViewChairId] = math.abs(MaxScore)
    end

    self._gameView:setTurnMaxScore(lTurnMaxScore)
    self._gameView:setGoldNum()
    -- 获取底分
    local lCellScore =  self.lCellScore
    
    local lGameScore = {}
    local winChair = {0,0,0,0}
    local loseScore = {0,0,0,0}
    local isBankerLose = false
    for i = 1, cmd.GAME_PLAYER do
        lGameScore[i] = dataBuffer:readscore(int64):getvalue()      
        if self.cbPlayStatus[i] == 1 then
            local wViewChairId = self:SwitchViewChairID(i - 1)
            self._gameView:runWinLoseAnimate(wViewChairId, lGameScore[i])
            loseScore[wViewChairId] = lGameScore[i]
        end
    end

    local MyChair = self:GetMeChairID()
    if MyChair ~= yl.INVALID_CHAIR then
        local score = lGameScore[MyChair+1]
        if score ~= 0 then
            self._gameView:gameEnd(score)     
        elseif score == 0 then
            self._gameView.btStart:setVisible(true)
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

    local cbDelayOverGame = dataBuffer:readbyte()

    for i = 1, cmd.GAME_PLAYER do
        self.cbPlayStatus[i] = 0
        
    end

    self._gameView:stopHeadClock()
    self:KillGameClock()
    --self._gameView:setClockPosition(cmd.MY_VIEWID)
    -- 私人房无倒计时
    if not GlobalUserItem.bPrivateRoom then
        -- 设置倒计时
        self:SetGameClock(self:GetMeChairID(), cmd.IDI_START_GAME, cmd.TIME_USER_START_GAME)
        self._gameView:setHeadClock(cmd.MY_VIEWID,cmd.TIME_USER_START_GAME)
    else
        self._gameView.spriteClock:setVisible(false)
    end
end

--开始游戏
function GameLayer:onStartGame()
    if true == self.m_bPriScoreLow then
        local msg = self.m_szScoreMsg or ""
        self.m_querydialog = QueryDialog:create(msg,function()
            self:onExitTable()
        end,nil,1)
        self.m_querydialog:setCanTouchOutside(false)
        self.m_querydialog:addTo(self)
    else
        -- body
        self:KillGameClock()
        self._gameView:stopHeadClock(wViewChairId)
        self._gameView:onResetView(1)
        self._gameFrame:SendUserReady()
        self.m_bStartGame = true
    end
end

function GameLayer:getPlayNum()
    local num = 0
    for i = 1, cmd.GAME_PLAYER do
        if self.cbPlayStatus[i] == 1 then
            num = num + 1
        end
    end
    return num
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

function GameLayer:sendCardClock()
    --self._gameView:setClockPosition()
    self:SetGameClock(self:GetMeChairID(), cmd.IDI_TIME_OPEN_CARD, cmd.TIME_USER_OPEN_CARD)
    for i = 1, cmd.GAME_PLAYER do
        if self.cbPlayStatus[i] == 1 then
            local wViewChairId = self:SwitchViewChairID(i - 1)
            self._gameView:setHeadClock(wViewChairId,cmd.TIME_USER_OPEN_CARD)
        end
    end
end

function GameLayer:sendCardFinish()
    for i = 1, cmd.GAME_PLAYER do
        if self.cbPlayStatus[i] == 1 then
            local wViewChairId = self:SwitchViewChairID(i - 1)
            if wViewChairId == cmd.MY_VIEWID then
                self._gameView.btOpenCard:setVisible(true)
            end
        end
    end
end

function GameLayer:openCard(chairId, bEnded)
    --排列cbCardData
    local index = chairId + 1
    if self.cbCardData[index] == nil then
        print("出错")
        return false
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

    return true
end

function GameLayer:getMeCardLogicValue(num)
    local index = self:GetMeChairID() + 1
    local value = GameLogic:getCardLogicValue(self.cbCardData[index][num])
    local str = string.format("index:%d, num:%d, self.cbCardData[index][num]:%d, return:%d", index, num, self.cbCardData[index][num], value)
    print(str)
    return value
end

function GameLayer:getOxCard(cbCardData)
    return GameLogic:getOxCard(cbCardData)
end

function GameLayer:getPrivateRoomConfig()
    return self.m_tabPrivateRoomConfig
end

--********************   发送消息     *********************--
function GameLayer:onBanker(cbBanker)
    local dataBuffer = CCmd_Data:create(1)
    dataBuffer:setcmdinfo(GameServer_CMD.MDM_GF_GAME,cmd.SUB_C_CALL_BANKER)
    dataBuffer:pushbyte(cbBanker)
    return self._gameFrame:sendSocketData(dataBuffer)
end

function GameLayer:onAddScore(lScore)
    if self:SwitchViewChairID(self.wBankerUser) == cmd.MY_VIEWID then
        return
    end
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

return GameLayer