local GameViewLayer = class("GameViewLayer",function(scene)
    local gameViewLayer = display.newLayer()
    return gameViewLayer
end)

local module_pre        = "game.yule.9lineking.src"
local cmd               = module_pre .. ".models.CMD_Game"
local ClipText          = appdf.EXTERNAL_SRC .. "ClipText"
local SettingLayer      = appdf.req(module_pre .. ".views.layer.GameSetLayer")
local HelpLayer         = appdf.req(module_pre .. ".views.layer.HelpLayer")
local GameLogic         = appdf.req(module_pre .. ".models.GameLogic")
local QueryDialog       = appdf.req("app.views.layer.other.QueryDialog")
local ExternalFun       = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameSystemMessage = appdf.req(appdf.EXTERNAL_SRC .. "GameSystemMessage")
local g_var             = ExternalFun.req_var
local scheduler         = cc.Director:getInstance():getScheduler()

GameViewLayer.TAG_GAMESYSTEMMESSAGE = 6751
GameViewLayer.TAG_BACK  = 1
GameViewLayer.TAG_HELP  = 2
GameViewLayer.TAG_SET   = 3
GameViewLayer.TAG_CHAT  = 4
GameViewLayer.TAG_FULL  = 5
GameViewLayer.TAG_LINE  = 6
GameViewLayer.TAG_CELL  = 7
GameViewLayer.TAG_START = 8

GameViewLayer.TAG_ANI_GOLD = 677

GameViewLayer.LINE_POS = {cc.p(657, 429), cc.p(657, 581), cc.p(657, 279), cc.p(657, 461), cc.p(657, 400), cc.p(657, 429), cc.p(657, 429), cc.p(657, 424), cc.p(657, 425)}
GameViewLayer.GOODS_POS = {cc.p(299, 286), cc.p(477, 286), cc.p(655, 286), cc.p(833, 286), cc.p(1011, 286)}
GameViewLayer.GOODS_GAP = 140
GameViewLayer.GOODS_COUNT = {20, 27, 34, 41, 48}

GameViewLayer.ROLL_STATUS_DOWN = 1
GameViewLayer.ROLL_STATUS_DOWNSHOW = 2
GameViewLayer.ROLL_STATUS_UP = 3
GameViewLayer.ROLL_STATUS_STOP = 4

GameViewLayer.GAME_STATUS_FREE = 1
GameViewLayer.GAME_STATUS_WAIT = 2
GameViewLayer.GAME_STATUS_PLAY = 3
GameViewLayer.GAME_STATUS_END  = 4
--------------------------------------------------------------- 系统函数 ---------------------------------------------------------------
function GameViewLayer:ctor(scene)
	self._scene = scene
	ExternalFun.registerNodeEvent(self)     -- 注册node事件
    self:initUI()                           -- 初始化csb界面
end

function GameViewLayer:onExit()
    ExternalFun.playPlazzBackgroudAudio()   -- 播放大厅背景音乐
end

