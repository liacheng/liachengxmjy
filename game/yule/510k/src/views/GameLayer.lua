local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.510k.src"
local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd = appdf.req(module_pre .. ".models.CMD_Game")
local game_cmd = appdf.CLIENT_SRC..".plaza.models.CMD_GameServer"
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local ResultLayer = appdf.req(module_pre .. ".views.layer.ResultLayer")


function GameLayer.registerTouchEvent(node, bSwallow, FixedPriority)
    local function onTouchBegan( touch, event )
        if nil == node.onTouchBegan then
            return false
        end
        return node:onTouchBegan(touch, event)
    end

    local function onTouchMoved(touch, event)
        if nil ~= node.onTouchMoved then
            node:onTouchMoved(touch, event)
        end
    end

    local function onTouchEnded( touch, event )
        if nil ~= node.onTouchEnded then
            node:onTouchEnded(touch, event)
        end       
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(bSwallow)
    node._listener = listener
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener, FixedPriority)
end



function GameLayer:ctor( frameEngine,scene )
    GameLayer.super.ctor(self, frameEngine, scene)
    self:OnInitGameEngine()
    self._roomRule = self._gameFrame._dwServerRule
    self.m_bLeaveGame = false

    --约战模式
    self.m_bIsYueZhan = false
    --规则,A大,2大
    self.m_b2Biggest = GameLogic.m_b2Biggest
    --规则,4,6王
    self.m_ModelWang = GameLogic.m_ModelWang
    -- 一轮结束
    self.m_bRoundOver = false
    -- 自己是否是地主
    self.m_bIsMyBanker = false
    -- 提示牌数组
    self.m_tabPromptList = {}
    -- 当前出牌,就是上家的出牌
    self.m_tabCurrentCards = {}
    -- 提示牌
    self.m_tabPromptCards = {}
    -- 比牌结果
    self.m_bLastCompareRes = false
    -- 上轮出牌视图
    self.m_nLastOutViewId = cmd.INVALID_VIEWID
    -- 上轮出牌
    self.m_tabLastCards = {}

    self.m_lTurnScore = {}

    self.lCollectScore = {}
    -- 是否叫分状态进入
    self.m_bCallStateEnter = false

    self.m_gameScenePlay = {}

    self.m_wXuanZhanUser = 0

    self.m_wBankerUser = 0          --庄家
    self.m_wCurrentUser = 0         --当前用户
    self.m_wPartner = 0             --伙伴
    self.m_cbCardDataPartner = 0    --伙伴牌

    self.m_cbAskStatus = {}
    self.m_wNoDeclareCount = 0      --没宣战玩家数
    self.m_wNoAskFriendCount = 0    --没宣战玩家数
    self.m_addTimes = 1             --个人翻倍

    self.m_tab_cbFriendFlag = {} 
    self.m_tab_cbAddTimesFlag = {}
    self.m_cbFriendFlag = 0
    self.m_wFriend = {}
    self.m_bCanTrustee = false

    self.m_wLastOutCardUser = cmd.INVALID_CHAIRID
    self.m_wOutCardUser = cmd.INVALID_CHAIRID
    self.m_cbTurnCardCount = {}
    self.m_lCellScore = 1

    --约战的各种分数
    self.m_cbCaiShuPlayerVec = {}       --彩数
    self.m_lBaseScore = {}              --基本得分
    self.m_lRoundScore = {}             --一局总得分
    self.m_wWinOrder = {}               --名次信息
end

--获取gamekind
function GameLayer:getGameKind()
    return cmd.KIND_ID
end

--创建场景
function GameLayer:CreateView()
    return GameViewLayer:create(self)
        :addTo(self)
end

function GameLayer:getParentNode( )
    return self._scene
end

function GameLayer:getFrame( )
    return self._gameFrame
end

function GameLayer:logData(msg)
    if nil ~= self._scene.logData then
        self._scene:logData(msg)
    end
end

