local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")

local GameLayer = class("GameLayer", GameModel)

local cmd = appdf.req(appdf.GAME_SRC.."yule.oxfive.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.oxfive.src.models.GameLogic")
local GameViewLayer = appdf.req(appdf.GAME_SRC.."yule.oxfive.src.views.layer.GameViewLayer")
local QueryDialog = appdf.req("app.views.layer.other.QueryDialog")
local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameServer_CMD = appdf.req(appdf.HEADER_SRC.."CMD_GameServer")
-- 初始化界面
function GameLayer:ctor(frameEngine,scene)
    GameLayer.super.ctor(self, frameEngine, scene)

end

function GameLayer:getParentNode()
    return self._scene
end
--创建场景
function GameLayer:CreateView()
    return GameViewLayer:create(self):addTo(self)
end

-- 初始化游戏数据
function GameLayer:OnInitGameEngine()
    self.cbPlayStatus = {0, 0, 0, 0,0} --游戏状态
    self.lGameEndScore = {0,0,0,0,0} --游戏结束分数
    self.lFreeConif = {0, 0, 0, 0} --积分
    self.lPercentConfig = {0, 0, 0, 0} --百分比
    self.lCardType = {}         --牌型
    self.cbCardData = {}
    self.wBankerUser = yl.INVALID_CHAIR
    self.cbDynamicJoin = 0
    self.m_tabPrivateRoomConfig = {}
    self.m_bStartGame = false
    self.isPriOver = false
    self.bAddScore = false
    self.m_lMaxTurnScore = 0

    self.m_tabUserItem = {}

    --约战
    self.m_userRecord = {}   --用户记录

    GameLayer.super.OnInitGameEngine(self)
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()

    GameLayer.super.OnResetGameEngine(self)
    self._gameView:onResetView()

    self.m_lMaxTurnScore = 0

    --print("重置游戏数据")
    self.cbPlayStatus = { 0, 0, 0 ,0 ,0} --游戏状态
    self.lFreeConif = {0, 0, 0, 0} --积分
    self.lPercentConfig = {0, 0, 0, 0} --百分比
    self.lCardType = {}

    --self.cbCardData = {}
    self.wBankerUser = yl.INVALID_CHAIR
    self.cbDynamicJoin = 0
    self.m_tabPrivateRoomConfig = {}
    self.m_bStartGame = false
    self.isPriOver = false
    self.bAddScore = false

end

-- 椅子号转视图位置,注意椅子号从0~nChairCount-1,返回的视图位置从1~nChairCount
function GameLayer:SwitchViewChairID(chair)
    local viewid = yl.INVALID_CHAIR
    local nChairCount = 5
    local nChairID = self:GetMeChairID()
    if chair ~= yl.INVALID_CHAIR and chair < nChairCount then
        viewid = math.mod(chair + math.floor(nChairCount * 3/2) - nChairID, nChairCount) + 1
    end
    return viewid
end

--将视图id转换为普通id
function GameLayer:SwitchChairID( viewid )
    if viewid < 1 or viewid >6 then
        error("this is error viewid")
    end
    for i=1,cmd.GAME_PLAYER do
        if self:SwitchViewChairID(i-1) == viewid then
            return i
        end
    end
end

--是否正在玩
function GameLayer:isPlayerPlaying(viewId)
    if viewId < 1 or viewId > 6 then
        --print("view chair id error!")
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

--获取gamekind
function GameLayer:getGameKind()
    return cmd.KIND_ID
end

-- 时钟处理
function GameLayer:OnEventGameClockInfo(chair,time,clockId)

    self._gameView:logicClockInfo(chair,time,clockId)
   
end

--用户分数
function GameLayer:onEventUserScore( item )
    if item.wTableID ~= self:GetMeUserItem().wTableID then
       return
    end

    self._gameView:updateScore(self:SwitchViewChairID(item.wChairID))
end

--用户聊天
function GameLayer:onUserChat(chat, wChairId)
    --print("玩家聊天", chat.szChatString)
    self._gameView:onUserChat(chat, self:SwitchViewChairID(wChairId))
end

--用户表情
function GameLayer:onUserExpression(expression, wChairId)
    self._gameView:onUserExpression(expression, self:SwitchViewChairID(wChairId))
end