function GameViewLayer:initUI()             -- 初始化按钮
	--按钮回调方法
    local function btnEvent(sender, eventType)
        ExternalFun.btnEffect(sender, eventType)
        if eventType == ccui.TouchEventType.began then
        elseif eventType == ccui.TouchEventType.canceled then
        elseif eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end

    local function btnEvent1(sender, eventType)
        local text = sender:getChildByName("text")
        if eventType == ccui.TouchEventType.began then
            sender:setContentSize(cc.size(sender:getContentSize().width, 82))
            if text ~= nil then
                text:setPosition(cc.p(text:getPositionX(), 43.5))
            end
        elseif eventType == ccui.TouchEventType.canceled then
            sender:setContentSize(cc.size(sender:getContentSize().width, 87))
            if text ~= nil then
                text:setPosition(cc.p(text:getPositionX(), 48.5))
            end
        elseif eventType == ccui.TouchEventType.ended then
            sender:setContentSize(cc.size(sender:getContentSize().width, 87))
            if text ~= nil then
                text:setPosition(cc.p(text:getPositionX(), 48.5))
            end
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end

    local function btnEvent2(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            if self.m_bIsAuto == false then
                self:onUpdateAutoOpen()
            end
        elseif eventType == ccui.TouchEventType.canceled then
            self:onUpdateAutoClose()
        elseif eventType == ccui.TouchEventType.ended then
            self:onUpdateAutoClose()
            if self:getButtonStartIsAuto() then -- 按钮为停止自动 如果isAuto为true则代表取消自动 如果为false则代表刚开启自动
                if self.m_bIsAuto then
                    self.m_bIsAuto = false
                    self:setButtonStartIsAuto(false)
                else
                    self.m_bIsAuto = true
                    self:onButtonClickedEvent(sender:getTag(), sender)
                end
            else
                self:onButtonClickedEvent(sender:getTag(), sender)
            end
        end
    end
    

	self._csbNode = cc.CSLoader:createNode("game/GameLayer.csb")
	self:addChild(self._csbNode)
    self.m_pNodeGoods       = self._csbNode:getChildByName("m_pNodeGoods")          -- 滚动物品节点
    self.m_pNodeLine        = self._csbNode:getChildByName("m_pNodeLine")           -- 连线节点
    self.m_pNodePoint       = self._csbNode:getChildByName("m_pNodePoint")          -- 跑马灯节点
    self.m_pNodeScore       = self._csbNode:getChildByName("m_pNodeScore")          -- 分数节点
    self.m_pNodeControl     = self._csbNode:getChildByName("m_pNodeControl")        -- 控制按钮节点
    self.m_pNodeShow        = self._csbNode:getChildByName("m_pNodeShow")           -- 显示提示之类的节点
    self.m_pNodeBtn         = self._csbNode:getChildByName("m_pNodeBtn")            -- 游戏按钮节点
    self.m_pNodeGoldPool    = self._csbNode:getChildByName("m_pNodeGoldPool")       -- 彩金节点
    self.m_pIconTip         = self._csbNode:getChildByName("m_pIconTip")            -- 中奖提示
    local nodeWin           = self._csbNode:getChildByName("m_pNodeWin")            -- 赢分节点

    self.m_pNodeWin = {}
    for i = 1, 4 do
        self.m_pNodeWin[i] = nodeWin:getChildByName(string.format("m_pNodeWin%d", i))
        self.m_pNodeWin[i]:setScale(0)
        self.m_pNodeWin[i]:setSwallowTouches(false)

        self.m_pNodeWin[i].score = self.m_pNodeWin[i]:getChildByName("m_pTextWinScore")
        
        self.m_pNodeWin[i].light = self.m_pNodeWin[i]:getChildByName("m_pIconLight")
        --self.m_pNodeWin[i]:getChildByName("m_pIconLight"):setVisible(false)
    end
    
    self.m_pTextScore       = self.m_pNodeScore:getChildByName("m_pTextScore")      -- 玩家身上金币
    self.m_pTextChip        = self.m_pNodeScore:getChildByName("m_pTextChip")       -- 当前下注金额
    self.m_pTextWinScore    = self.m_pNodeScore:getChildByName("m_pTextWinScore")   -- 总共输赢金额

    local m_pBtnFull        = self.m_pNodeControl:getChildByName("m_pBtnFull")      -- 押满按钮
    local m_pBtnLine        = self.m_pNodeControl:getChildByName("m_pBtnLine")      -- 线数按钮
    local m_pBtnCell        = self.m_pNodeControl:getChildByName("m_pBtnCell")      -- 底注按钮
    local m_pBtnStart       = self.m_pNodeControl:getChildByName("m_pBtnStart")     -- 开始按钮

    local m_pBtnBack        = self.m_pNodeBtn:getChildByName("m_pBtnBack")          -- 返回按钮
    local m_pBtnHelp        = self.m_pNodeBtn:getChildByName("m_pBtnHelp")          -- 帮助按钮
    local m_pBtnSet         = self.m_pNodeBtn:getChildByName("m_pBtnSet")           -- 设置按钮
    local m_pBtnChat        = self.m_pNodeBtn:getChildByName("m_pBtnChat")          -- 聊天按钮

    self.m_pTextLine        = m_pBtnLine:getChildByName("text")                     -- 按钮线数
    self.m_pTextCell        = m_pBtnCell:getChildByName("text")                     -- 按钮倍数
    self.m_pNodeGoldPoolScore = self.m_pNodeGoldPool:getChildByName("m_pNodeScore") -- 彩金数字
    local nodeLineLight     = self._csbNode:getChildByName("m_pNodeLineLight")
    
    m_pBtnFull:setTag(GameViewLayer.TAG_FULL)
    m_pBtnLine:setTag(GameViewLayer.TAG_LINE)
    m_pBtnCell:setTag(GameViewLayer.TAG_CELL)
    m_pBtnStart:setTag(GameViewLayer.TAG_START)
    m_pBtnBack:setTag(GameViewLayer.TAG_BACK)
    m_pBtnHelp:setTag(GameViewLayer.TAG_HELP)
    m_pBtnSet:setTag(GameViewLayer.TAG_SET)
    m_pBtnChat:setTag(GameViewLayer.TAG_CHAT)
    
    m_pBtnFull:addTouchEventListener(btnEvent1)
    m_pBtnLine:addTouchEventListener(btnEvent1)
    m_pBtnCell:addTouchEventListener(btnEvent1)
    m_pBtnStart:addTouchEventListener(btnEvent2)
    m_pBtnBack:addTouchEventListener(btnEvent)
    m_pBtnHelp:addTouchEventListener(btnEvent)
    m_pBtnSet:addTouchEventListener(btnEvent)
    m_pBtnChat:addTouchEventListener(btnEvent)

    m_pBtnStart.isAuto = false
    
    -- 获取连线
    self.m_tagLine = {}
    for i = 1, g_var(cmd).LINE_COUNT do
        self.m_tagLine[i] = cc.ProgressTimer:create(display.newSprite(string.format("#tiger_game_icon_line%d.png", i)))
        self.m_tagLine[i]:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        self.m_tagLine[i]:setPercentage(0)
        self.m_tagLine[i]:setMidpoint(ccp(0,1))
        self.m_tagLine[i]:setPosition(GameViewLayer.LINE_POS[i])
        self.m_tagLine[i]:setBarChangeRate(ccp(1, 0))
        self.m_pNodeLine:addChild(self.m_tagLine[i])
    end
    
    -- 获取跑马灯
    self.m_pPointArray = {}
    for i = 1, g_var(cmd).POINT_COUNT do
        self.m_pPointArray[i] = self.m_pNodePoint:getChildByName(string.format("m_pIconPoint%d", i))
    end

    -- 彩金数字数组
    self.m_tagGoldPool = {}     
    for i = 1, 12 do
        self.m_tagGoldPool[i] = self.m_pNodeGoldPoolScore:getChildByName(string.format("m_pTextGoldPool%d", i))
    end
    
    -- 滚动物品数组
    self.m_tagGoodsArray = {}   
    local item = nil
    for i = 1, g_var(cmd).ITEM_X_COUNT do
        self.m_tagGoodsArray[i] = {}
        for j = 1, g_var(cmd).ITEM_Y_COUNT do
            item = display.newSprite(string.format("#tiger_game_icon_goods%d.png", math.random(1, 11)))
            item:setPosition(cc.p(GameViewLayer.GOODS_POS[i].x, GameViewLayer.GOODS_POS[i].y + GameViewLayer.GOODS_GAP * (j - 1)))
            item.index = j
            item.line = i
            table.insert(self.m_tagGoodsArray[i], item)
            self.m_pNodeGoods:addChild(item)
        end
    end
    
    self.m_tagLineLight = {}
    for i = 1, g_var(cmd).LINE_COUNT do
        self.m_tagLineLight[i] = nodeLineLight:getChildByName(string.format("m_pIconLineLight%d_1", i))     -- 左边数字光
        self.m_tagLineLight[i+9] = nodeLineLight:getChildByName(string.format("m_pIconLineLight%d_2", i))   -- 右边数字光
    end

    self:resetData()
    self:onAniLight1()
end

function GameViewLayer:resetData()                                              -- 重置数据
    self.m_pTextScore.number    =       0
    self.m_pTextWinScore.number =       0
    self.m_pTextLine.number     =       1                                       -- 线数
    self.m_bUpdateAutoTime      =       0                                       -- 自动时间
    self.m_bIsAuto              =       false                                   -- 是否自动
    self.m_pSchedulerAuto       =       nil                                     -- 自动函数
    self.m_pSchedulerRoll       =       nil                                     -- 滚动函数
    self.m_tagRollPath          =       { GameViewLayer.ROLL_STATUS_DOWN,       -- 滚动方向
                                          GameViewLayer.ROLL_STATUS_DOWN, 
                                          GameViewLayer.ROLL_STATUS_DOWN, 
                                          GameViewLayer.ROLL_STATUS_DOWN, 
                                          GameViewLayer.ROLL_STATUS_DOWN  }
    self.m_fRollSpeed           =       1                                       -- 滚动速度
    self.m_bGame_Status         =       GameViewLayer.GAME_STATUS_FREE          -- 游戏状态
    self.m_lCellScore           =       0                                       -- 底分
    self.m_lLotteryScore        =       0                                       -- 彩金
    self.m_lTableScore          =       0                                       -- 桌面底分
    self.m_lWinScore            =       0                                       -- 输赢分数
    self.m_cbItemInfo           =       {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}}   -- 开奖信息
    self.m_cbResultType         =       {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}                     -- 开奖信息
    self.m_cbResultMultiple     =       {0,0,0,0,0,0,0,0,0}                     -- 开奖信息
    self:onAniStopWin()
