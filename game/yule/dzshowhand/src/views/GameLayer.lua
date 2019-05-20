--                            _ooOoo_
--                           o8888888o
--                           88" . "88
--                           (| -_- |)
--                            O\ = /O
--                        ____/`---'\____
--                      .   ' \\| |// `.
--                      / \\||| : |||// \
--                     / _||||| -:- |||||- \
--                       | | \\\ - /// | |
--                     | \_| ''\---/'' | |
--                      \ .-\__ `-` ___/-. /
--                   ___`. .' /--.--\ `. . __
--                ."" '< `.___\_<|>_/___.' >'"".
--               | | : `- \`.;`\ _ /`;.`/ - ` : | |
--                 \ \ `-. \_ __\ /__ _/ .-` / /
--         ======`-.____`-.___\_____/___.-`____.-'======
--                            `=---='
--
--         .............................................
--                  佛祖保佑             永无BUG 
local GameModel = appdf.req(appdf.CLIENT_SRC .. "gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)
local cmd = import("..models.CMD_Game")
local GameLogic = import("..models.GameLogic")
local GameViewLayer = import(".layer.GameViewLayer")
local GameEndView = import(".layer.GameEndView")
local QueryDialog = appdf.req("base.src.app.views.layer.other.QueryDialog")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

-- *******************游戏数据函数************************--
-- 初始化界面
function GameLayer:ctor(frameEngine, scene)
    GameLayer.super.ctor(self, frameEngine, scene)
end

-- 创建场景
function GameLayer:CreateView()
    return GameViewLayer:create(self)
    :addTo(self)
end

-- 初始化游戏数据
function GameLayer:OnInitGameEngine()
    GameLayer.super.OnInitGameEngine(self)

    self.m_wMinChipInUser = 0                   -- 小盲注
    self.m_wCurrentUser = 0                     -- 当前玩家
    self.m_lAddLessScore = 0                    -- 加最小注
    self.m_lTurnLessScore = 0                   -- 最小下注
    self.m_lTurnMaxScore = 0                    -- 最大下注
    self.m_lCellScore = 0                       -- 单元下注
    self.m_lTableScore = { }                    -- 下注数目
    self.m_lTotalScore = { }                    -- 累计下注
    self.m_cbPlayStatus = { }                   -- 游戏状态
    self.m_dEndScore = { }                      -- 结束分数
    self.m_cbCenterCardData = { }               -- 中心扑克 m_cbCenterCardData[MAX_CENTERCOUNT]
    self.m_cbHandCardData = { { },{ },{ },{ },{ },{ },{ },{ },}     -- 手上扑克 m_cbHandCardData[GAME_PLAYER][MAX_COUNT]
    self.m_cbOverCardData = { { },{ },{ },{ },{ },{ },{ },{ },}     -- 结束扑克 m_cbOverCardData[GAME_PLAYER][MAX_CENTERCOUNT]
    self.m_cbEndCardKind = { 0, 0, 0, 0, 0, 0, 0, 0 }
    self.m_cbEndCardKindView = { "单牌", "对子", "两对", "三条", "顺子", "同花", "葫芦", "四条", "同花顺", "皇家同花顺" }
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()
    GameLayer.super.OnResetGameEngine(self)
    self.m_wMinChipInUser = yl.INVALID_CHAIR    -- 小盲注
    self.m_wCurrentUser = yl.INVALID_CHAIR      -- 当前玩家
    self.m_lAddLessScore = 0                    -- 加最小注
    self.m_lTurnLessScore = 0                   -- 最小下注
    self.m_lTurnMaxScore = 0                    -- 最大下注
    self.m_lCellScore = 0                       -- 单元下注
    self.m_lTableScore = { 0,0,0,0,0,0,0,0}     -- 下注数目
    self.m_lTotalScore = { 0,0,0,0,0,0,0,0}     -- 累计下注
    self.m_cbPlayStatus = {0,0,0,0,0,0,0,0}     -- 游戏状态
    self.m_dEndScore = { 0,0,0,0,0,0,0,0}       -- 结束分数
    self.m_cbCenterCardData = {0,0,0,0,0}       -- 中心扑克 m_cbCenterCardData[MAX_CENTERCOUNT]
    self.m_cbHandCardData = {{ },{ },{ },{ },{ },{ },{ },{ }, } -- 手上扑克 m_cbHandCardData[GAME_PLAYER][MAX_COUNT]
    self.m_cbOverCardData = {{ },{ },{ },{ },{ },{ },{ },{ }, }
    self.m_cbEndCardKind = { 0, 0, 0, 0, 0, 0, 0, 0 }

    self._gameView:OnResetView()
end

-- *******************游戏流程函数********************--
-- 场景信息 断线重连
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)
    if cbGameStatus == cmd.GAME_STATUS_FREE then            -- 空闲状态
        local pStatusFree = ExternalFun.read_netdata(cmd.CMD_S_StatusFree, dataBuffer)
        -- 设置变量
        self.m_lTurnLessScore = pStatusFree.lCellMinScore;
        self.m_lTurnMaxScore = pStatusFree.lCellMaxScore;

        -- 设置游戏初始积分
--        for i = 1, cmd.GAME_PLAYER do
--            self._gameView:SetCurUserMaxScore(i-1,pStatusFree.lGameInitScore[1][i])
--        end  
        self._gameView.m_BtnReady:setVisible(self:GetMeUserItem().cbUserStatus == yl.US_SIT)     
        self:SetGameClock(self:GetMeChairID(),cmd.IDI_START_GAME,cmd.TIME_START_GAME)

    elseif cbGameStatus == cmd.GAME_STATUS_PLAY then           -- 游戏状态
        --隐藏准备按钮
        self._gameView.m_BtnReady:setVisible(false)
        local CMD_S_StatusPlay = ExternalFun.read_netdata(cmd.CMD_S_StatusPlay, dataBuffer)

        -- 加注信息
        self.m_lCellScore = CMD_S_StatusPlay.lCellScore
        self.m_lAddLessScore = CMD_S_StatusPlay.lAddLessScore
        self.m_lTurnLessScore = CMD_S_StatusPlay.lTurnLessScore
        self.m_lTurnMaxScore = CMD_S_StatusPlay.lTurnMaxScore

        local TableAllScore = 0
        for i = 1, GAME_PLAYER do
            local wChairID = i - 1
            TableAllScore = TableAllScore + CMD_S_StatusPlay.lTotalScore[1][i]
            self.m_lTotalScore[i] = CMD_S_StatusPlay.lTotalScore[1][i]
            self.m_lTableScore[i] =  CMD_S_StatusPlay.lTableScore[1][i]
            -- 设置累计下注
            self._gameView:SetTotalScore(wChairID, CMD_S_StatusPlay.lTotalScore[1][i])
            -- 设置当前下注
            self._gameView:SetUserTableScore(wChairID, CMD_S_StatusPlay.lTableScore[1][i])
            -- 设置游戏初始积分
            self._gameView:SetGameInitScore(i - 1, CMD_S_StatusPlay.lGameInitScore[1][i])
            --设置用户携带积分
            self._gameView:SetCurUserMaxScore(i-1,CMD_S_StatusPlay.lUserMaxScore[1][i])
        end
        -- 设置中心分数
        self._gameView:SetCenterScore(TableAllScore)

        -- 状态信息
        -- 庄家
        self._gameView:SetDFlag(CMD_S_StatusPlay.wDUser, true)
        -- 小盲
        self.m_wMinChipInUser = CMD_S_StatusPlay.wMinChipInUser
        -- 当前用户
        self.m_wCurrentUser = CMD_S_StatusPlay.wCurrentUser
        -- 用户状态
        for i = 1, GAME_PLAYER do
            self.m_cbPlayStatus[i] = CMD_S_StatusPlay.cbPlayStatus[1][i]
        end

        -- 扑克信息
        -- 设置手牌
        for i = 1, GAME_PLAYER do
            for j = 1, cmd.MAX_COUNT do
                if self.m_cbPlayStatus[i] == 1 then
                    local wChairID = i - 1
                    if self:GetMeChairID() == wChairID then
                        self._gameView:DrawMoveCard(wChairID, self._gameView.TO_SHOWUSERCARD, CMD_S_StatusPlay.cbHandCardData[1][j])
                    else
                        self._gameView:DrawMoveCard(wChairID, self._gameView.TO_SHOWUSERCARD, CMD_S_StatusPlay.cbHandCardData[1][j])
                    end
                end
            end
        end

        --  设置中心扑克
        for i = 1, #CMD_S_StatusPlay.cbCenterCardData[1] do
            if CMD_S_StatusPlay.cbCenterCardData[1][i] == 0x00 then
                break
            end
            self._gameView:DrawMoveCard(GAME_PLAYER, self._gameView.TO_SHOWCENTER_CARD, CMD_S_StatusPlay.cbCenterCardData[1][i])
        end
        -- 设置底分
        self._gameView:SetCellScore(m_lCellScore)
        
        if self.m_wCurrentUser == self:GetMeChairID() then
           self:UpdateScoreControl()
        else
           self._gameView:HideScoreControl()
        end
        -- 设置时钟
        self:SetGameClock(self.m_wCurrentUser, cmd.IDI_USER_ADD_SCORE, cmd.TIME_USER_ADD_SCORE)
    end
    -- 刷新房卡
    if PriRoom and GlobalUserItem.bPrivateRoom then
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            self._gameView._priView:onRefreshInfo()
        end
    end
    self:dismissPopWait()
end

-- 游戏开始
function GameLayer:OnSubGameStart(dataBuffer)
    local pGameStart = ExternalFun.read_netdata(cmd.CMD_S_GameStart, dataBuffer)

    -- 设置变量
    self.m_wMinChipInUser = pGameStart.wMinChipInUser
    self.m_wCurrentUser = pGameStart.wCurrentUser
    self.m_lAddLessScore = pGameStart.lAddLessScore
    self.m_lTurnLessScore = pGameStart.lTurnLessScore
    self.m_lTurnMaxScore = pGameStart.lTurnMaxScore
    self.m_lCellScore = pGameStart.lCellScore

    -- 加注信息
    self.m_lTableScore[pGameStart.wMinChipInUser + 1] = self.m_lTableScore[pGameStart.wMinChipInUser + 1] + self.m_lCellScore
    self.m_lTableScore[pGameStart.wMaxChipInUser + 1] = 2 * self.m_lCellScore
    self.m_lTotalScore[pGameStart.wMinChipInUser + 1] = self.m_lCellScore
    self.m_lTotalScore[pGameStart.wMaxChipInUser + 1] = 2 * self.m_lCellScore

    -- 设置界面
    self._gameView:SetDFlag(pGameStart.wDUser, true)    
--    self._gameView:SetDFlag(pGameStart.wCurrentUser, true)    
    -- 用户状态
    for i = 1, GAME_PLAYER do
        -- 获取用户
        local userItem = self:getUserInfoByChairID(i - 1)
        -- 读取游戏状态
        if userItem ~= nil then 
            self.m_cbPlayStatus[i] = 1
        end
        -- 设置游戏积分显示
        self._gameView:SetGameInitScore(i - 1, pGameStart.lGameInitScore[1][i])
        self._gameView:SetTotalScore(i - 1,self.m_lTotalScore[i])
        self._gameView:SetUserTableScore(i - 1, 0)
        self._gameView:SetCurUserMaxScore(i-1,pGameStart.lUserMaxScore[1][i])
    end

    -- 设置底分
    self._gameView:SetCellScore(self.m_lCellScore)

    -- 总计下注
    local lTotalScore = 0
    for i = 1, GAME_PLAYER do
        lTotalScore = lTotalScore + self.m_lTableScore[i]
    end

    -- 设置中心分数
    self._gameView:SetCenterScore(lTotalScore)

    -- 设置手牌
    self.m_cbHandCardData = pGameStart.cbCardData
    for j = 1, 2 do
        for i = 1, GAME_PLAYER do
            local userItem = self:getUserInfoByChairID(i - 1)
            if self.m_cbPlayStatus[i] == 1 then
                local wChairID = i - 1
                self._gameView:OnUpdateUser(self:SwitchViewChairID(wChairID), userItem)
                self._gameView:DrawMoveCard(wChairID, self._gameView.TO_USERCARD, self.m_cbHandCardData[i][j])
            end
        end
    end

    -- 设置时钟
    self:SetGameClock(self.m_wCurrentUser, cmd.IDI_USER_ADD_SCORE, cmd.TIME_USER_ADD_SCORE)

    -- 播放游戏开始音效
    self:PlaySound(cmd.RES .. "sound_res/GAME_START.wav")

    -- 控制界面
    if self.m_wCurrentUser == self:GetMeChairID() then
        self:ShowScoreControl()
    end

    -- 刷新房卡
    if PriRoom and GlobalUserItem.bPrivateRoom then
        if nil ~= self._gameView._priView and nil ~= self._gameView._priView.onRefreshInfo then
            PriRoom:getInstance().m_tabPriData.dwPlayCount = PriRoom:getInstance().m_tabPriData.dwPlayCount + 1
            self._gameView._priView:onRefreshInfo()
        end
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

-- 游戏结束
function GameLayer:OnSubGameEnd(dataBuffer)
    local pGameEnd = ExternalFun.read_netdata(cmd.CMD_S_GameEnd, dataBuffer)

    -- 积分信息
    self.m_dEndScore = pGameEnd.lGameScore[1]
    self.m_cbHandCardData = pGameEnd.cbCardData
    self.m_cbOverCardData = pGameEnd.cbLastCenterCardData     
    self.m_cbEndCardKind = pGameEnd.cbEndCardKind[1]
    self._gameView:HideScoreControl()
    self:KillGameTimer()
    
    -- 桌面金币移至中间
    for i = 1, GAME_PLAYER do
        local wChairID = i - 1
        if self.m_lTableScore[i] > 0 and self.m_cbPlayStatus[i] == 1 then
            self._gameView:DrawMoveAnte(wChairID, self._gameView.AA_BASEDEST_TO_CENTER, self.m_lTableScore[i])
        end       
        -- 开牌显示
        self._gameView:SetCardData(wChairID, self.m_cbHandCardData[i])
    end

    -- 显示赢状态
    for i = 1, GAME_PLAYER do
        local wChairID = i - 1
         self._gameView:SetGameInitScore(wChairID, pGameEnd.lGameInitScore[1][i])
         self._gameView:SetDFlag(wChairID, false)
    end
    self:OnGameOver()
end

-- 发送准备
function GameLayer:onStartGame(bReady)
    self:OnResetGameEngine()
    if bReady == true then
        self:SendUserReady()
        self.m_bStartGame = true
    end
end

-- 发牌结束
function GameLayer:OnSendFinish()
    if self.m_wCurrentUser == self:GetMeChairID() then
        self:UpdateScoreControl()
    end
    if self.m_wCurrentUser < GAME_PLAYER then
        self:KillGameClock(cmd.IDI_USER_ADD_SCORE)
        self:SetGameClock(self.m_wCurrentUser, cmd.IDI_USER_ADD_SCORE, cmd.TIME_USER_ADD_SCORE)
    end
end

-- 游戏结束
function GameLayer:OnGameOver()
    -- 状态设置
    self:KillGameClock(cmd.IDI_USER_ADD_SCORE)

    -- 成绩显示在即时聊天对话框
    local tGameEnd = { }
    tGameEnd.tEndScore = self.m_dEndScore
    tGameEnd.tHandCard = self.m_cbOverCardData
    tGameEnd.tCardType = { }
    tGameEnd.userItem = { }
    for i = 1, GAME_PLAYER do
        if self.m_cbPlayStatus[i] == 1 then         
            tGameEnd.userItem[i]  = self._gameFrame:getTableUserItem(self:GetMeTableID(), i - 1)
            tGameEnd.tCardType[i] = self.m_cbEndCardKindView[self.m_cbEndCardKind[i]]
        end
    end
    -- 延时显示结算
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create( function(ref)
        self:addChild(GameEndView:create(self, tGameEnd))
    end )))

end

-- *******************操作函数************************--
-- 开牌按钮
function GameLayer:OnOpenCard()
    -- 发送数据
    local dataBuffer = CCmd_Data:create(0)
    self:SendData(SUB_C_OPEN_CARD, dataBuffer)
end

-- 放弃按钮
function GameLayer:OnGiveUp()
    -- 删除计时器
    self:KillGameClock(cmd.IDI_USER_ADD_SCORE);

    self._gameView:HideScoreControl()

    -- 发送数据
    local dataBuffer = CCmd_Data:create(0)
    self:SendData(SUB_C_GIVE_UP, dataBuffer)
end

-- 跟注按钮
function GameLayer:OnFollow()
    -- 删除定时器
    self:KillGameClock(cmd.IDI_USER_ADD_SCORE);
    -- 获取筹码
    local wMeChairID = self:GetMeChairID()
    self.m_lTableScore[wMeChairID + 1] = self.m_lTableScore[wMeChairID + 1] + self.m_lTurnLessScore
    self.m_lTotalScore[wMeChairID + 1] = self.m_lTotalScore[wMeChairID + 1] + self.m_lTurnLessScore

    self._gameView:SetTotalScore(wMeChairID, self.m_lTotalScore[wMeChairID + 1])

    if self.m_lTableScore[wMeChairID + 1] ~= 0 then
        self._gameView:DrawMoveAnte(wMeChairID, self._gameView.AA_BASEFROM_TO_BASEDEST, self.m_lTurnLessScore);
    end

    self._gameView:HideScoreControl()

    -- 发送数据
    local dataBuffer = CCmd_Data:create(8)
    dataBuffer:pushscore(self.m_lTurnLessScore)
    self:SendData(SUB_C_ADD_SCORE, dataBuffer)
end

-- 加注按钮
function GameLayer:OnAddScore()
    -- 显示加注界面
    self._gameView:HideScoreControl()
    self._gameView.m_ChipBG:setVisible(true)
    -- 更新加注选项
    self._gameView:UpdataAddScoreMultiple(self.m_lTurnLessScore)
    -- 更新可以加注的按钮
     local wMeChairID = self:GetMeChairID();
     self._gameView:UpdateAddScoreBtn(self.m_lTurnMaxScore,self.m_lTotalScore[wMeChairID +1])
end

-- 让牌按钮
function GameLayer:OnPassCard()
    -- 删除定时器
    self:KillGameClock(cmd.IDI_USER_ADD_SCORE)
    self._gameView:HideScoreControl()

    -- 发送数据
    local dataBuffer = CCmd_Data:create(8)
    dataBuffer:pushscore(0)
    self:SendData(SUB_C_ADD_SCORE, dataBuffer)
end

-- 梭哈按钮
function GameLayer:OnShowHand()
    -- 删除定时器
    self:KillGameClock(cmd.IDI_USER_ADD_SCORE);

    -- 获取筹码
    local wMeChairID = self:GetMeChairID();
    self.m_lTableScore[wMeChairID + 1] = self.m_lTableScore[wMeChairID + 1] + self.m_lTurnMaxScore;
    self.m_lTotalScore[wMeChairID + 1] = self.m_lTotalScore[wMeChairID + 1] + self.m_lTurnMaxScore;
    self._gameView:SetTotalScore(wMeChairID, self.m_lTotalScore[wMeChairID + 1]);
    self._gameView:SetUserTableScore(wMeChairID, self.m_lTurnMaxScore);

    self._gameView:HideScoreControl();

    -- 发送数据
    local dataBuffer = CCmd_Data:create(8)
    dataBuffer:pushscore(self.m_lTurnMaxScore)
    self:SendData(SUB_C_ADD_SCORE, dataBuffer)
end

-- 确定加注操作
function GameLayer:OnOKScore(AddScore)
    -- 删除定时器
    self:KillGameClock(cmd.IDI_USER_ADD_SCORE)

    -- 隐藏操作按钮
    self._gameView:HideScoreControl()
    self._gameView.m_ChipBG:setVisible(false)

    -- 获取筹码
    local wMeChairID = self:GetMeChairID()
    self.m_lTableScore[wMeChairID + 1] = self.m_lTableScore[wMeChairID + 1] + AddScore
    self.m_lTotalScore[wMeChairID + 1] = self.m_lTotalScore[wMeChairID + 1] + AddScore

    -- 设置累计下注
    self._gameView:SetTotalScore(wMeChairID, self.m_lTotalScore[wMeChairID + 1])

    -- 加注动画
    if AddScore > 0 then
        -- 设置本次下注
        self._gameView:SetUserTableScore(wMeChairID, AddScore)
        self._gameView:DrawMoveAnte(wMeChairID, self._gameView.AA_BASEFROM_TO_BASEDEST, AddScore)
    end

    -- 发送消息
    local dataBuffer = CCmd_Data:create(8)
    dataBuffer:pushscore(AddScore)
    self:SendData(SUB_C_ADD_SCORE, dataBuffer)
end

-- 取消加注操作
function GameLayer:OnCancelScore()
    self._gameView.m_ChipBG:setVisible(false)
end

-- *******************消息函数************************--
-- 系统消息
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
                :addTo(runScene)
    end
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub, dataBuffer)
    if sub == SUB_S_GAME_START then           -- 游戏开始
        self:OnSubGameStart(dataBuffer)
    elseif sub == SUB_S_ADD_SCORE then        -- 用户加注
        self:OnSubAddScore(dataBuffer)
    elseif sub == SUB_S_GIVE_UP then          -- 用户放弃
        self:OnSubGiveUp(dataBuffer)
    elseif sub == SUB_S_GAME_END then         -- 游戏结束
        self:OnSubGameEnd(dataBuffer)
    elseif sub == SUB_S_SEND_CARD then        -- 发送扑克
        self:OnSubSendCard(dataBuffer)
    elseif sub == SUB_S_OPEN_CARD then        -- 用户开牌
        self:OnSubOpenCard(dataBuffer)
    else
        print("unknow gamemessage sub is" .. sub)
    end
end

-- 放弃消息
function GameLayer:OnSubGiveUp(dataBuffer)
    local pGiveUp = ExternalFun.read_netdata(cmd.CMD_S_GiveUp, dataBuffer)
    local wGiveUpUser = pGiveUp.wGiveUpUser;    
    -- 设置变量
    self.m_cbPlayStatus[wGiveUpUser + 1] = 0

    -- 界面设置
    self._gameView:SetOperatStatus(wGiveUpUser, self._gameView.BT_GIVEUP)
    self:KillGameClock(cmd.IDI_USER_ADD_SCORE)

    self:PlaySound(cmd.RES .. "sound_res/GIVE_UP.wav")
end

-- 加注消息
function GameLayer:OnSubAddScore(dataBuffer)
    local pAddScore = ExternalFun.read_netdata(cmd.CMD_S_AddScore, dataBuffer)

    -- 变量定义
    local wMeChairID = self:GetMeChairID()
    local wAddScoreUser = pAddScore.wAddScoreUser
    local lAddScoreCount = pAddScore.lAddScoreCount
    -- 设置变量
    self.m_wCurrentUser = pAddScore.wCurrentUser;
    self.m_lTurnLessScore = pAddScore.lTurnLessScore;
    self.m_lTurnMaxScore = pAddScore.lTurnMaxScore;
    self.m_lAddLessScore = pAddScore.lAddLessScore;

    -- 加注处理
    if wAddScoreUser ~= wMeChairID then
        -- 加注界面
        if pAddScore.lAddScoreCount > 0 then
            self.m_lTotalScore[wAddScoreUser + 1] = self.m_lTotalScore[wAddScoreUser + 1] + lAddScoreCount
            self.m_lTableScore[wAddScoreUser + 1] = self.m_lTableScore[wAddScoreUser + 1] + lAddScoreCount

            -- 更新加注按钮
            self._gameView:UpdataAddScoreMultiple(self.m_lTurnLessScore)
            self._gameView:DrawMoveAnte(wAddScoreUser, self._gameView.AA_BASEFROM_TO_BASEDEST, lAddScoreCount)
            self._gameView:SetUserTableScore(wAddScoreUser, lAddScoreCount)
            self._gameView:SetTotalScore(wAddScoreUser, self.m_lTotalScore[wAddScoreUser + 1])
        end
    end

    -- 总计下注
    local lTotalScore = 0
    for i = 1, GAME_PLAYER do
        lTotalScore = lTotalScore + self.m_lTotalScore[i]
    end
    self._gameView:SetCenterScore(lTotalScore)

    -- 更新显示状态
    if lAddScoreCount == 0 then
        -- 过牌
        self._gameView:SetOperatStatus(wAddScoreUser, self._gameView.BT_PASS)
    elseif lAddScoreCount == self.m_lTurnMaxScore then
        -- 梭哈
        self._gameView:SetOperatStatus(wAddScoreUser, self._gameView.BT_SHOWHAND)
    elseif lAddScoreCount == self.m_lTurnLessScore then
        -- 跟注
        self._gameView:SetOperatStatus(wAddScoreUser, self._gameView.BT_FOLLOW)
    else
        -- 加注
        self._gameView:SetOperatStatus(wAddScoreUser, self._gameView.BT_ADD)
    end

    -- 控制界面
    if self.m_wCurrentUser == wMeChairID then
        self:UpdateScoreControl()
    end

    if self.m_wCurrentUser == yl.INVALID_CHAIR then
        self:KillGameClock(cmd.IDI_USER_ADD_SCORE)
        -- 筹码移动
        for i = 1, GAME_PLAYER do
            if self.m_cbPlayStatus[i] == 1 then
                if self.m_lTableScore[i] ~= 0 then
                    local wChairID = i - 1
                    self._gameView:DrawMoveAnte(wAddScoreUser, self._gameView.AA_BASEDEST_TO_CENTER, self.m_lTableScore[i])
                    self._gameView:SetUserTableScore(wChairID, 0)
                end
            end
        end
        self.m_lTableScore = { 0, 0, 0, 0, 0, 0, 0, 0 }
    elseif self.m_wCurrentUser < GAME_PLAYER then
        self:KillGameClock(cmd.IDI_USER_ADD_SCORE)
        self:SetGameClock(self.m_wCurrentUser, cmd.IDI_USER_ADD_SCORE, cmd.TIME_USER_ADD_SCORE);
    end
end

-- 发牌消息
function GameLayer:OnSubSendCard(dataBuffer)
    local pSendCard = ExternalFun.read_netdata(cmd.CMD_S_SendCard, dataBuffer)
    local cbSendCardCount = pSendCard.cbSendCardCount
    local cbPublic = pSendCard.cbPublic
    -- 当前玩家
    self.m_wCurrentUser = pSendCard.wCurrentUser;
    self.m_cbCenterCardData = pSendCard.cbCenterCardData[1]

    -- 发送共牌
    if cbSendCardCount >= 3 and cbSendCardCount <= 5 and cbPublic == 0 then
        -- 发送共牌
        if cbSendCardCount == 3 then
            for j = 1, pSendCard.cbSendCardCount do
                self._gameView:DrawMoveCard(GAME_PLAYER, self._gameView.TO_CENTER_CARD, self.m_cbCenterCardData[j])
            end
        elseif cbSendCardCount > 3 then
            local bTemp = pSendCard.cbSendCardCount;
            self._gameView:DrawMoveCard(GAME_PLAYER, self._gameView.TO_CENTER_CARD, self.m_cbCenterCardData[bTemp]);
        end
    end

    if cbSendCardCount == 5 and cbPublic >= 1 then
        local bFirstCard = cbPublic
        if bFirstCard == 1 then
            bFirstCard = 1
        elseif bFirstCard == 2 then
            bFirstCard = 4
        elseif bFirstCard == 3 then
            bFirstCard = 5
        end
        for j = bFirstCard, pSendCard.cbSendCardCount do
            self._gameView:DrawMoveCard(GAME_PLAYER, self._gameView.TO_CENTER_CARD, self.m_cbCenterCardData[j]);
        end
    end
end

-- 开牌消息
function GameLayer:OnSubOpenCard(dataBuffer)
    local pOpenCard = ExternalFun.read_netdata(cmd.CMD_S_OpenCard, dataBuffer)
    for i = 1, GAME_PLAYER do
        local wChairID = i - 1
        local pClientUserItem = self:getUserInfoByChairID(wChairID)
        if pClientUserItem and pClientUserItem.cbUserStatus ~= yl.US_READY then
            self._gameView:SetCardData(wChairID, self.m_cbHandCardData[i])
        end
    end
end


-- *******************功能函数************************--
-- 换位操作
function GameLayer:onChangeDesk()
    self._gameFrame:QueryChangeDesk()
end

function GameLayer:ShowScoreControl()
    self._gameView.btnGiveUp:setVisible(true)
    self._gameView.btnNoAdd:setVisible(true)   
    self._gameView.btnAdd:setVisible(true) 
end

-- 更新操作
function GameLayer:UpdateScoreControl()
    -- 显示让牌，跟注
    if self.m_lTurnLessScore > 0 then
        self._gameView.btnNoAdd:setVisible(false)        
        self._gameView.btnFollow:setVisible((self.m_lTurnLessScore == self.m_lTurnMaxScore) and false or true)            
    else
        self._gameView.btnNoAdd:setVisible(true)        
        self._gameView.btnFollow:setVisible(false)  
    end

    -- 加注
    if self.m_lAddLessScore > self.m_lTurnMaxScore then      
         self._gameView.btnAdd:setVisible(false)
    else
        self._gameView.btnAdd:setVisible(true)
    end
    -- 弃牌   
    self._gameView.btnGiveUp:setVisible(true)
end

--function GameLayer:onUserChat(chatinfo, sendchair)
--    if chatinfo and sendchair then
--        local viewid = self:SwitchViewChairID(sendchair)
--        if viewid and viewid ~= yl.INVALID_CHAIR then
--            self._gameView:ShowUserChat(viewid, chatinfo.szChatString)
--        end
--    end
--end

--function GameLayer:onUserExpression(expression, sendchair)
--    if expression and sendchair then
--        local viewid = self:SwitchViewChairID(sendchair)
--        if viewid and viewid ~= yl.INVALID_CHAIR then
--            self._gameView:ShowUserExpression(viewid, expression.wItemIndex)
--        end
--    end
--end

-- 语音播放开始
function GameLayer:onUserVoiceStart( useritem, filepath )
    self._gameView:onUserVoiceStart(self:SwitchViewChairID(useritem.wChairID))
end

-- 语音播放结束
function GameLayer:onUserVoiceEnded( useritem, filepath )
    self._gameView:onUserVoiceEnded(self:SwitchViewChairID(useritem.wChairID))
end

-- 游戏退出
function  GameLayer:onExit()
    self:KillGameClock()
    self:dismissPopWait()
    GameLayer.super.onExit(self)
end

-- 退出桌子
function GameLayer:onExitTable()
    if self.m_querydialog then
        return
    end
    self:KillGameClock()
    local MeItem = self:GetMeUserItem()
    if MeItem and MeItem.cbUserStatus > yl.US_FREE then
        self:showPopWait()
        self:runAction(cc.Sequence:create(
        cc.CallFunc:create(
        function()
            self._gameFrame:StandUp(1)
        end
        ),
        cc.DelayTime:create(10),
        cc.CallFunc:create(
        function()
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

-- 离开房间
function GameLayer:onExitRoom()
    self._scene:onKeyBack()
end

-- 用户视图转换
function GameLayer:SwitchViewChairID(chair)
    local nViewID = yl.INVALID_CHAIR
    local nChairCount = self._gameFrame:GetChairCount()
    print("椅子数目", nChairCount)
    local nChairID = self:GetMeChairID()
    if chair ~= yl.INVALID_CHAIR and chair < nChairCount then
        -- nViewID = math.mod(chair + math.floor(nChairCount * 3 / 2) - nChairID, nChairCount) + 1
        nViewID = math.mod(chair - nChairID + nChairCount, nChairCount) + 1
        print("转换后的ID=", nViewID)
    end
    return nViewID
end

-- 当前玩家坐下人数
function GameLayer:onGetSitUserNum()
    local num = 0
    for i = 1, cmd.GAME_PLAYER do
        if nil ~= self._gameView.m_sparrowUserItem[i] then
            num = num + 1
        end
    end
    return num
end

-- 用户椅子ID
function GameLayer:getUserInfoByChairID(chairId)
    return self._gameFrame:getTableUserItem(self._gameFrame:GetTableID(), chairId)
end

-- 获取gamekind
function GameLayer:getGameKind()
    return cmd.KIND_ID
end

-- 得到父节点
function GameLayer:getParentNode()
    return self._scene
end

-- 设置计时器
function GameLayer:SetGameClock(chair, id, time)
    GameLayer.super.SetGameClock(self, chair, id, time)
    local viewid = self:GetClockViewID()
    if viewid and viewid ~= yl.INVALID_CHAIR then
        --[[
        local progress = self._gameView.m_TimeProgress[viewid]
        if progress ~= nil then
            progress:setPercentage(100)
            progress:setVisible(true)
            progress:runAction(cc.Sequence:create(cc.ProgressTo:create(time, 0), cc.CallFunc:create( function()
                progress:setVisible(false)
                self:OnEventGameClockInfo(viewid, id)
            end )))
        end
        ]]
    end
end

-- 关闭计时器
function GameLayer:KillGameClock(notView)
    local nViewID = self:GetClockViewID()
    if nViewID and nViewID ~= yl.INVALID_CHAIR then
        -- 关闭计时器
        self._gameView:OnCloseClockView(nViewID)
    end
    GameLayer.super.KillGameClock(self, notView)
end

-- 删除时间
function GameLayer:KillGameTimer(nTimerID)
    self:KillGameClock(nil)
end

-- 获取当前正在玩的玩家数量
function GameLayer:getPlayingNum()
    local num = 0
    for i = 1, cmd.GAME_PLAYER do
        if self.m_cbPlayStatus[i] == 1 then
            num = num + 1
        end
    end
    return num
end

-- 时钟处理
function GameLayer:OnEventGameClockInfo(chair, time, clockid)
    -- 房卡不托管
    if GlobalUserItem.bPrivateRoom then
        print("倒计时处理，房卡返回")
        if time <= 0 then
            return true
        end
    end
    if time < 5 then
        self:PlaySound(cmd.RES .. "sound_res/GAME_WARN.wav")
    end
    if clockid == cmd.IDI_START_GAME then
        if time <= 0 then
            self._gameFrame:setEnterAntiCheatRoom(false)
            -- 退出防作弊
            return true
        end
    elseif clockid == cmd.IDI_USER_ADD_SCORE then
        if time == 0 then
            if m_wCurrentUser == self:GetMeChairID() then
                self:OnGiveUp()
                return true
            end
        end
    elseif clockid == cmd.IDI_GAME_END_DELAY then
        if time == 0 then
            self:OnGameOver()
            return true
        end
    end
end
-- 最少加注
function GameLayer:OnMinScore()  
end

-- 最大加注
function GameLayer:OnMaxScore()
  
end

function GameLayer:ShowBtnStart()
    self._gameView.m_BtnReady:setVisible(true)
    self:SetGameClock(self:GetMeChairID(),cmd.IDI_START_GAME,cmd.TIME_START_GAME)
end

return GameLayer  