-- 语音播放结束
function GameLayer:onUserVoiceEnded( useritem, filepath )
    local viewid = self:SwitchViewChairID(useritem.wChairID)
    if viewid and viewid ~= yl.INVALID_CHAIR then
        --print("语音播放结束,viewid",viewid)
        self._gameView:ShowUserVoice(viewid, false)
    end
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
                end
                ),
            cc.DelayTime:create(10),
            cc.CallFunc:create(
                function ()
                    --print("delay leave")
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
    self._scene:onKeyBack()
end

--退出
function  GameLayer:onExit()
    self:KillGameClock()
    self:dismissPopWait()
    GameLayer.super.onExit(self)
end

--坐下人数
function GameLayer:onGetSitUserNum()
    local num = 0
    for i = 1, cmd.GAME_PLAYER do
        if nil ~= self.m_tabUserItem[i] then
            num = num + 1
        end
    end
    return num
end

function GameLayer:getUserInfoByChairID(chairId)
    local viewId = self:SwitchViewChairID(chairId)
    return self.m_tabUserItem[viewId]
end

function GameLayer:onGetNoticeReady()
    --print("牛牛 系统通知准备")
    if nil ~= self._gameView and nil ~= self._gameView.btStart then
        self._gameView.btStart:setVisible(true)
        self._gameView.gBetsSelf:setVisible(false)
        -- 清除正在下注图标
        for i = 1, cmd.GAME_PLAYER do
            self._gameView:setBetsVisible(i,false)
            self._gameView:hiddenMulBet(i,false)
        end    
    end
end

--系统消息
function GameLayer:onSystemMessage( wType,szString )
    if wType == 501 or wType == 515 then
        local msg = szString or "你的游戏币不足，无法继续游戏"
        local query = QueryDialog:create(msg, function(ok)
                if ok == true then
                    self:onExitTable()
                end
            end):setCanTouchOutside(false)
                :addTo(self)
    end
end


-- 场景信息
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)

    --self._gameView:onResetView()
    self.m_cbGameStatus = cbGameStatus
	if cbGameStatus == cmd.GS_TK_FREE	then				--空闲状态
        self:onSceneFree(dataBuffer)
	elseif cbGameStatus == cmd.GS_TK_CALL	then			--叫分状态
        self._gameView.btStart:setVisible(false) 
        self:onSceneCall(dataBuffer)
	elseif cbGameStatus == cmd.GS_TK_SCORE	then			--下注状态
        self._gameView.btStart:setVisible(false) 
        self:onSceneScore(dataBuffer)
    elseif cbGameStatus == cmd.GS_TK_PLAYING  then           --游戏状态
        self._gameView.btStart:setVisible(false) 
        self:onScenePlaying(dataBuffer)
	end
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
    local lCellScore = cmd_table.lCellScore
    local lRoomStorageStart = cmd_table.lRoomStorageStart
    local lRoomStorageCurrent = cmd_table.lRoomStorageCurrent

    local lTurnScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnScore[i] = cmd_table.lTurnScore[1][i]
    end

    local lCollectScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lCollectScore[i] = cmd_table.lCollectScore[1][i]
    end

    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        local tableID = self._gameFrame:GetTableID()
        local userItem = self._gameFrame:getTableUserItem(tableID,i-1)
        if nil ~= userItem then
            self._gameView:OnUpdateUser(wViewChairId, userItem)     
        end
    end

    self._gameView:setBaseScore(lCellScore)
    if not GlobalUserItem.isAntiCheat() then
        local useritem = self:GetMeUserItem()

        if useritem.cbUserStatus == yl.US_SIT then
            self._gameView.btStart:setVisible(true)
        end

        if useritem.cbUserStatus > yl.US_SIT then
            return
        end
        
        -- 私人房无倒计时
        if not GlobalUserItem.bPrivateRoom then
            -- 设置倒计时
            self:KillGameClock()
            self:SetGameClock(self:GetMeChairID(), cmd.IDI_START_GAME, cmd.TIME_USER_START_GAME)
            self._gameView:setHeadClock(cmd.MY_VIEWID,cmd.TIME_USER_START_GAME)
        end
    end
end

--叫庄场景
function GameLayer:onSceneCall(dataBuffer)
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_StatusCall, dataBuffer);
    dump(cmd_table)
    
    local lCellScore = cmd_table.lCellScore
    local wCallBanker = cmd_table.wCallBanker
    self.cbDynamicJoin = cmd_table.cbDynamicJoin
    --print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~动态加入：", self.cbDynamicJoin)
    for i = 1, cmd.GAME_PLAYER do
        --游戏状态
        self.cbPlayStatus[i] = cmd_table.cbPlayStatus[1][i]
    end
    local lRoomStorageStart = cmd_table.lRoomStorageStart
    local lRoomStorageCurrent = cmd_table.lRoomStorageCurrent

    local lTurnScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnScore[i] = cmd_table.lTurnScore[1][i]
    end
    local lCollectScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lCollectScore[i] = cmd_table.lCollectScore[1][i]
    end

    self._gameView:setBaseScore(lCellScore)
    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        local tableID = self._gameFrame:GetTableID()
        local userItem = self._gameFrame:getTableUserItem(tableID,i-1)
        if nil ~= userItem then
            self._gameView:OnUpdateUser(wViewChairId, userItem)     
        end
    end

    --叫庄状态
    local cbCallBankerStatus = {}
    for i = 1, cmd.GAME_PLAYER do
        cbCallBankerStatus[i] = cmd_table.bCallStatus[1][i]
    end

    --叫庄倍数
    local cbCallTimes = {}
    for i = 1, cmd.GAME_PLAYER do
        cbCallTimes[i] = cmd_table.cbCallTimes[1][i]
    end

    for i = 1, cmd.GAME_PLAYER do
        if self.cbPlayStatus[i] == 1 then 
            local wViewChairId = self:SwitchViewChairID(i - 1)
            if cbCallBankerStatus[i] == false then --当前玩家没有叫庄
                self:KillGameClock()
                self:SetGameClock(wViewChairId, cmd.IDI_CALL_BANKER, cmd_table.cbTimeLeave) 
                self._gameView:setHeadClock(wViewChairId,cmd_table.cbTimeLeave)
                self._gameView:gameCallBanker(wViewChairId)
                if self.cbDynamicJoin == 0 then 
                    self._gameView:onCallBanker(true)
                end
            else
                 if wViewChairId == cmd.MY_VIEWID then 
                    self._gameView:onCallBanker(false)
                 end
                 self._gameView:setCallMultiple(wViewChairId,cbCallTimes[i])   
            end
            
        end
    end      
end