end

function GameViewLayer:onButtonClickedEvent(tag,ref)
	if     tag == GameViewLayer.TAG_FULL    then
        self:onButtonEventFull()
    elseif tag == GameViewLayer.TAG_LINE    then
        self:onButtonEventLine()
    elseif tag == GameViewLayer.TAG_CELL    then
        self:onButtonEventCell()
    elseif tag == GameViewLayer.TAG_START   then
        self:onButtonEventStart()
    elseif tag == GameViewLayer.TAG_BACK    then
        self:onButtonEventBack()
    elseif tag == GameViewLayer.TAG_HELP    then
        self:onButtonEventHelp()
    elseif tag == GameViewLayer.TAG_SET     then
        self:onButtonEventSet()
    elseif tag == GameViewLayer.TAG_CHAT    then
        self:onButtonEventChat()
	end
end
--------------------------------------------------------------- 参数设置 ---------------------------------------------------------------
function GameViewLayer:setButtonStartIsAuto(isAuto)
    local m_pBtnStart = self.m_pNodeControl:getChildByName("m_pBtnStart")       -- 开始按钮
    m_pBtnStart.isAuto = isAuto
    if isAuto then
        m_pBtnStart:loadTextures("tiger_game_btn_start3.png", "tiger_game_btn_start4.png", "tiger_game_btn_start4.png", ccui.TextureResType.plistType)
    else
        m_pBtnStart:loadTextures("tiger_game_btn_start1.png", "tiger_game_btn_start2.png", "tiger_game_btn_start2.png", ccui.TextureResType.plistType)
    end
end

function GameViewLayer:getButtonStartIsAuto()
    local m_pBtnStart = self.m_pNodeControl:getChildByName("m_pBtnStart")       -- 开始按钮
    return m_pBtnStart.isAuto
end

function GameViewLayer:setCellScore(score)
    self.m_lCellScore = score
end

function GameViewLayer:setLotteryScore(score)
    self.m_lLotteryScore = score
    self:onAniChangeGoldPool(score)
end

function GameViewLayer:setUserScore(score)
    self.m_pTextScore.number = score
    self:onAniChangeScore(self.m_pTextScore, score)