function GameLayer:reSetData()
    self.m_bIsMyBanker = false
    self.m_tabPromptList = {}
    self.m_tabCurrentCards = {}
    self.m_tabPromptCards = {}
    self.m_bLastCompareRes = false
    self.m_nLastOutViewId = cmd.INVALID_VIEWID
    self.m_tabLastCards = {}    
    self.m_cbCaiShuPlayerVec = {}
    self.m_lBaseScore = {}
    self.m_lRoundScore = {}
    self.m_wWinOrder = {}
end

---------------------------------------------------------------------------------------
------继承函数
function GameLayer:onEnterTransitionFinish()
    GameLayer.super.onEnterTransitionFinish(self)
end

function  GameLayer:onExit()
    self:KillGameClock()
    self:dismissPopWait()
    GameLayer.super.onExit(self)
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

--离开房间
function GameLayer:onExitRoom()
    self._scene:onKeyBack()
end

-- 计时器响应
function GameLayer:OnEventGameClockInfo(chair,time,clockId)
    if nil ~= self._gameView and nil ~= self._gameView.updateClock then
        self._gameView:updateClock(clockId, time)
    end
end

-- 设置计时器
function GameLayer:SetGameClock(chair,id,time)
    GameLayer.super.SetGameClock(self,chair,id,time)
end

function GameLayer:onGetSitUserNum()
    return table.nums(self._gameView.m_tabUserHead)
end

function GameLayer:getUserInfoByChairID( chairid )
    local viewId = self:SwitchViewChairID(chairid)
    return self._gameView.m_tabUserItem[viewId]
end

function GameLayer:OnResetGameEngine()
    self:reSetData() 
    GameLayer.super.OnResetGameEngine(self)
end