--叫分场景 
function GameLayer:onSceneScore(dataBuffer)
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_StatusScore, dataBuffer);
    for i = 1, cmd.GAME_PLAYER do
        --游戏状态
        self.cbPlayStatus[i] = cmd_table.cbPlayStatus[1][i]
    end
    self.cbDynamicJoin = cmd_table.cbDynamicJoin
    local lCellScore = cmd_table.lCellScore
    self._gameView:setBaseScore(lCellScore) 
    --self._gameView:setTurnMaxMulToScore()

    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        local tableID = self._gameFrame:GetTableID()
        local userItem = self._gameFrame:getTableUserItem(tableID,i-1)
        if nil ~= userItem then
            self._gameView:OnUpdateUser(wViewChairId, userItem)     
        end
    end

    --庄家
    self.wBankerUser = cmd_table.wBankerUser
    local lRoomStorageStart = cmd_table.lRoomStorageStart
    local lRoomStorageCurrent = cmd_table.lRoomStorageCurrent
    local lTurnScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnScore[i] = cmd_table.lTurnScore[1][i]
    end
    local lCollectScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lCollectScore[i] = cmd_table.lCollectScore[1][i]
    end

    --已下注分数
    local lTableScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTableScore[i] = cmd_table.lTableScore[1][i]
        local wViewChairId = self:SwitchViewChairID(i - 1)
        local bankerViewId = self:SwitchViewChairID(self.wBankerUser)    
        if self.cbPlayStatus[i] == 1 then
            if bankerViewId ~= wViewChairId then
                self._gameView:setBetsVisible(wViewChairId,true)
                self._gameView:hiddenMulBet(wViewChairId,false)
                if lTableScore[i] == 0 then
                    self._gameView:setHeadClock(wViewChairId,cmd_table.cbTimeLeave)
                end
            end
            self._gameView:setUserTableScore(wViewChairId, lTableScore[i])
            if lTableScore[i] ~= 0 then
                self._gameView:gameAddScore(wViewChairId, lTableScore[i],false)
            end
        else
             self._gameView:setBetsVisible(wViewChairId,false)
            -- self._gameView:setMulBet(viewId,lTableScore[i])
             self._gameView:stopHeadClock(wViewChairId)
        end
    end

    self._gameView:setGoldNum()

    --庄家信息
    self._gameView:setCallMultiple(self:SwitchViewChairID(self.wBankerUser), cmd_table.cbCurrBankerTimes)
    self._gameView:setBankerUser(self:SwitchViewChairID(self.wBankerUser),self.cbDynamicJoin)
    self._gameView:setBankerMultiple(self:SwitchViewChairID(self.wBankerUser))

    -- 积分房卡配置的下注
    local TurnMaxScore = {}
    for i = 1, cmd.GAME_PLAYER do 
        local wViewChairId = self:SwitchViewChairID(i - 1)
        TurnMaxScore[wViewChairId] = lTableScore[i]
    end   

    -- 下注类型
    if self:SwitchViewChairID(self.wBankerUser) ~= cmd.MY_VIEWID and lTableScore[self:GetMeChairID()] == 0 then 
        if self.cbPlayStatus[cmd.MY_VIEWID] == 1 and self.cbDynamicJoin == 0 then
             self._gameView.gBetsSelf:setVisible(true)
        end
        self._gameView:setScoreJetton()
        self._gameView:showChipBtn(self:SwitchViewChairID(self.wBankerUser))
    end

    self._gameView:resetEffect()
end