end

function GameViewLayer:setChipScore()
    self:onAniChangeScore(self.m_pTextChip, self.m_pTextLine.number * self.m_lTableScore)
end

function GameViewLayer:setWinScore(score)
    self.m_pTextWinScore.number = score
    self:onAniChangeScore(self.m_pTextWinScore, score)
end

function GameViewLayer:setLine(full)
    if full then
        self.m_pTextLine.number = 9
    else
        self.m_pTextLine.number = self.m_pTextLine.number + 1
        if self.m_pTextLine.number > g_var(cmd).LINE_COUNT then
            self.m_pTextLine.number = 1
        end
    end
    self.m_pTextLine:setString(tostring(self.m_pTextLine.number))
    self:onAniShowLine(self.m_pTextLine.number)
    self:setChipScore()
end

function GameViewLayer:setTableScore(full)
    if full then
        self.m_lTableScore = self.m_lCellScore * g_var(cmd).MAX_MULTIPLE
    else
        self.m_lTableScore = self.m_lTableScore + self.m_lCellScore
        if self.m_lTableScore > self.m_lCellScore * g_var(cmd).MAX_MULTIPLE then
            self.m_lTableScore = self.m_lCellScore
        end
    end

    self.m_pTextCell:setString(tostring(self.m_lTableScore))
    self:setChipScore()
end

function GameViewLayer:setGameStatus(status)
    self.m_bGame_Status = status
    self:setButtonEnabled(self.m_bGame_Status == GameViewLayer.GAME_STATUS_FREE)
end

function GameViewLayer:setButtonEnabled(isEnabled)
    local m_pBtnFull = self.m_pNodeControl:getChildByName("m_pBtnFull")      -- 押满按钮
    local m_pBtnLine = self.m_pNodeControl:getChildByName("m_pBtnLine")      -- 线数按钮
    local m_pBtnCell = self.m_pNodeControl:getChildByName("m_pBtnCell")      -- 底注按钮

    m_pBtnFull:setEnabled(isEnabled)
    m_pBtnLine:setEnabled(isEnabled)
    m_pBtnCell:setEnabled(isEnabled)
    
    m_pBtnFull:getChildByName("black"):setVisible(isEnabled == false)
    m_pBtnLine:getChildByName("black"):setVisible(isEnabled == false)
    m_pBtnCell:getChildByName("black"):setVisible(isEnabled == false)
end
---------------------------------------------------------------  倒计时  ---------------------------------------------------------------
function GameViewLayer:updateAuto(dt)
    self.m_bUpdateAutoTime = self.m_bUpdateAutoTime + 1
    if self.m_bUpdateAutoTime >= 2 then
        self:onUpdateAutoClose()
        self:setButtonStartIsAuto(true)
    end
end

function GameViewLayer:onUpdateAutoOpen()
    self.m_bUpdateAutoTime = 0
    if self.m_pSchedulerAuto == nil then
	    local function updateauto(dt)
	        self:updateAuto(dt)
	    end
        self.m_pSchedulerAuto = scheduler:scheduleScriptFunc(updateauto, 1, false)
    end
end

function GameViewLayer:onUpdateAutoClose()
    if self.m_pSchedulerAuto ~= nil then
	    scheduler:unscheduleScriptEntry(self.m_pSchedulerAuto)
	    self.m_pSchedulerAuto = nil
	end
end

function GameViewLayer:updateRoll(dt)
    if self.m_fRollSpeed < 40 then
        self.m_fRollSpeed = self.m_fRollSpeed + 4
    end
    for i = 1, g_var(cmd).ITEM_X_COUNT do
        for k, v in pairs(self.m_tagGoodsArray[i]) do
            if self.m_tagRollPath[i] == GameViewLayer.ROLL_STATUS_DOWN then
                v:setPosition(cc.p(v:getPositionX(), v:getPositionY()-self.m_fRollSpeed))
                if k == #self.m_tagGoodsArray[i] - 3 then
                    if v:getPositionY() < GameViewLayer.GOODS_POS[i].y + GameViewLayer.GOODS_GAP*3 then
                        self.m_tagRollPath[i] = GameViewLayer.ROLL_STATUS_DOWNSHOW
                    end
                end
            elseif self.m_tagRollPath[i] == GameViewLayer.ROLL_STATUS_DOWNSHOW then
                v:setPosition(cc.p(v:getPositionX(), v:getPositionY()-self.m_fRollSpeed))
                if k == #self.m_tagGoodsArray[i] then
                    if v:getPositionY() < GameViewLayer.GOODS_POS[i].y + GameViewLayer.GOODS_GAP*2.8 then
                        self.m_tagRollPath[i] = GameViewLayer.ROLL_STATUS_UP
                    end
                end
            elseif self.m_tagRollPath[i] == GameViewLayer.ROLL_STATUS_UP then
                v:setPosition(cc.p(v:getPositionX(), v:getPositionY() + 3))
                if k == #self.m_tagGoodsArray[i] then
                    if v:getPositionY() > GameViewLayer.GOODS_POS[i].y + GameViewLayer.GOODS_GAP*3 then
                        self.m_tagRollPath[i] = GameViewLayer.ROLL_STATUS_STOP
                    end
                end
            end
        end
    end
    
    local isOver = true
    for i = 1, g_var(cmd).ITEM_X_COUNT do
        if self.m_tagRollPath[i] ~= GameViewLayer.ROLL_STATUS_STOP then
            isOver = false
        end
    end
    if isOver then
        self:setGameStatus(GameViewLayer.GAME_STATUS_END)
        self:onAniShowGoods()
        self:onUpdateRollClose()
    end