-- 刷新提示列表
-- @param[cards]        出牌数据,上家的出牌
-- @param[handCards]    手牌数据
-- @param[outViewId]    已经出牌视图id
-- @param[curViewId]    当前视图id
function GameLayer:updatePromptList(cards, handCards, outViewId, curViewId)
    self.m_tabCurrentCards = cards
    self.m_tabPromptList = {}

    --result有三个元素,第一个是总共有多少种出法，第二个是个是每种出牌对应有多少张牌，第三个是具体的每种出牌
    local result = {}
    if outViewId == curViewId then
        self.m_tabCurrentCards = {}
        result = GameLogic:SearchOutCard(handCards, #handCards, {}, 0)
    else
        result = GameLogic:SearchOutCard(handCards, #handCards, cards, #cards)
    end

    --dump(result, "出牌提示", 6)    
    local resultCount = 0
    resultCount = result[1]
    --print("## 提示牌组 " .. resultCount)
    if resultCount > 0 then
        for i = resultCount, 1, -1 do
            local tmplist = {}
            local total = result[2][i]
            if total == nil then
                total = 0
            end
            local cards = result[3][i]
            for j = 1, total do
                local cbCardData = cards[j] or 0
                table.insert(tmplist, cbCardData)
            end
            if  total > 0 then
                table.insert(self.m_tabPromptList, tmplist)
            end
        end
    end
    local count = #self.m_tabPromptList
    self.m_tabPromptCards = self.m_tabPromptList[#self.m_tabPromptList] or {}
    self._gameView.m_promptIdx = 0
end

-- 扑克对比
-- @param[cards]        当前出牌
-- @param[outView]      出牌视图id
function GameLayer:compareWithLastCards( cards, outView)
    local bRes = false
    self.m_bLastCompareRes = false
    local outCount = #cards
    if outCount > 0 then
        if outView ~= self.m_nLastOutViewId then
            --返回true，表示cards数据大于m_tagLastCards数据
            self.m_bLastCompareRes = GameLogic:CompareCard(self.m_tabLastCards, #self.m_tabLastCards, cards, outCount)
            self.m_nLastOutViewId = outView
            bRes = self.m_bLastCompareRes
        end
        self.m_tabLastCards = cards
    end
    return bRes
end

------------------------------------------------------------------------------------------------------------
--网络处理
------------------------------------------------------------------------------------------------------------

-- 发送准备
function GameLayer:sendReady()
    self:KillGameClock()
    self._gameFrame:SendUserReady()
end

-- 发送叫分
function GameLayer:sendCallScore( score )
    self:KillGameClock()
    local cmddata = CCmd_Data:create(1)
    cmddata:pushbyte(score)
    self:SendData(cmd.SUB_C_CALL_SCORE,cmddata)
end

--是否宣战
function GameLayer:sendDelareWar(cbDelare)
    local cmddata = CCmd_Data:create(1)
    cmddata:pushbyte(cbDelare)
    self:SendData(cmd.SUB_C_XUAN_ZHAN,cmddata)
end

--
function GameLayer:sendAskFriend(cbAsk)
    local cmddata = CCmd_Data:create(1)
    cmddata:pushbyte(cbAsk)
    self:SendData(cmd.SUB_C_ASK_FRIEND,cmddata)
end

function GameLayer:sendAddTimes(cbAdd)
    local cmddata = CCmd_Data:create(1)
    cmddata:pushbyte(cbAdd)
    self:SendData(cmd.SUB_C_ADD_TIMES,cmddata)
end

-- 发送出牌
function GameLayer:sendOutCard(cards, bPass)
    self:KillGameClock()
    if bPass then
        local cmddata = CCmd_Data:create()
        self:SendData(cmd.SUB_C_PASS_CARD,cmddata)
    else
        local cardcount = #cards
        local cmddata = CCmd_Data:create(1 + cardcount)
        cmddata:pushbyte(cardcount)
        for i = 1, cardcount do
            cmddata:pushbyte(cards[i])
        end
        self:SendData(cmd.SUB_C_OUT_CARD,cmddata)
    end
end
--发送托管
function GameLayer:sendTrustees( cbTrustees )
    local cmddata = CCmd_Data:create(1)
    cmddata:pushbyte(cbTrustees)
    self:SendData(cmd.SUB_C_AUTOMATISM,cmddata)
end

-- 语音播放开始
function GameLayer:onUserVoiceStart( useritem, filepath )
    local viewid = self:SwitchViewChairID(useritem.wChairID)
    self._gameView.m_tabVoiceBox[viewid]:setVisible(true)
end

-- 语音播放结束
function GameLayer:onUserVoiceEnded( useritem, filepath )
    local viewid = self:SwitchViewChairID(useritem.wChairID)
    self._gameView.m_tabVoiceBox[viewid]:setVisible(false)
end

-- 场景信息
function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
    print("场景数据:" .. cbGameStatus)
    if self.m_bOnGame then
        return
    end
    self.m_bOnGame = true
    self._gameView:initHistoryScore()
    self.m_cbGameStatus = cbGameStatus
    if cbGameStatus == cmd.GAME_SCENE_FREE then                                  --空闲状态
        self:onEventGameSceneFree(dataBuffer)
    else --if cbGameStatus == cmd.GAME_SCENE_PLAY then                           --游戏状态
        self:onEventGameScenePlay(dataBuffer)
    end
    self:dismissPopWait()
    
end

function GameLayer:onEventGameMessage(sub,dataBuffer)
    if nil == self._gameView then
        return
    end
    print("onEventGameMessage",sub)
    if cmd.SUB_S_GAME_START == sub then                 --游戏开始
        self.m_cbGameStatus = cmd.GAME_SCENE_WAIT
        self:onSubGameStart(dataBuffer)
    elseif cmd.SUB_S_OUT_CARD == sub then               --用户出牌
        self.m_cbGameStatus = cmd.GAME_SCENE_PLAY
        self:onSubOutCard(dataBuffer)
    elseif cmd.SUB_S_PASS_CARD == sub then              --用户放弃
        self.m_cbGameStatus = cmd.GAME_SCENE_PLAY
        self:onSubPassCard(dataBuffer)
    elseif cmd.SUB_S_GAME_END == sub then               --游戏结束
        if PriRoom and GlobalUserItem.bPrivateRoom then
            self.m_cbGameStatus = cmd.GAME_SCENE_PLAY
        else
            self.m_cbGameStatus = cmd.GAME_SCENE_FREE
        end
        self:onSubGameEnd(dataBuffer)
    elseif cmd.SUB_S_AUTOMATISM == sub then             --用户托管
        self.m_cbGameStatus = cmd.GAME_SCENE_PLAY
        self:onSubTrustee(dataBuffer)
    end
end

-- 游戏开始
function GameLayer:onSubGameStart(dataBuffer)
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_GameStart, dataBuffer)
    print("--------------dataBuffer:getlen() ----------------" ,dataBuffer:getlen())
    dump(cmd_table, "onSubGameStart", 6)
    --[[
    cmd_table.myName = GlobalUserItem.tabAccountInfo.szNickName
    cmd_table.struct = "CMD_S_GameStart"
    local jsonStr = cjson.encode(cmd_table)
    LogAsset:getInstance():logData(jsonStr,true)
    --]]
    self.m_wCurrentUser = cmd_table.wCurrentUser
    self.m_wBankerUser = cmd_table.wHeadUser
    self.m_wPartner = cmd_table.wPartnerID 
    self.m_cbCardDataPartner = cmd_table.cbCardPartner    
    GameLogic.m_cbCardDataPartner =  cmd_table.cbCardPartner 


    self.m_bRoundOver = false
    self:reSetData()
    --游戏开始
    self._gameView:onGameStart()
    local cards = GameLogic:SortCardList(cmd_table.cbCardData[1], cmd.NORMAL_COUNT, 0)
    --发牌
    self._gameView:onGetGameCard(cmd.MY_VIEWID, cards, false, cc.CallFunc:create(function()
            if self.m_wCurrentUser == self._gameFrame:GetChairID() then
                self._gameView:onGameFirstOutCards()
            end
            self:KillGameClock()
            self:SetGameClock(cmd_table.wCurrentUser, cmd.TAG_COUNTDOWN_OUTCARD, cmd.COUNTDOWN_HANDOUTTIME)
            self._gameView:setTuoGuanBtn(true)
        end))
    --local curView = self:SwitchViewChairID(cmd_table.wCurrentUser)
    --local startView = self:SwitchViewChairID(cmd_table.wStartUser)   
    
    -- 刷新局数
    if PriRoom and GlobalUserItem.bPrivateRoom then
        local curcount = PriRoom:getInstance().m_tabPriData.dwPlayCount
        PriRoom:getInstance().m_tabPriData.dwPlayCount = PriRoom:getInstance().m_tabPriData.dwPlayCount + 1
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            self._gameView._priView:onRefreshInfo()
        end
    end
end

function GameLayer:SetFriendFlag(dataBuffer)
    
    self._gameView:SetFriendFlag(cmd.INVALID_VIEWID,0)

    if self.m_cbFriendFlag == cmd.FRIEDN_FLAG_NORMAL then --正常
        for i = 1, cmd.PLAYER_COUNT do
            if i == self:GetMeChairID() or i == self.m_wFriend [self:GetMeChairID() + 1] then
                self._gameView:SetFriendFlag(i - 1,5)
            else
                self._gameView:SetFriendFlag(i - 1,2)
            end
        end
    elseif self.m_cbFriendFlag == cmd.FRIEDN_FLAG_DECLAREWAR then --宣战
        for i = 1, cmd.PLAYER_COUNT do
            if i - 1 == self.m_wXuanZhanUser then
                self._gameView:SetFriendFlag(i - 1,4)
            else
                if self.m_wXuanZhanUser == self:GetMeChairID() then
                    self._gameView:SetFriendFlag(i - 1,2)
                else
                    self._gameView:SetFriendFlag(i - 1,5)
                end
            end
        end
    elseif self.m_cbFriendFlag == cmd.FRIEDN_FLAG_MINGDU then
         for i = 1, cmd.PLAYER_COUNT do
            if i -1 == self.m_wXuanZhanUser then
                self._gameView:SetFriendFlag(i - 1,1)
            else
                if self.m_wXuanZhanUser == self:GetMeChairID() then
                    self._gameView:SetFriendFlag(i - 1,2)
                else
                    self._gameView:SetFriendFlag(i - 1,5)
                end
            end
         end
    else
        for i = 1, cmd.PLAYER_COUNT do
            if i -1 ~= self:GetMeChairID() then
                self._gameView:SetFriendFlag(i - 1,3)
            end
        end
    end
end

-- 用户出牌
function GameLayer:onSubOutCard(dataBuffer)
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_OutCard, dataBuffer)
    print("--------------onSubOutCard:getlen() ----------------" ,dataBuffer:getlen())
    dump(cmd_table, "onSubOutCard", 6)
    local curView = self:SwitchViewChairID(cmd_table.wCurrentUser)
    local outView = self:SwitchViewChairID(cmd_table.wOutCardUser)
    self.m_wOutCardUser = cmd_table.wOutCardUser
    print("&& 出牌 " .. outView .. " current " .. curView)
    local outCard = cmd_table.cbCardData[1]
    local outCount = cmd_table.cbCardCount                                      --#outCard
    local carddata = GameLogic:SortCardList(outCard, outCount, 0)

    carddata = self:getValidCardsData(carddata)
    -- 扑克对比
    self:compareWithLastCards(carddata, outView)
    self:KillGameClock()
    -- 构造提示
    local handCards = self._gameView.m_tabNodeCards[cmd.MY_VIEWID]:getHandCards()
    if curView ~= cmd.INVALID_CHAIRID then
        self:SetGameClock(cmd_table.wCurrentUser, cmd.TAG_COUNTDOWN_OUTCARD, cmd.COUNTDOWN_OUTCARD)
        self:updatePromptList(carddata, handCards, outView, curView)
        -- 不出按钮
        self._gameView:onChangePassBtnState(true)
    end
    
    self._gameView:onGetOutCard(curView, outView, carddata)
    self.m_wLastOutCardUser = cmd_table.wOutCardUser

    -- 设置倒计时
    self._gameView:setOperateTipVisible(outView, false)
    if curView ~= cmd.INVALID_CHAIRID then
        self._gameView:setOperateTipVisible(curView, false)
    end
    --更新牌视图
    if outView ~= cmd.MY_VIEWID then
        local m_nodeCard = self._gameView.m_tabNodeCards[outView]
        local currentCount = m_nodeCard:getCardsCount()
        local lastCount = m_nodeCard:getCardsCount()
        --currentCount = currentCount - outCount
        
        --m_nodeCard:setCardsCount(currentCount)
        if lastCount <= 2 and lastCount > 0 then
            self._gameView.m_tabAlertSp[outView]:setVisible(true)
        else
            self._gameView.m_tabAlertSp[outView]:setVisible(false)
        end

        self._gameView:updateCardsNodeLayout(outView, currentCount, true)
    end
    --更新彩数,和当前得分
    self.m_cbCaiShuPlayerVec =  cmd_table.cbCaiShu[1]
    self.m_wWinOrder = cmd_table.wWinOrder[1]
    for i = 1, cmd.PLAYER_COUNT do
        local viewId = self:SwitchViewChairID(i - 1)
        local head_bg = self._gameView.m_csbNode:getChildByName(string.format("head_bg_%d", viewId))
        local caiShuImg = head_bg:getChildByName("imgCaiShu")
        local caiShuImg = caiShuImg:getChildByName("textCaiShu")
        local caiShuScore = self:getCaiShuScore(i)
        caiShuImg:setString(string.format("%d", caiShuScore))
        
        local text_curScore = head_bg:getChildByName("text_curScore")
        --text_curScore:setString("当前得分:"..caiShuScore)       
        
        --名次信息
        if cmd_table.bIsShowWinOrder == true then
            self._gameView:setWinOrder(self.m_wWinOrder[i] - 1, i)   
        end
    end
    --是否显示伙伴
    if cmd_table.bIsShowPartner == true then
        self._gameView:showPartner()
    end
end

-- 用户放弃
function GameLayer:onSubPassCard(dataBuffer)
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_PassCard, dataBuffer)
    local curView = self:SwitchViewChairID(cmd_table.wCurrentUser)
    local passView = self:SwitchViewChairID(cmd_table.wPassCardUser)
    if self:IsValidViewID(curView) and self:IsValidViewID(passView) then
        print("&& pass " .. passView .. " current " ..  curView)
        if 1 == cmd_table.cbTurnOver then
            print("一轮结束")
            self:compareWithLastCards({}, curView)
            -- 构造提示
            local handCards = self._gameView.m_tabNodeCards[cmd.MY_VIEWID]:getHandCards()
            self:updatePromptList({}, handCards, curView, curView)

            -- 不出按钮
            self._gameView:onChangePassBtnState(false)
        end
        -- 不出牌
        self._gameView:onGetPassCard(cmd_table)

        self._gameView:onGetOutCard(curView, curView, {})

        -- 设置倒计时
        self:SetGameClock(cmd_table.wCurrentUser, cmd.TAG_COUNTDOWN_OUTCARD, cmd.COUNTDOWN_OUTCARD)
    else
        print("viewid invalid" .. curView .. " ## " .. passView)
    end

    self._gameView:setOperateTipVisible(passView, true)
    if curView ~= cmd.INVALID_CHAIRID then
        self._gameView:setOperateTipVisible(curView, false)
    end
end

-- 游戏结束
function GameLayer:onSubGameEnd(dataBuffer)
    self.m_wNoDeclareCount = 0
    self.m_wNoAskFriendCount = 0
    local cmd_table = {}
    if self.m_bIsYueZhan then
       cmd_table= ExternalFun.read_netdata(cmd.CMD_S_GameEndYueZhan, dataBuffer)   
    else
       cmd_table = ExternalFun.read_netdata(cmd.CMD_S_GameEnd, dataBuffer)
    end
    dump(cmd_table, "onSubGameEnd", 6)

    ----------设置约战各个分数的值---------------
    if self.m_bIsYueZhan == true then
        self.m_cbCaiShuPlayerVec = cmd_table.cbCaiShu[1]
        self.m_lBaseScore = cmd_table.lBaseScore[1]
        self.m_lRoundScore = cmd_table.lRoundScore[1]
    end

    --------------------游戏结算等等--------------------
    self._gameView:setTrusteeBtnEnable(false)
    self._gameView:setTuoGuanBtn(false)
    self._gameView:onGetGameConclude( cmd_table )
    self:KillGameClock()
    -- 私人房无倒计时
    if not GlobalUserItem.bPrivateRoom then
        -- 设置倒计时
        self:SetGameClock(self:GetMeChairID(), cmd.TAG_COUNTDOWN_READY, cmd.COUNTDOWN_READY)
    end

    self:reSetData()
end

--用户托管
function GameLayer:onSubTrustee( dataBuffer )
    
end

function GameLayer:onSubBaseScore( dataBuffer )
    
end

function GameLayer:onEventGameSceneFree( dataBuffer )
    local int64 = Integer64.new()
    print("--------------dataBuffer:getlen() ----------------" ,dataBuffer:getlen())
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_StatusFree, dataBuffer)
    dump(cmd_table, "scene free", 6)

    self.m_lCellScore = cmd_table.lCellScore
    -- 更新底分
    --self._gameView:onGetCellScore(cmd_table.lCellScore)
    -- 空闲消息
    self._gameView:onGetGameFree()

    --self._gameView:onGetGameCard(cmd.MY_VIEWID, cards, false)
    local empTyCard = GameLogic:emptyCardList(cmd.NORMAL_COUNT)

    -- 私人房无倒计时
    self:KillGameClock()
    if not GlobalUserItem.bPrivateRoom then
        -- 设置倒计时
        self:SetGameClock(self:GetMeChairID(), cmd.TAG_COUNTDOWN_READY, cmd.COUNTDOWN_READY)
    end  
    -- 刷新局数
    if PriRoom and GlobalUserItem.bPrivateRoom then
        local curcount = PriRoom:getInstance().m_tabPriData.dwPlayCount
        print("---- PriRoom curcount -----",curcount)
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            self._gameView._priView:onRefreshInfo()
        end
    end  