--游戏场景
function GameLayer:onScenePlaying(dataBuffer)
    print("onScenePlaying")
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_StatusPlay, dataBuffer);
    for i = 1, cmd.GAME_PLAYER do
        --游戏状态
        self.cbPlayStatus[i] = cmd_table.cbPlayStatus[1][i]
    end
    self.cbDynamicJoin = cmd_table.cbDynamicJoin
    local lCellScore = cmd_table.lCellScore
    self._gameView:setBaseScore(lCellScore)      
    --self._gameView:setTurnMaxMulToScore()

    local lTableMul = {}
    for i = 1, cmd.GAME_PLAYER do
        lTableMul[i] = cmd_table.lTableScore[1][i]
        if self.cbPlayStatus[i] == 1 and lTableMul[i] ~= 0 then
            local wViewChairId = self:SwitchViewChairID(i - 1)
            self._gameView:gameAddScore(wViewChairId, lTableMul[i],false)
        end
    end
    self.wBankerUser = cmd_table.wBankerUser
    local lRoomStorageStart = cmd_table.lRoomStorageStart
    local lRoomStorageCurrent = cmd_table.lRoomStorageCurrent

    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        local tableID = self._gameFrame:GetTableID()
        local userItem = self._gameFrame:getTableUserItem(tableID,i-1)
        if nil ~= userItem then
            self._gameView:OnUpdateUser(wViewChairId, userItem)     
        end
    end

    for i = 1, cmd.GAME_PLAYER do
        self.cbCardData[i] = {}
        for j = 1, #cmd_table.cbHandCardData[1] do
            self.cbCardData[i][j] = cmd_table.cbHandCardData[i][j]
        end
    end
   
    local bOxCard = {}
    local bOpenCardStatus = {}
    for i = 1, cmd.GAME_PLAYER do
        bOxCard[i] = cmd_table.bOxCard[1][i]
        bOpenCardStatus[i] = cmd_table.bOpenCardStatus[1][i]
        local wViewChairId = self:SwitchViewChairID(i - 1)
        if self.cbPlayStatus[i] == 1 then
            if true == bOpenCardStatus[i]  then
                self._gameView:onButtonConfirm(wViewChairId)
                self._gameView:setOpenCardVisible(wViewChairId, true)
            end
            if not bOpenCardStatus[i] and cmd.MY_VIEWID == wViewChairId then 
                --出现计分器
                self._gameView:setCombineCard(self.cbCardData[i])
                self._gameView.gOpenCardSelf:setVisible(true)
                self._gameView:showCalculate(true,true)
                self._gameView:showBtn(true) 
            end
        end
    end

    local lTurnScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lTurnScore[i] = cmd_table.lTurnScore[1][i]
    end
    local lCollectScore = {}
    for i = 1, cmd.GAME_PLAYER do
        lCollectScore[i] =  cmd_table.lCollectScore[i]
    end

    local MaxScore ={}
    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        local Score = lTurnScore[i]
        MaxScore[wViewChairId] = math.abs(Score)
    end

    self._gameView:setGoldNum()

    --显示牌并开自己的牌
    for i = 1, cmd.GAME_PLAYER do
        if self.cbPlayStatus[i] == 1 then
            local wViewChairId = self:SwitchViewChairID(i - 1)
            for j = 1, 5 do
                local card = self._gameView.nodeCard[wViewChairId][j]
                card:setVisible(true)
                if wViewChairId == cmd.MY_VIEWID then          --是自己则打开牌
                    local value = GameLogic:getCardValue(self.cbCardData[i][j])
                    local color = GameLogic:getCardColor(self.cbCardData[i][j])
                    self._gameView:setCardTextureRect(wViewChairId, j, value, color)
                end
            end
        end
    end
    self._gameView:setCallMultiple(self:SwitchViewChairID(self.wBankerUser), cmd_table.cbCurrBankerTimes)
    self._gameView:setBankerUser(self:SwitchViewChairID(self.wBankerUser),self.cbDynamicJoin)
    self._gameView:setBankerMultiple(self:SwitchViewChairID(self.wBankerUser))

    self:KillGameClock()
    self._gameView:stopHeadClock()
    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        if self.cbPlayStatus[i] == 1 then
            self._gameView:setHeadClock(wViewChairId,cmd_table.cbTimeLeave)
            self:SetGameClock(self.wBankerUser, cmd.IDI_TIME_OPEN_CARD, cmd_table.cbTimeLeave)
        end
    end
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub,dataBuffer)
	if sub == cmd.SUB_S_CALL_BANKER then           --叫庄开始,与叫庄多少
--        self.m_cbGameStatus = cmd.GS_TK_CALL
		self:onSubCallBanker(dataBuffer)  
    elseif sub == cmd.SUB_S_CALL_BANKERINFO then   -- SUB_S_BEGIN_OPEN
        self:onSubCallBankerInfo(dataBuffer)              --
	elseif sub == cmd.SUB_S_GAME_START then        --游戏开始
        self.m_cbGameStatus = cmd.GS_TK_SCORE 
		self:onSubGameStart(dataBuffer)
	elseif sub == cmd.SUB_S_ADD_SCORE then         --加注结果
--        self.m_cbGameStatus = cmd.GS_TK_SCORE
		self:onSubAddScore(dataBuffer)
	elseif sub == cmd.SUB_S_SEND_CARD then         --发牌消息
--        self.m_cbGameStatus = cmd.GS_TK_PLAYING
		self:onSubSendCard(dataBuffer)
	elseif sub == cmd.SUB_S_OPEN_CARD then         --用户摊牌
        self.m_cbGameStatus = cmd.GS_TK_PLAYING
		self:onSubOpenCard(dataBuffer)
	elseif sub == cmd.SUB_S_PLAYER_EXIT then       --用户强退
        self.m_cbGameStatus = cmd.GS_TK_PLAYING
		self:onSubPlayerExit(dataBuffer)
	elseif sub == cmd.SUB_S_GAME_END then          --游戏结束
        self.m_cbGameStatus = cmd.GS_TK_FREE
		self:onSubGameEnd(dataBuffer)
    elseif sub == cmd.SUB_S_RECORD then            --游戏记录
        self:onSubGameRecord(dataBuffer)
	else
        print("unknow gamemessage sub is"..sub)
        --error("unknow gamemessage sub")
	end
end

--用户叫庄
function GameLayer:onSubCallBanker(dataBuffer)
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_CallBanker, dataBuffer)
    local wCallBanker = cmd_table.wCallBanker
    local viewId = self:SwitchViewChairID(wCallBanker)
    
    if cmd_table.bFirstTimes then
        return
    end

    if viewId == cmd.MY_VIEWID then
       self._gameView:onCallBanker(false)
    end
    
    self._gameView:setCallMultiple(viewId, cmd_table.cbBankerTimes)
    -- self._gameView:gameCallBanker(viewId,cmd_table.bFirstTimes)
    self._gameView:stopHeadClock(viewId)

--    if bFirstTimes == false then
--        self._gameView:stopHeadClock()
--    end

    for i = 1, cmd.GAME_PLAYER do
        --游戏状态
        self.cbPlayStatus[i] = cmd_table.cbPlayStatus[1][i]
    end

    if self.cbDynamicJoin == 0 then 
        self:KillGameClock()
        self:SetGameClock(cmd.MY_VIEWID, cmd.IDI_CALL_BANKER, cmd.TIME_USER_CALL_BANKER) 