end

function GameViewLayer:onUpdateRollOpen()
    if self.m_pSchedulerRoll == nil then
	    local function updateroll(dt)
	        self:updateRoll(dt)
	    end
        self.m_pSchedulerRoll = scheduler:scheduleScriptFunc(updateroll, 0, false)
    end
end

function GameViewLayer:onUpdateRollClose()
    if self.m_pSchedulerRoll ~= nil then
	    scheduler:unscheduleScriptEntry(self.m_pSchedulerRoll)
	    self.m_pSchedulerRoll = nil
	end
end
--------------------------------------------------------------- 按钮事件 ---------------------------------------------------------------
-- 押满
function GameViewLayer:onButtonEventFull()
    if self.m_bGame_Status ~= GameViewLayer.GAME_STATUS_FREE then
        return
    end
    self:setLine(true)
    self:setTableScore(true)
end

-- 线数
function GameViewLayer:onButtonEventLine()
    if self.m_bGame_Status ~= GameViewLayer.GAME_STATUS_FREE then
        return
    end
    self:setLine()
end

-- 底注
function GameViewLayer:onButtonEventCell()
    if self.m_bGame_Status ~= GameViewLayer.GAME_STATUS_FREE then
        return
    end
    self:setTableScore()
end

-- 开始
function GameViewLayer:onButtonEventStart()
    if     self.m_bGame_Status == GameViewLayer.GAME_STATUS_FREE then
        self._scene:onGameStart(self.m_pTextLine.number, self.m_lTableScore)
        self:setGameStatus(GameViewLayer.GAME_STATUS_WAIT)
    elseif self.m_bGame_Status == GameViewLayer.GAME_STATUS_WAIT then
        
    elseif self.m_bGame_Status == GameViewLayer.GAME_STATUS_PLAY then
        self:onAniStopRoll()            -- 停止滚动
    elseif self.m_bGame_Status == GameViewLayer.GAME_STATUS_END  then

    end
end

-- 返回
function GameViewLayer:onButtonEventBack()
    self.m_bIsLeave = true
    self._scene:onExitTable()
end

-- 帮助
function GameViewLayer:onButtonEventHelp()
    if nil == self.m_pHelpLayer then
        self.m_pHelpLayer = HelpLayer:create()
        self.m_pHelpLayer:setLocalZOrder(20)
        self:addChild(self.m_pHelpLayer)
    else
        self.m_pHelpLayer:onShow()
    end
end

-- 设置
function GameViewLayer:onButtonEventSet()
    if nil == self.m_pSetLayer then
        local mgr = self._scene._scene:getApp():getVersionMgr(g_var(cmd).KIND_ID)
        local verstr = mgr:getResVersion() or "0"
        self.m_pSetLayer = SettingLayer:create(verstr)
        self.m_pSetLayer:setLocalZOrder(20)
        self:addChild(self.m_pSetLayer)
    else
        self.m_pSetLayer:onShow()
    end
end

-- 聊天
function GameViewLayer:onButtonEventChat()
    local item = self:getChildByTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
    if item ~= nil then
        item:resetData()
    else
        local gameSystemMessage = GameSystemMessage:create()
        gameSystemMessage:setLocalZOrder(100)
        gameSystemMessage:setTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
        self:addChild(gameSystemMessage)
    end
end
--------------------------------------------------------------- 游戏动画 ---------------------------------------------------------------

function GameViewLayer:onAniShowWin(index, score)
    self.m_pNodeWin[index]:runAction(
        cc.Sequence:create(
            cc.ScaleTo:create(0.3, 1.2),
            cc.ScaleTo:create(0.1, 1),
            cc.CallFunc:create(function(sender)
                sender.light:runAction(cc.RepeatForever:create(cc.RotateBy:create(4, 360)))
                self:onAniChangeScore(sender.score, score)
                if index == 4 then
                    self:onAniGold(500)
                else
                    self:onAniGold(420)
                end
            end)
        )
    )
end

function GameViewLayer:onAniStopWin()
    for i = 1, 4 do
        self.m_pNodeWin[i]:stopAllActions()
        self.m_pNodeWin[i]:setScale(0)
        
        self.m_pNodeWin[i].light:stopAllActions()
        self.m_pNodeWin[i].light:setRotation(0)
        
        self.m_pNodeWin[i].score:stopAllActions()
        self.m_pNodeWin[i].score:setString("0")
    end
end

function GameViewLayer:onAniGold(posY)
    local gold = display.newSprite("#tiger_ani_gold1.png")
    gold:setPosition(667, posY)
    gold:setTag(GameViewLayer.TAG_ANI_GOLD)
    self:addChild(gold)
    local animation = cc.Animation:create()
    for i = 1, 7 do
        local frameName = string.format("tiger_ani_gold%d.png", i)
        local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
        animation:addSpriteFrame(spriteFrame)
    end  
    animation:setDelayPerUnit(0.1)          -- 设置两个帧播放时间    
    local action = cc.Animate:create(animation)
    gold:runAction(cc.Sequence:create(action, cc.DelayTime:create(0.5), cc.CallFunc:create(function() self:onAniStopWin() end), cc.RemoveSelf:create()))