end


function GameLayer:onEventGameScenePlay( dataBuffer )
    local cmd_table = ExternalFun.read_netdata(cmd.CMD_S_StatusPlay, dataBuffer)
    print("--------------onEventGameScenePlay:getlen() ----------------" ,dataBuffer:getlen())
    self.m_gameScenePlay = cmd_table
    dump(cmd_table, "scene play", 6)

    self.m_lCellScore = cmd_table.lCellScore
    self.m_wBankerUser = cmd_table.wHeadUser
    self.m_wPartner = cmd_table.wPartnerID
    self.m_cbCardDataPartner = cmd_table.cbCardPartner
    self.m_wCurrentUser = self.m_gameScenePlay.wCurrentUser
    self.m_cbTurnCardCount = cmd_table.cbTurnCardCount
    self.m_wTurnWiner = cmd_table.wTurnWiner
    self.m_cbTurnCardData = cmd_table.cbTurnCardData[1]
    
    local myChairId = self._gameFrame:GetChairID()
    self._gameView.m_cardNum1:setString(string.format("%d", cmd_table.cbHandCardCount[1][myChairId + 1]))
    self._gameView.m_cardNum1:setVisible(true)
    self._gameView:updateRule()

    self.m_bRoundOver = false

    -- 用户手牌
    local countlist = cmd_table.cbHandCardCount[1]

    for i = 1, 4 do
        local chair = i - 1
        local cards = {}
        local count = countlist[i]
        local viewId = self:SwitchViewChairID(chair)
        if cmd.MY_VIEWID == viewId then
            local tmp = cmd_table.cbHandCardData[1]
            for j = 1, count do
                table.insert(cards, tmp[j])
            end
            cards = GameLogic:SortCardList(cards, count, 0)
        else
            cards = GameLogic:emptyCardList(count)
        end
        self._gameView:onGetGameCard(viewId, cards, true)
    end
    self.m_cbTurnCardData = self:getValidCardsData(self.m_cbTurnCardData)
    print("self.m_gameScenePlay.cbGameStatus",self.m_gameScenePlay.cbGameStatus)
    if self.m_gameScenePlay.cbGameStatus == cmd.GAME_SCENE_PLAY then
        self._gameView:setTuoGuanBtn(true)
        --显示好友
        local curView = self:SwitchViewChairID(self.m_wCurrentUser)
        local outView = self:SwitchViewChairID(cmd_table.wTurnWiner)

        local handCards = self._gameView.m_tabNodeCards[cmd.MY_VIEWID]:getHandCards()
        self:updatePromptList(self.m_cbTurnCardData, handCards, outView, cmd.MY_VIEWID)        
        if  self.m_wCurrentUser == myChairId then
            self._gameView:onGetOutCard(1, 1, self.m_cbTurnCardData)
            self._gameView:presentOutCardsBtns()
            self._gameView:onChangePassBtnState(self.m_cbTurnCardCount > 0)
            self._gameView.m_bt_outCard:setEnabled(false)
            self._gameView.m_bt_outCard:setOpacity(125)
            --搜索出牌
            if cmd_table.wTurnWiner == myChairId then
                local result = {}
                result = GameLogic:SearchOutCard(handCards, #handCards, {}, 0)
            else
                result = GameLogic:SearchOutCard(handCards, #handCards, self.m_cbTurnCardData, self.m_cbTurnCardCount)
            end
        end
        --个人拥有的牌
        self._gameView.m_cardNum1:setString(string.format("%d", cmd_table.cbHandCardCount[1][myChairId + 1]))
        self._gameView.m_cardNum1:setVisible(true)
        self._gameView:onGetOutCard(curView, outView, self.m_cbTurnCardData)
        --历史成绩
        print("--- 历史成绩 ---")
        for i = 1 ,cmd.PLAYER_COUNT do
            local viewId = self:SwitchViewChairID(i - 1)
        end
        self:SetGameClock(self.m_wCurrentUser, cmd.TAG_COUNTDOWN_OUTCARD, cmd.COUNTDOWN_OUTCARD)
    end

     --是否显示伙伴
    if cmd_table.bIsShowPartner == true then
        self._gameView:showPartner()
    end

    for i = 1 ,cmd.PLAYER_COUNT do
        local viewId = self:SwitchViewChairID(i - 1)
        local head_bg = self._gameView.m_csbNode:getChildByName(string.format("head_bg_%d", viewId))
        --显示庄家,改用庄家图
        if i - 1 == self.m_wBankerUser then
            local heart = head_bg:getChildByName("heart")
            heart:setVisible(false)
            self._gameView:showBankUser()
        end
        local caiShuScore = self:getCaiShuScore(i)
        local text_curScore = head_bg:getChildByName("text_curScore")
        --text_curScore:setString(string.format("当前得分:%d", caiShuScore))              --self._gameView.m_lGameScore[viewId])

        if viewId ~= cmd.MY_VIEWID then
            self._gameView:updateCardsNodeLayout(viewId, cmd_table.cbHandCardCount[1][i], true) 
        end
    end

    -- 刷新局数
    if PriRoom and GlobalUserItem.bPrivateRoom then
        local curcount = PriRoom:getInstance().m_tabPriData.dwPlayCount
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            self._gameView._priView:onRefreshInfo()
        end
    end
    self._gameView.m_cardNum1:setString(string.format("%d", cmd_table.cbHandCardCount[1][myChairId + 1]))
    self._gameView.m_cardNum1:setVisible(true)
end

--去0
function GameLayer:getValidCardsData(cardsData)
    local newCardsData = {}
    for i = 1, #cardsData do
        if 0 ~= cardsData[i] then
            table.insert(newCardsData, cardsData[i])
        end
    end
    return newCardsData
end

-- 文本聊天
function GameLayer:onUserChat(chatdata, chairid)
    local viewid = self:SwitchViewChairID(chairid)    
    if self:IsValidViewID(viewid) then
        self._gameView:onUserChat(chatdata, viewid)
    end
end

-- 表情聊天
function GameLayer:onUserExpression(chatdata, chairid)
    local viewid = self:SwitchViewChairID(chairid)
    if self:IsValidViewID(viewid) then
        self._gameView:onUserExpression(chatdata, viewid)
    end
end

-- 语音聊天
function GameLayer:onUserVoice( useritem, filepath)
    local viewid = self:SwitchViewChairID(useritem.wChairID)
    if self:IsValidViewID(viewid) then
        self._gameView:onUserVoice(filepath, viewid)
        return true
    end
    return false
end

------------------------------------------------------------------------------------------------------------
--网络处理
------------------------------------------------------------------------------------------------------------

function GameLayer:getWinDir( score )
    print("## is my Banker")
    print(self.m_bIsMyBanker)
    print("## is my Banker")
    if true == self.m_bIsMyBanker then
        if score > 0 then
            return cmd.kLanderWin
        elseif score < 0 then
            return cmd.kLanderLose
        end
    else
        if score > 0 then
            return cmd.kFarmerWin
        elseif score < 0 then
            return cmd.kFarmerLose
        end
    end
    return cmd.kDefault
end

function GameLayer:SwitchViewChairID(chair)
    local viewid = yl.INVALID_CHAIR
    if chair == cmd.INVALID_CHAIRID then
        return chair
    end
    local nChairCount = self._gameFrame:GetChairCount()
    if(chair >= nChairCount)then
        error('invalid chair count')
    end
    local nChairID = self:GetMeChairID()
    local userIndex = 1;
    local startIndex = nChairID
    while (true)
        do
        if startIndex == chair then
            break
        end
            userIndex = userIndex + 1
            startIndex = startIndex + 1
        if startIndex >= nChairCount then
            startIndex = 0
        end
    end
    
    return userIndex
end

--获得彩数得分
function GameLayer:getCaiShuScore(logicId)
    --计算彩数得分
    if self.m_cbCaiShuPlayerVec ~= nil and #self.m_cbCaiShuPlayerVec == cmd.PLAYER_COUNT then
        local lCaiShuScore = 0; local cbOtherCaiShu = 0;
        for i = 1, #self.m_cbCaiShuPlayerVec do
            if logicId ~= i then
                cbOtherCaiShu = cbOtherCaiShu + self.m_cbCaiShuPlayerVec[i]
            end
        end
        lCaiShuScore =  self.m_cbCaiShuPlayerVec[logicId] * 3 - cbOtherCaiShu
        return lCaiShuScore
    end

    return 0
end

return GameLayer