--        for i = 1, cmd.GAME_PLAYER do
--            local wViewChairId = self:SwitchViewChairID(i - 1)
--            if self.cbPlayStatus[i] == 1 then
--                self._gameView:setHeadClock(wViewChairId,cmd.TIME_USER_CALL_BANKER)
--            end
--        end   
    end
end

function GameLayer:onSubCallBankerInfo(dataBuffer)
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_CallBankerInfo, dataBuffer)
    self.cbCardData  = {} 

     --叫庄状态
    local cbCallBankerStatus = {}
    for i = 1, cmd.GAME_PLAYER do
        cbCallBankerStatus[i] = cmd_table.cbCallBankerStatus[1][i]
    end

    --叫庄倍数
    local cbCallBankerTimes = {}
    for i = 1, cmd.GAME_PLAYER do
        cbCallBankerTimes[i] = cmd_table.cbCallBankerTimes[1][i]
    end

    for i=1,cmd.GAME_PLAYER do 
        if 1 == cbCallBankerStatus[i] then
           local wViewChairId = self:SwitchViewChairID(i - 1)
           if wViewChairId == cmd.MY_VIEWID then 
               self._gameView:showCallBankerMul(0)
           end
           --显示倍数
           self._gameView:setCallMultiple(wViewChairId,cbCallBankerTimes[i])
        end
    end

end

--游戏开始
function GameLayer:onSubGameStart(dataBuffer)
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_GameStart, dataBuffer);
    self._gameView:playEffect("gameStart.mp3")
    --self._gameView:setTurnMaxMulToScore()
    self.wBankerUser = cmd_table.wBankerUser
    self._gameView:setCallMultiple(self:SwitchViewChairID(cmd_table.wCallUser), cmd_table.bCallTimes) -- 最后一个的叫庄信息被合并在GameStart里，囧

    local bankViewId = self:SwitchViewChairID(self.wBankerUser)
    self._gameView:setCallMultiple(bankViewId, cmd_table.bBankerTimes) -- 再设置一次，避免漏了最重要的庄倍数

    --显示庄家标识
    for i = 1, #self._gameView.btMul do
		self._gameView.btMul[i]:setVisible(false)
	end
    self._gameView:onCallBanker(isShow)
    self._gameView:setBankerUser(bankViewId,self.cbDynamicJoin)
    --只显示庄家倍数
    self._gameView:setBankerMultiple(bankViewId)

    --庄家等待下注Tips
    for i=1,cmd.GAME_PLAYER do
       if 1 == self.cbPlayStatus[i]  then
           local viewId = self:SwitchViewChairID(i-1)
           self._gameView:hiddenMulBet(viewId,false)
           if (viewId ~= cmd.MY_VIEWID) then 
                if i-1 ~= self.wBankerUser  then
                    local bNormal 
                    if self.m_tabPrivateRoomConfig.sendCardType == cmd.SENDCARDTYPE_CONFIG.ST_BETFIRST then
                        bNormal = true
                    elseif self.m_tabPrivateRoomConfig.sendCardType == cmd.SENDCARDTYPE_CONFIG.ST_SENDFOUR then
                        bNormal = false  
                    end
                    self._gameView:setBetsVisible(viewId,true)
                end
           else
                if i-1 ~= self.wBankerUser then
                    self._gameView.gBetsSelf:setVisible(true)
                end
           end
       end
    end

    if self:SwitchViewChairID(self.wBankerUser) ~=  cmd.MY_VIEWID then
        self._gameView:setScoreJetton()
        self._gameView:showChipBtn(self:SwitchViewChairID(self.wBankerUser))
    end
    
    self._gameView:resetEffect()
    self._gameView:stopAllClock() 
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
end

--用户下注
function GameLayer:onSubAddScore(dataBuffer)
    print("用户下注")

    self.bAddScore = true
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_AddScore, dataBuffer);
    --dump(cmd_table)
    local wAddScoreUser = cmd_table.wAddScoreUser
    local lAddMulCount = cmd_table.lAddMulCount

    local userViewId = self:SwitchViewChairID(wAddScoreUser)
    self._gameView:gameAddScore(userViewId, lAddMulCount,true)
    self._gameView:runChipAnimate(self._gameView:getGoldNum(lAddMulCount,userViewId),userViewId)
    self._gameView:stopHeadClock(userViewId)
    self._gameView:playEffect("ADD_SCORE.WAV")
end

--发牌消息
function GameLayer:onSubSendCard(dataBuffer)
    print("用户发牌")
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_SendCard, dataBuffer);
    local eSendType = cmd_table.eSendType 
    for i = 1, cmd.GAME_PLAYER do
        self.cbCardData[i] = {}
        for j = 1, 5 do
            self.cbCardData[i][j] = cmd_table.cbCardData[i][j]
        end

        if self:SwitchViewChairID(i-1) == cmd.MY_VIEWID then  --原始数据
            self._gameView:setCombineCard(self.cbCardData[i])