end

function GameViewLayer:onAniStopGold()
    local gold = self:getChildByTag(GameViewLayer.TAG_ANI_GOLD)
    if gold then
        gold:stopAllActions()
        gold:removeFromParent()
    end
end

-- 中将提示
function GameViewLayer:onAniShowTips()
    self.m_pIconTip:setVisible(true)
    self.m_pIconTip:setOpacity(50)
    self.m_pIconTip:setPosition(cc.p(655, 200))
    self.m_pIconTip:runAction(
        cc.Spawn:create(
            cc.FadeIn:create(0.3),
            cc.MoveTo:create(0.3, cc.p(655, 241))
        )
    )
end

function GameViewLayer:onAniStopTips()
    self.m_pIconTip:setVisible(false)
    self.m_pIconTip:stopAllActions()
    self.m_pIconTip:removeAllChildren()
end

-- 放大中奖水果
function GameViewLayer:onAniShowGoods()
    local ptZhongJiang = {}
    local curPosX = 80
    local curWidth = 100
    local isShow = false

    local ptAniArray = {}
    for i = 1, 5 do
        ptAniArray[i] = {}
        for j = 1, 3 do
            ptAniArray[i][j] = 0
        end
    end

    for i = 1, self.m_pTextLine.number do
        ptZhongJiang = {}
        GameLogic:GetZhongJiangXian(self.m_cbItemInfo, i, ptZhongJiang)
        if self.m_cbResultType[i] ~= 0xFF then
            -- 设置中奖水果
            for i = 1, 5 do
                if ptZhongJiang[i].x ~= 0xFF and ptZhongJiang[i].y ~= 0xFF then
                    ptAniArray[ptZhongJiang[i].y][g_var(cmd).ITEM_Y_COUNT-ptZhongJiang[i].x+1] = 1
                end
            end

            -- 连线
            self:onAniWinLine(i)

            -- 创建水果以数字
            local item = display.newSprite(string.format("#tiger_game_icon_goods%d.png", self.m_cbResultType[i]+1))
            item:setPosition(cc.p(curPosX, 24))
            item:setScale(0.4)
            self.m_pIconTip:addChild(item)
            curPosX = curPosX + 30
            curWidth = curWidth + 60

            local num = ccui.Text:create(string.format("x%d", self.m_cbResultMultiple[i]), appdf.FONT_FILE, 25)
            num:setPosition(cc.p(curPosX, 20))
            num:setAnchorPoint(cc.p(0, 0.5))
            self.m_pIconTip:addChild(num)
            curPosX = curPosX + num:getContentSize().width + 40
            curWidth = curWidth + num:getContentSize().width + 10

            isShow = true
        end
    end

    if isShow then
        self.m_pIconTip:setContentSize(cc.size(curWidth, self.m_pIconTip:getContentSize().height))
        self:onAniShowTips()
    end

    local winTime = 0.5
    if self.m_lWinScore > 0 then
        local chipScore = self.m_pTextLine.number * self.m_lTableScore
        local winIndex = 1
        if self.m_lWinScore >= chipScore * 10 then
            winIndex = 3
        elseif self.m_lWinScore >= chipScore * 5 then
            winIndex = 2
        end
        self:onAniShowWin(winIndex, self.m_lWinScore)
        
        self:setWinScore(self.m_pTextWinScore.number + self.m_lWinScore)
        self:setUserScore(self.m_pTextScore.number + self.m_lWinScore)
        self.m_lWinScore = 0
        winTime = 1
    end
    
    for i = 1, g_var(cmd).ITEM_X_COUNT do
        for k, v in pairs(self.m_tagGoodsArray[i]) do
            if v.index > 0 and v.index <= 3 then
                if ptAniArray[i][v.index] == 1 then
                    v:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.5, 1.2), cc.ScaleTo:create(0.5, 1))))
                end
            end
        end
    end

    self:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(winTime), 
            cc.CallFunc:create(function() 
                self:setGameStatus(GameViewLayer.GAME_STATUS_FREE)
                if self.m_bIsAuto then
                    self:onButtonEventStart()
                end
            end)
        )
    )
end

-- 停止播放水果动画
function GameViewLayer:onAniStopGoods()
    for i = 1, g_var(cmd).ITEM_X_COUNT do
        for k, v in pairs(self.m_tagGoodsArray[i]) do
            v:stopAllActions()
            v:setScale(1)
        end
    end
end

-- 绘画连线
function GameViewLayer:onAniShowLine(count)
    if count < 1 or count > g_var(cmd).LINE_COUNT then
        return
    end
    for i = 1, g_var(cmd).LINE_COUNT do
        if i <= count then
            if self.m_tagLine[i]:getNumberOfRunningActions() == 0 then
                self.m_tagLine[i]:runAction(cc.ProgressTo:create(0.2, 100))
            end
        else
            self.m_tagLine[i]:stopAllActions()
            self.m_tagLine[i]:setPercentage(0)
        end
    end
end

-- 隐藏连线
function GameViewLayer:onAniHideLine()
    for i = 1, g_var(cmd).LINE_COUNT do
        self.m_tagLine[i]:stopAllActions()
        self.m_tagLine[i]:setPercentage(0)
    end
