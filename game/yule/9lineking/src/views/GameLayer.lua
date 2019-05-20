require("cocos.init")
local module_pre    = "game.yule.9lineking.src"
local GameModel     = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer     = class("GameLayer", GameModel)
local ExternalFun   = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local GameLogic     = appdf.req(module_pre .. ".models.GameLogic")
local QueryDialog   = appdf.req("app.views.layer.other.QueryDialog")
local g_var         = ExternalFun.req_var
local cmd           = module_pre .. ".models.CMD_Game"

local emGameState =
{
    "GAME_STATE_WAITTING",              --等待
    "GAME_STATE_WAITTING_RESPONSE",     --等待服务器响应
    "GAME_STATE_MOVING",                --转动
    "GAME_STATE_RESULT",                --结算
    "GAME_STATE_END",                   --结束
    "GAME_STATE_TAKING_SCORE"           --收分
}
local GAME_STATE = ExternalFun.declarEnumWithTable(0, emGameState)
--------------------------------------------------------------- 系统函数 ---------------------------------------------------------------
function GameLayer:ctor(frameEngine,scene)
    ExternalFun.registerNodeEvent(self)
    GameLayer.super.ctor(self,frameEngine,scene)
    
    self.m_bLeaveGame = false
    
    local bgSize = cc.size(700, 34)
    self.m_pIconMessageBg:setContentSize(bgSize)
    self.m_pStencil:setTextureRect(cc.rect(0, 0, 700-40, 34))
    self.m_pBtnMessage:setContentSize(cc.size(bgSize.width*0.9, bgSize.height*1.5))
end

function GameLayer:getFrame( )
    return self._gameFrame
end

--创建场景
function GameLayer:CreateView()
    return GameViewLayer:create(self)
        :addTo(self)
end

function GameLayer:OnInitGameEngine()
    GameLayer.super.OnInitGameEngine(self)
    self:resetData()
end

function GameLayer:getGameKind()
    return g_var(cmd).KIND_ID
end

function GameLayer:resetData()
    self.m_cbGameStatus         =       0                         -- 游戏状态
    self.m_bIsLeave             =       false                     -- 是否离开游戏
    self.m_lGetScore            =       0                         -- 获得金币
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()
end

function GameLayer:onExit()
    self:KillGameClock()
    self:dismissPopWait()
end
--退出房间
function GameLayer:onExitRoom()
    self._gameView:onUpdateAutoClose()
    self._gameView:onUpdateRollClose()
    self:getFrame():onCloseSocket()
    self:stopAllActions()
    self:KillGameClock()
    self._scene:onKeyBack()
end

--退出桌子
function GameLayer:onExitTable()
    self:KillGameClock()
    local MeItem = self:GetMeUserItem()
    if self.m_bIsLeave == true and  MeItem.cbUserStatus > yl.US_FREE then
        local seq = cc.Sequence:create(
            cc.CallFunc:create(function()
                self._gameFrame:StandUp(1)
            end),
            cc.DelayTime:create(10),
            cc.CallFunc:create(function()
                self:onExitRoom()
            end)
        )
        self:runAction(seq)
        return
    elseif self.m_bIsLeave == false and MeItem.cbUserStatus == yl.US_FREE then
        local seq = cc.Sequence:create(
            cc.CallFunc:create(function()
                ExternalFun.popupTouchFilter(2, false)
                showToast(cc.Director:getInstance():getRunningScene(), "提醒：长时间未操作", 2)
            end),
            cc.DelayTime:create(2),
            cc.CallFunc:create(function()
                self._gameFrame:StandUp(1)
                ExternalFun.dismissTouchFilter()
                self:onExitRoom()
            end)
        )
        self:runAction(seq)
        return
    end
   self:onExitRoom()
end

--------------------------------------------------------------- 场景消息 ---------------------------------------------------------------

function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
    self:KillGameClock()
    self:dismissPopWait()
    self._gameView.m_cbGameStatus = cbGameStatus
	if cbGameStatus == g_var(cmd).GAME_STATUS_FREE	then    -- 空闲状态
        self:onEventGameScenePlay(dataBuffer)
	end
end

function GameLayer:onEventGameScenePlay(dataBuffer)             -- 空闲状态 
    local cmd_table = ExternalFun.read_netdata(g_var(cmd).CMD_S_GameScene, dataBuffer)
    self._gameView:setUserScore(cmd_table.lUserScore)
    self._gameView:setCellScore(cmd_table.lCellScore)
    self._gameView:setTableScore(cmd_table.lTableScore)
    self._gameView:setLotteryScore(cmd_table.lLotteryScore)
end

--------------------------------------------------------------- 游戏消息 ---------------------------------------------------------------

function GameLayer:onEventGameMessage(sub,dataBuffer)
    if sub == g_var(cmd).SUB_S_GameEnd then 
        self:onSubGameEnd(dataBuffer)             -- 改变底注
    end
end

function GameLayer:onSubGameEnd(dataBuffer)       -- 改变底注  
    print("GameLayer:onSubGameEnd")
    local cmd_table = ExternalFun.read_netdata(g_var(cmd).CMD_S_GameEnd, dataBuffer)
    self._gameView.m_cbItemInfo         = cmd_table.cbCardType
    self._gameView.m_cbResultType       = cmd_table.cbResultType[1]
    self._gameView.m_cbResultMultiple   = cmd_table.cbResultMultiple[1]
    self._gameView.m_lWinScore          = cmd_table.lWinScore
    self._gameView:setUserScore(cmd_table.lUserScore)
    self._gameView:setLotteryScore(cmd_table.lLotteryScore)
    self._gameView:onRecGameStart()
end

--------------------------------------------------------------- 请求消息 ---------------------------------------------------------------

function GameLayer:onGameStart(nLine, nCell)
    self:SendUserReady()
    local dataBuffer = CCmd_Data:create(12)
    dataBuffer:pushscore(nCell)
    dataBuffer:pushint(nLine)
    self:SendData(g_var(cmd).SUB_C_GameStart, dataBuffer)
end

return GameLayer