--            self._gameView:setSpecialInfo(cmd_table.bSpecialCard[1][i],cmd_table.cbOriginalCardType[1][i])
        end
    end
    
    local sendCount
    if eSendType == 0 then
        self._gameView.bCanMoveCard = false
        --self:OnResetGameEngine() -- 
        -- 1.SUB_S_SEND_CARD
        -- 2.SUB_S_CALL_BANKER(FirstTime=true)
        -- 3.SUB_S_CALL_BANKERINFO
        -- 4.SUB_S_GAME_START
        -- 奇葩的流程,囧
        --前四张牌
        local tableId = self._gameFrame:GetTableID()
        for i = 1, cmd.GAME_PLAYER do
            --self.cbPlayStatus[i] = cmd_table.cbPlayStatus[1][i]
            self.cbPlayStatus[i] = 0
            local userItem = self._gameFrame:getTableUserItem(tableId, i-1)
            if nil ~= userItem then
                if userItem.cbUserStatus ~= yl.US_OFFLINE then
                    self.cbPlayStatus[i] = 1
                end 
            end
        end
        sendCount = 4
        self.m_cbGameStatus = cmd.GS_TK_CALL
        local cmddata = CCmd_Data:create()
        self:SendData(cmd.SUB_C_SEND_CARD_FINISH,cmddata)
        -- 刷新房卡
        if PriRoom and GlobalUserItem.bPrivateRoom then
            if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
                PriRoom:getInstance().m_tabPriData.dwPlayCount = PriRoom:getInstance().m_tabPriData.dwPlayCount + 1
                self._gameView._priView:onRefreshInfo()
            end
        end
    else
        --最后一张牌
        sendCount = 1
        self.m_cbGameStatus = cmd.GS_TK_PLAYING
        self._gameView.bCanMoveCard = self.cbPlayStatus[self:GetMeChairID()+1]==1
    end
    
    
    --打开自己的牌
    --dump(self._gameView.nodeCard[cmd.MY_VIEWID])

    self:KillGameClock()
    if eSendType == 0 then
         for i = 1, cmd.GAME_PLAYER do
            local wViewChairId = self:SwitchViewChairID(i - 1)
            if self.cbPlayStatus[i] == 1 then
                self._gameView:setCallingBankerStatus(true,wViewChairId)
            end
        end  
        self._gameView:onCallBanker(true)
        self._gameView:showCallBankerMul()
        self:KillGameClock() 
        self:SetGameClock(self:GetMeChairID(), cmd.IDI_CALL_BANKER, cmd.TIME_USER_CALL_BANKER)
        for i = 1, cmd.GAME_PLAYER do
            local wViewChairId = self:SwitchViewChairID(i - 1)
            if self.cbPlayStatus[i] == 1 then
                self._gameView:setHeadClock(wViewChairId,cmd.TIME_USER_CALL_BANKER)
            end
        end   
    elseif eSendType == 1 then
        for i = 1, cmd.MAX_CARDCOUNT do
            local index = self:GetMeChairID() + 1
            local data = self.cbCardData[index][i]
            local value = GameLogic:getCardValue(data)
            local color = GameLogic:getCardColor(data)
            local card = self._gameView.nodeCard[cmd.MY_VIEWID][i]
            self._gameView:setCardTextureRect(cmd.MY_VIEWID, i, value, color)
        end
        self._gameView:gameSendCard(self:SwitchViewChairID(self.wBankerUser),5) 
        
        if self:isPlayerPlaying(cmd.MY_VIEWID) then
            --出现计分器
            self._gameView.gOpenCardSelf:setVisible(true)
            self._gameView:showCalculate(true,true)
        end
    end
    
end

--用户摊牌
function GameLayer:onSubOpenCard(dataBuffer)
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_Open_Card, dataBuffer);
    local wPlayerID = cmd_table.wOpenChairID
    local bOpen = cmd_table.bOpenCard
    local wViewChairId = self:SwitchViewChairID(wPlayerID)
    self._gameView:stopHeadClock(wViewChairId)
    if wViewChairId == cmd.MY_VIEWID then
        self._gameView:onButtonConfirm(wViewChairId)
        self:openCard(wPlayerID)
    end
    self._gameView:stopCardAni(wViewChairId)
    self._gameView:setOpenCardVisible(wViewChairId,true)

    self._gameView:playEffect("SEND_CARD.wav")
end

--用户强退
function GameLayer:onSubPlayerExit(dataBuffer)
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_PlayerExit, dataBuffer);
    --dump(cmd_table)
    local wPlayerID = cmd_table.wPlayerID
    local wViewChairId = self:SwitchViewChairID(wPlayerID)
    self.cbPlayStatus[wPlayerID + 1] = 0
    self._gameView.bCanMoveCard = false
    self._gameView.nodePlayer[wViewChairId]:setVisible(false)
    self._gameView.spriteCalculate:setVisible(false)
    self._gameView.labCardType:setVisible(false)
    self._gameView:setOpenCardVisible(wViewChairId, false)
end