end

-- 中奖连线
function GameViewLayer:onAniWinLine(index)
    local time = 0.2
    self.m_tagLineLight[index]:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(0.5), cc.FadeOut:create(0.5))))
    self.m_tagLineLight[index + 9]:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(0.5), cc.FadeOut:create(0.5))))
    self.m_tagLine[index]:runAction(cc.ProgressTo:create(time, 100))
end

-- 清除中奖连线
function GameViewLayer:onAniStopWinLine()
    for i = 1, g_var(cmd).LINE_COUNT do
        self.m_tagLineLight[i]:stopAllActions()
        self.m_tagLineLight[i + 9]:stopAllActions()
        self.m_tagLine[i]:stopAllActions()
        self.m_tagLineLight[i]:setOpacity(0)
        self.m_tagLineLight[i + 9]:setOpacity(0)
        self.m_tagLine[i]:setPercentage(0)
    end
    
end

-- 跑马灯全亮
function GameViewLayer:onAniLightAllOn()
    for i = 1, g_var(cmd).POINT_COUNT do
        self.m_pPointArray[i]:stopAllActions()
        self.m_pPointArray[i]:setVisible(true)
    end
end

-- 跑马灯全暗
function GameViewLayer:onAniLightAllOff()
    for i = 1, g_var(cmd).POINT_COUNT do
        self.m_pPointArray[i]:stopAllActions()
        self.m_pPointArray[i]:setVisible(false)
    end
end

-- 跑马灯动画1
function GameViewLayer:onAniLight1()
    self:onAniLightAllOn()
    local showCount = 10000             -- 跑马灯闪烁次数
    local showTime = 0.2                -- 跑马灯闪烁间隔 数值越小速度越快
    for i = 1, g_var(cmd).POINT_COUNT do
        if i % 2 == 1 then
            self.m_pPointArray[i]:runAction(cc.Blink:create(showCount*showTime*2, showCount))
        else
            self.m_pPointArray[i]:runAction(cc.Sequence:create(cc.DelayTime:create(showTime), cc.Blink:create(showCount*showTime*2, showCount)))
        end
    end
end

-- 跑马灯动画2
function GameViewLayer:onAniLight2()
    self:onAniLightAllOff()
    local showTime = 1
    local gapTime = 0.05
    for i = 1, g_var(cmd).POINT_COUNT/2 do
        self.m_pPointArray[i]:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(i * gapTime), 
                cc.Show:create(), 
                cc.DelayTime:create(showTime), 
                cc.Hide:create(),
                cc.DelayTime:create((g_var(cmd).POINT_COUNT/2 - i) * gapTime * 2),
                cc.Show:create()
            )
        )
        self.m_pPointArray[g_var(cmd).POINT_COUNT-i+1]:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(i * gapTime), 
                cc.Show:create(), 
                cc.DelayTime:create(showTime), 
                cc.Hide:create(),
                cc.DelayTime:create((g_var(cmd).POINT_COUNT/2 - i) * gapTime * 2),
                cc.Show:create()
            )
        )
    end
end

-- 滚动物品
function GameViewLayer:onAniRoll()
    --------------- 清除多余物品
    for i = 1, g_var(cmd).ITEM_X_COUNT do
        for k, v in pairs(self.m_tagGoodsArray[i]) do
            if v.index == 0 then
                v:removeFromParent()
            else
                v.index = 0
            end
        end
    end
    
    self.m_tagGoodsArray = {}
    for i = 1, g_var(cmd).ITEM_X_COUNT do
        self.m_tagGoodsArray[i] = {}
    end

    for k, v in pairs(self.m_pNodeGoods:getChildren()) do
        table.insert(self.m_tagGoodsArray[v.line], v)
    end

    --------------- 新建物品
    local item = nil            -- 水果
    local index = 0             -- 是否为显示的水果
    local itemCount = 0         -- 当前列的创建水果数
    local itemIndex = 0

    for i = 1, g_var(cmd).ITEM_X_COUNT do
        itemCount = GameViewLayer.GOODS_COUNT[i]
        for j = 1, itemCount do
            if j >= itemCount - 3 and j < itemCount then
                index = j - (itemCount - 3) + 1
                local indexArray = self.m_cbItemInfo[g_var(cmd).ITEM_Y_COUNT - index + 1]
                itemIndex = indexArray[i] + 1
            else
                index = 0
                itemIndex = math.random(1, 11)
            end
            if itemIndex >= 1 and itemIndex <= 14 then
                item = display.newSprite(string.format("#tiger_game_icon_goods%d.png", itemIndex))
                item:setPosition(cc.p(GameViewLayer.GOODS_POS[i].x, GameViewLayer.GOODS_POS[i].y + GameViewLayer.GOODS_GAP * (j + 2)))
                item.index = index
                item.line = i
                table.insert(self.m_tagGoodsArray[i], item)
                self.m_pNodeGoods:addChild(item)
            else
                print("m_cbItemInfo数据错误")
            end
        end
    end
    -- 配置参数
    self.m_tagRollPath = {  GameViewLayer.ROLL_STATUS_DOWN, 
                            GameViewLayer.ROLL_STATUS_DOWN, 
                            GameViewLayer.ROLL_STATUS_DOWN, 
                            GameViewLayer.ROLL_STATUS_DOWN, 
                            GameViewLayer.ROLL_STATUS_DOWN} -- 滚动方向 
    self.m_fRollSpeed = 1                                   -- 初始滚动速度
    self:onUpdateRollOpen()
end

-- 快速停止滚动
function GameViewLayer:onAniStopRoll()
    if self.m_tagRollPath[1] == GameViewLayer.ROLL_STATUS_DOWN then
        -- 计算间隔距离
        local item = self.m_tagGoodsArray[1][(#self.m_tagGoodsArray[1] - 3)]
        local gap = item:getPositionY() - (GameViewLayer.GOODS_POS[1].y + GameViewLayer.GOODS_GAP * 3)
        if gap < 0 then
            gap = 0
        end

        -- 修正其他行的差距
        for i = 1, g_var(cmd).ITEM_X_COUNT do
            for k, v in pairs(self.m_tagGoodsArray[i]) do
                v:setPosition(cc.p(v:getPositionX(), v:getPositionY() - (GameViewLayer.GOODS_COUNT[i] - GameViewLayer.GOODS_COUNT[1]) * GameViewLayer.GOODS_GAP - gap))
            end
        end
    end
end

-- 分数变化动画
function GameViewLayer:onAniChangeScore(item, score)
    item.tarScore = score
    item:stopAllActions()
    item:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
                cc.DelayTime:create(0.01), 
                cc.CallFunc:create(function()
                    local score = tonumber(item:getString())
                    if type(score) ~= "number" then
                        item:stopAllActions()
                        return
                    end
                    if score ~= item.tarScore then
                        score = self:getNumber(score, item.tarScore)
                        item:setString(tostring(score))
                    else
                        item:stopAllActions()
                    end
                end)
            )
        )
    )
end

-- 彩金池数字动画
function GameViewLayer:onAniChangeGoldPool(score)
    local item = nil
    local runTime = 0.3
    local delay = 0
    for i = 1, 12 do
        item = self.m_tagGoldPool[i]
        parScore = math.pow(10, (i - 1))
        curBits = tonumber(item:getString())
        tarBits = math.floor(score / parScore) % 10
        if curBits ~= tarBits then
            delay = math.random(0, 10) / 100
            item.score = tarBits

            local temp = ccui.TextAtlas:create(tostring(tarBits), "game/tiger_number_2.png", 26, 39, "0")
            temp:setPosition(cc.p(item:getPositionX(), item:getPositionY() - 40))
            self.m_pNodeGoldPoolScore:addChild(temp)
            temp:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(delay),
                    cc.MoveBy:create(runTime, cc.p(0, 40)),
                    cc.RemoveSelf:create()
                )
            )

            item:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(delay),
                    cc.MoveBy:create(runTime, cc.p(0, 40)),
                    cc.CallFunc:create(function(sender)
                        sender:setString(tostring(sender.score))
                        sender:setPosition(cc.p(sender:getPositionX(), sender:getPositionY() - 40))
                    end)
                )
            )
        end
    end
end

--------------------------------------------------------------- 发送消息 ---------------------------------------------------------------

--------------------------------------------------------------- 处理消息 ---------------------------------------------------------------
function GameViewLayer:onRecGameStart()
    self:setGameStatus(GameViewLayer.GAME_STATUS_PLAY)
    self:onAniStopWinLine()         -- 隐藏连线
    self:onAniStopGoods()
    self:onAniStopTips()
    self:onAniStopWin()
    self:onAniStopGold()
    self:onAniRoll()                -- 开始滚动
end

--------------------------------------------------------------- 测试函数 ---------------------------------------------------------------
function GameViewLayer:getGoodsName(index)
    if index == 1 then
        return "樱桃"
    elseif index == 2 then
        return "苹果"
    elseif index == 3 then
        return "香蕉"
    elseif index == 4 then
        return "橘子"
    elseif index == 5 then
        return "菠萝"
    elseif index == 6 then
        return "西瓜"
    elseif index == 7 then
        return "葡萄"
    elseif index == 8 then
        return "荔枝"
    elseif index == 9 then
        return "草莓"
    elseif index == 10 then
        return "山竹"
    elseif index == 11 then
        return "七七"
    elseif index == 12 then
        return "大王"
    elseif index == 13 then
        return "钻石"
    elseif index == 14 then
        return "宝箱"
    end

    return "   "
end

function GameViewLayer:getNumber(curScore, tarScore)
    local curBits = 0
    local tarBits = 0
    local resultScore = 0
    local parScore = 0
    if curScore < tarScore then
        for i = 1, 20 do
            parScore = math.pow(10, (i - 1))
            curBits = math.floor(curScore / parScore) % 10
            tarBits = math.floor(tarScore / parScore) % 10
            if curBits ~= tarBits then
                resultScore = curScore + parScore
                if resultScore <= tarScore then
                    return resultScore
                end
            end
        end
    else
        local j = 20
        for i = 1, 20 do
            j = 20 - i + 1
            parScore = math.pow(10, (j - 1))
            curBits = math.floor(curScore / parScore) % 10
            tarBits = math.floor(tarScore / parScore) % 10
            resultScore = curScore - parScore
            if resultScore >= tarScore then
                return resultScore
            end
        end
    end
end

return GameViewLayer