--游戏结束
function GameLayer:onSubGameEnd(dataBuffer)
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_GameEnd, dataBuffer);
    dump(cmd_table)
    self.m_bStartGame = false
    self.cbDynamicJoin = 0

     --牌值
    for i = 1, cmd.GAME_PLAYER do
        self.cbCardData[i] = {}
        for j = 1, cmd.MAX_CARDCOUNT do
            self.cbCardData[i][j] = cmd_table.cbCardData[i][j]
        end
    end

    local lGameTax = {}
    for i = 1, cmd.GAME_PLAYER do
        lGameTax[i] = cmd_table.lGameTax[1][i]
    end

    self.lCardType = {0,0,0,0,0}
    local loseScore = {0,0,0,0,0}
    for i = 1, cmd.GAME_PLAYER do
        self.lGameEndScore[i] = cmd_table.lGameScore[1][i]
        if self.cbPlayStatus[i] == 1 then
            local wViewChairId = self:SwitchViewChairID(i - 1)
            loseScore[wViewChairId] = self.lGameEndScore[i]
            self.lCardType[i] = cmd_table.cbOxCardType[1][i]
        end
    end
    self._gameView:setGoldNum()
    local cbDelayOverGame = cmd_table.cbDelayOverGame
    --开牌动画
    for i = 1, cmd.GAME_PLAYER do
        local viewid = self:SwitchViewChairID(i - 1)
            if (self.cbCardData and #self.cbCardData>0) then
                if self.cbCardData[i][1] > 0 then
                    self._gameView:stopCardAni(viewid)
                    self:openCard(i-1, true)
                end
            end
    end

    local lCardType = clone(self.lCardType)
    self._gameView:gameEnd(self.lGameEndScore,lCardType,self.cbPlayStatus)
    self._gameView:runOtherGoldAnimate(loseScore)

    self._gameView:stopHeadClock()
    self:KillGameClock()
    -- 私人房无倒计时
    if not GlobalUserItem.bPrivateRoom then
        -- 设置倒计时
        if self.cbDynamicJoin == 0 then 
            self:SetGameClock(self:GetMeChairID(), cmd.IDI_START_GAME, cmd.TIME_USER_START_GAME)
            self._gameView:setHeadClock(cmd.MY_VIEWID,cmd.TIME_USER_START_GAME)
        end
    end

   
    local callfunc = function( )
        self._gameView:onRestart()
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(4),cc.CallFunc:create(callfunc)))  
end

--游戏记录
function GameLayer:onSubGameRecord(dataBuffer)
    --print("游戏记录")
    local cmd_data = ExternalFun.read_netdata(cmd.CMD_S_RECORD, dataBuffer)
     
    self.m_userRecord.wincount = {}
    self.m_userRecord.losecount = {}
    self.m_userRecord.totalcount = cmd_data.nCount
    for i=1,cmd.GAME_PLAYER do
        self.m_userRecord.wincount[i] = cmd_data.lUserWinCount[1][i]
        self.m_userRecord.losecount[i] = cmd_data.lUserLostCount[1][i]
    end
    self.isPriOver = true
    --self._gameView.btStart:setVisible(false)
    --dump(self.m_userRecord,"约战记录")
end
--用户状态
--function GameLayer:onEventUserStatus(useritem,newstatus,oldstatus)
--    if newstatus.cbUserStatus == yl.US_FREE or newstatus.cbUserStatus == yl.US_NULL then
--        if (oldstatus.wTableID ~= self:GetMeUserItem().wTableID) then
--            return
--        end
--        if yl.INVALID_CHAIR ==  useritem.wChairID then
--            if self.isPriOver == true then
--                return
--            end

--            for i=1, cmd.GAME_PLAYER do
--                if self.m_tabUserItem[i] and self.m_tabUserItem[i].dwUserID == useritem.dwUserID then
--                    local wViewChairId = self:SwitchViewChairID(i-1)
--                    self._gameView:OnUpdateUserExit(wViewChairId)
--                    self._gameView:setReadyVisible(wViewChairId, false)
--                    if not (PriRoom and GlobalUserItem.bPrivateRoom) then  
--                       self.m_tabUserItem[i] = nil
--                    end
--                end
--            end
--        else
--            local wViewChairId = self:SwitchViewChairID(useritem.wChairID)
--            self._gameView:setReadyVisible(wViewChairId, false)
--            self._gameView:OnUpdateUserExit(wViewChairId)
--            if not (PriRoom and GlobalUserItem.bPrivateRoom) then  
--                 self.m_tabUserItem[useritem.wChairID+1] = nil
--            end
--        end
--    else
--        --print("改变状态")
--        if (newstatus.wTableID ~= self:GetMeUserItem().wTableID) then
--            return
--        end
--        self.m_tabUserItem[useritem.wChairID+1] = clone(useritem)
--        local viewid = self:SwitchViewChairID(useritem.wChairID)
--        --刷新用户信息
--        self._gameView:OnUpdateUser(viewid,useritem)
--    end    
--end

--用户进入
--function GameLayer:onEventUserEnter(tableid,chairid,useritem)

    --print("the table id is ================>"..tableid.." chairid==>"..chairid)

--  --刷新用户信息
--    if useritem == self:GetMeUserItem() or tableid ~= self:GetMeUserItem().wTableID then
--        return
--    end

--    self.m_tabUserItem[useritem.wChairID+1] = clone(useritem)

--    local wViewChairId = self:SwitchViewChairID(chairid)
--    --print("wViewChairId",wViewChairId)
--    self._gameView:OnUpdateUser(wViewChairId, useritem)
--    if useritem.cbUserStatus == yl.US_READY then
--        self._gameView:setReadyVisible(wViewChairId, true)
--    end

--    -- 刷新房卡
--    if PriRoom and GlobalUserItem.bPrivateRoom then
--        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
----            self._gameView._priView:onRefreshInfo()
--        end
--    end
--end

------------------------------------------------------------------------

------------------------------------------------------------------------
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
       
        self:KillGameClock()
        self._gameView:stopHeadClock(wViewChairId)
        self._gameView:onRestart()
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

function GameLayer:sendCardFinish()
    if self.cbDynamicJoin == 1 then 
        return
    end 

    self:KillGameClock()
    self:SetGameClock(self:GetMeChairID(), cmd.IDI_TIME_OPEN_CARD, cmd.TIME_USER_OPEN_CARD)
    self._gameView:stopHeadClock(viewId)
    local bankerViewId = self:SwitchViewChairID(self.wBankerUser) 
    for i = 1, cmd.GAME_PLAYER do
        local wViewChairId = self:SwitchViewChairID(i - 1)
        if self.cbPlayStatus[i] == 1 then
            self._gameView:setHeadClock(wViewChairId,cmd.TIME_USER_OPEN_CARD)
        end
    end  
end

--开单张牌
function GameLayer:openOneCard(viewid,index,bEnd)--, bEnded)
    local chairId = self:SwitchChairID(viewid)

    if self.cbCardData[chairId][index] == 0 then
       -- print("the viewid is ======",viewid)
        --print("the chairid is ========",chairId)
        return false
    end

    local data = self.cbCardData[chairId][index]
    --dump(self.cbCardData, "poker data ====  ", 6)
    local value = GameLogic:getCardValue(data)
    local color = GameLogic:getCardColor(data)
    local card = self._gameView.nodeCard[viewid][index]
    self._gameView:setCardTextureRect(viewid, index, value, color)

    if bEnd and (index == cmd.MAX_CARDCOUNT) then
        self._gameView:resetCardByType(clone(self.cbCardData),clone(self.lCardType))
    end

    return true
end

function GameLayer:openCard(chairId, bEnded)
    --排列cbCardData
    local index = chairId + 1
    if self.cbCardData[index] == nil then
        --print("出错")
        return false
    end
    GameLogic:getOxCard(self.cbCardData[index])
    local cbOx = GameLogic:getCardType(self.cbCardData[index])

    local viewId = self:SwitchViewChairID(chairId)
    for i = 1,cmd.MAX_CARDCOUNT  do
        local data = self.cbCardData[index][i]
        local value = GameLogic:getCardValue(data)
        local color = GameLogic:getCardColor(data)
        local card = self._gameView.nodeCard[viewId][i]
        self._gameView:setCardTextureRect(viewId, i, value, color)
    end

    self._gameView:gameOpenCard(viewId, cbOx)--, bEnded)

    return true
end

function GameLayer:getMeCardLogicValue(num)
    local index = self:GetMeChairID() + 1
    local value = GameLogic:getCardLogicValue(self.cbCardData[index][num])
    local str = string.format("index:%d, num:%d, self.cbCardData[index][num]:%d, return:%d", index, num, self.cbCardData[index][num], value)
    --print(str)
    return value
end

function GameLayer:getMeCardValue( index )
    local chairID = self:GetMeChairID() + 1
    if index == nil then
       return self.cbCardData[chairID]
    end
   
    local value = self.cbCardData[chairID][index]
    return value 
end

function GameLayer:getOxCard(cbCardData)
    return GameLogic:getOxCard(cbCardData)
end

function GameLayer:getPrivateRoomConfig()
    return self.m_tabPrivateRoomConfig
end
--约战记录
function GameLayer:getDetailScore()
    return self.m_userRecord
end

--********************   发送消息     *********************--
--叫庄
function GameLayer:onBanker(cbBanker,mul)

    local dataBuffer = CCmd_Data:create(2)
    dataBuffer:setcmdinfo(GameServer_CMD.MDM_GF_GAME,cmd.SUB_C_CALL_BANKER)
    dataBuffer:pushbyte(cbBanker)
    dataBuffer:pushbyte(mul)
    return self._gameFrame:sendSocketData(dataBuffer)
end

function GameLayer:onAddScore(lMul)
    --print("牛牛 发送下注 lScore",lScore)
    if lMul == nil then
        error("send lMul is nil !")
    end
    if self:SwitchViewChairID(self.wBankerUser) == cmd.MY_VIEWID then
        --print("牛牛: 自己庄家不下注")
        return
    end
    local dataBuffer = CCmd_Data:create(8)
    dataBuffer:setcmdinfo(GameServer_CMD.MDM_GF_GAME, cmd.SUB_C_ADD_SCORE)
    dataBuffer:pushscore(lMul)
    return self._gameFrame:sendSocketData(dataBuffer)
end

--发送开牌消息
function GameLayer:onOpenCard(data)

    dump(data, "the combine card is =====")
    local dataBuffer = ExternalFun.create_netdata(cmd.CMD_C_OxCard)
    dataBuffer:setcmdinfo(GameServer_CMD.MDM_GF_GAME, cmd.SUB_C_OPEN_CARD)
    local ox_type = GameLogic:getCardType(data)
    if ox_type > 0 then
        ox_type = 1
    end
    dataBuffer:pushbyte(ox_type)
    for i=1,#data do
       dataBuffer:pushbyte(data[i])
    end

    return self._gameFrame:sendSocketData(dataBuffer)
end

function GameLayer:getChairCount()
    return table.nums(self.m_tabUserItem)
end

--获取用户数据
function GameLayer:getUserInfoByChairID(wchairid)
    for k,v in pairs(self.m_tabUserItem) do
        if v.wChairID == wchairid then
            return v
        end
    end
    return nil
end

--获取用户数据
function GameLayer:getUserInfoByUserID(dwUserID)
    for k,v in pairs(self.m_tabUserItem) do
        if v.dwUserID == dwUserID then
            return v
        end
    end
    return nil
end

--换位
function GameLayer:onChangeDesk()
    self._gameFrame:QueryChangeDesk()
    self._gameView:onResetView()
end

return GameLayer