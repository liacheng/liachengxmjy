local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)

local module_pre = "game.yule.oxex.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local cmd = appdf.req(appdf.GAME_SRC.."yule.oxex.src.models.CMD_Game")
local PopupInfoHead = appdf.req("client.src.external.PopupInfoHead")
local GameChatLayer = appdf.req(appdf.PUB_GAME_VIEW_SRC.."GameChatLayer")
local HelpLayer = appdf.req(module_pre .. ".views.layer.HelpLayer")
local SettingLayer = appdf.req(module_pre .. ".views.layer.GameSetLayer")
local GameSystemMessage = require(appdf.EXTERNAL_SRC .. "GameSystemMessage")
GameViewLayer.TAG_GAMESYSTEMMESSAGE = 6751

GameViewLayer.BT_PROMPT 			= 2
GameViewLayer.BT_OPENCARD 			= 3
GameViewLayer.BT_START 				= 4
GameViewLayer.BT_CALLBANKER 		= 5
GameViewLayer.BT_CANCEL 			= 6
GameViewLayer.BT_CHIP 				= 7
GameViewLayer.BT_CHIP1 				= 8
GameViewLayer.BT_CHIP2 				= 9
GameViewLayer.BT_CHIP3 				= 10
GameViewLayer.BT_CHIP4 				= 11

GameViewLayer.BT_SWITCH 			= 12
GameViewLayer.BT_SET 				= 13
GameViewLayer.BT_CHANGE 			= 14
GameViewLayer.BT_CHAT 				= 15
GameViewLayer.BT_EXPLAIN 			= 16
GameViewLayer.BT_HELP 				= 17
GameViewLayer.BT_EXIT 				= 18
--GameViewLayer.BT_SOUND 				= 15
--GameViewLayer.BT_TAKEBACK 			= 16

GameViewLayer.FRAME 				= 1
GameViewLayer.NICKNAME 				= 2
GameViewLayer.SCORE 				= 3
GameViewLayer.READY 				= 4
GameViewLayer.BGANTE                = 5
GameViewLayer.ANTE                  = 6
GameViewLayer.FACE 					= 7

GameViewLayer.TIMENUM   			= 1
GameViewLayer.CHIPNUM 				= 1
GameViewLayer.SCORENUM 				= 1
GameViewLayer.SCOREWIN 				= 1
GameViewLayer.SCORELOSE 			= 2
GameViewLayer.WINLOSELIGHT          = 1
GameViewLayer.WINLOSETITLE          = 2 
GameViewLayer.WINLOSETAB            = 3 
GameViewLayer.WINLOSESCOREWIN       = 4
GameViewLayer.WINLOSESCORELOSE      = 5
--牌间距
--GameViewLayer.CARDSPACING 			= 35
GameViewLayer.CARDSPACING 			= 50

GameViewLayer.VIEWID_CENTER 		= 5
--层级
GameViewLayer.ORDER_1               = 1         --下注数和金币层
GameViewLayer.ORDER_2               = 2         --卡牌层
GameViewLayer.ORDER_3               = 3         --牌型和时钟层
GameViewLayer.ORDER_4               = 4         --开始按钮层
GameViewLayer.ORDER_5               = 5         --结算层
GameViewLayer.ORDER_6               = 6
GameViewLayer.ORDER_SET             = 9         
GameViewLayer.ORDER_HELP            = 10 

GameViewLayer.RES_PATH 				= "game/yule/oxex/res/"

GameViewLayer.TAG_CLOCK             = 100

local pointMovePlayer = {cc.p(430, -100),cc.p(476, 850)}
local pointPlayer = {cc.p(430, 124), cc.p(476, 616)}
local pointCard = {cc.p(565, 128), cc.p(600, 615)}
local pointReady = {}
local pointClock = {}
local pointOpenCard = {cc.p(675, 90), cc.p(710, 590)}
local pointOpenCardFlag ={}
local pointTableScore = {}
local rectTableGold = nil
local pointBankerFlag = {}
local pointState = {}
local pointChat = {cc.p(230, 250), cc.p(767, 690)}
local ptWinLoseAnimate = {}
local pointUserInfo = {cc.p(205, 170), cc.p(445, 240)}
local anchorPoint = {cc.p(0, 0), cc.p(1, 1)}
local ptWaitFlag = cc.p(667,500)

local AnimationRes = 
{
	{name = "start", file = GameViewLayer.RES_PATH.."animation/start_", nCount = 11, fInterval = 0.15, nLoops = 1},
    {name = "opencard", file = GameViewLayer.RES_PATH.."animation/oxex_effect_opencard", nCount = 3, fInterval = 0.07, nLoops = 1},
	{name = "addscore", file = GameViewLayer.RES_PATH.."animation/oxex_effect_chip", nCount = 5, fInterval = 0.15, nLoops = 1},
	{name = "win", file = GameViewLayer.RES_PATH.."animation/oxex_effect_win", nCount = 8, fInterval = 0.15, nLoops = 1},
}

function GameViewLayer:onInitData()
	self.bCardOut = {false, false, false, false, false}
	self.lUserMaxScore = {0, 0, 0, 0}
	self.chatDetails = {}
	self.cbGender = {}
	self.bCanMoveCard = false
	self.bBtnInOutside = false
    self.bExplainInOutside = false
end

function GameViewLayer:onExit()
	print("GameViewLayer onExit")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game/card.png")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("oxex_all.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("oxex_all.png")
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()  
end

function GameViewLayer:SetGameNode()
    --玩家状态节点
    pointState = {}
    local StateNode = self._csbNode:getChildByName("m_pstate_node")
    for i = 1 ,cmd.GAME_PLAYER do
        local _StateNode = StateNode:getChildByName("m_node_"..i)
        local x,y = _StateNode:getPosition();
        table.insert(pointState,cc.p(x,y))
    end 
    --玩家准备节点
    pointReady = {}
    local ReadyNode = self._csbNode:getChildByName("m_ready_node")
    for i = 1 ,cmd.GAME_PLAYER do
        local _ReadyNode = ReadyNode:getChildByName("m_node_"..i)
        local x,y = _ReadyNode:getPosition();
        table.insert(pointReady,cc.p(x,y))
    end 
    --时钟节点
    pointClock = {}
    local ClockNode = self._csbNode:getChildByName("m_clock_node")
    for i = 1 ,cmd.GAME_PLAYER do
        local _ClockNode = ClockNode:getChildByName("m_node_"..i)
        local x,y = _ClockNode:getPosition();
        table.insert(pointClock,cc.p(x,y))
    end 
    --庄家节点
    pointBankerFlag = {}
    local BankerFlagNode = self._csbNode:getChildByName("m_banker_node")
    for i = 1 ,cmd.GAME_PLAYER do
        local _BankerFlagNode = BankerFlagNode:getChildByName("m_node_"..i)
        local x,y = _BankerFlagNode:getPosition();
        table.insert(pointBankerFlag,cc.p(x,y))
    end 
    --桌面分数节点
    pointTableScore = {}
    local TableScoreNode = self._csbNode:getChildByName("m_tablescore_node")
    for i = 1 ,cmd.GAME_PLAYER do
        local _TableScoreNode = TableScoreNode:getChildByName("m_node_"..i)
        local x,y = _TableScoreNode:getPosition();
        table.insert(pointTableScore,cc.p(x,y))
    end 
    --摊牌标志节点
    pointOpenCardFlag = {}
    local OpenCardFlagNode = self._csbNode:getChildByName("m_opecard_node")
    for i = 1 ,cmd.GAME_PLAYER do
        local _OpenCardFlagNode = OpenCardFlagNode:getChildByName("m_node_"..i)
        local x,y = _OpenCardFlagNode:getPosition();
        table.insert(pointOpenCardFlag,cc.p(x,y))
    end 
    --桌面分数区域
    rectTableGold = nil
    local x = (yl.DESIGN_WIDTH/2)-90;                          
    local y = (yl.DESIGN_HEIGHT/2)-60;                          
    local w = 90*2;                        
    local h = 60*2;                            
    rectTableGold = cc.rect(x, y, w, h)
    --结算分数节点
    ptWinLoseAnimate = {}
    local WinLoseNode = self._csbNode:getChildByName("m_score_node")
    for i = 1 ,cmd.GAME_PLAYER do
        local _WinLoseNode = WinLoseNode:getChildByName("m_node_"..i)
        local x,y = _WinLoseNode:getPosition();
        table.insert(ptWinLoseAnimate,cc.p(x,y))
    end 
end
local this
function GameViewLayer:ctor(scene)
	this = self
	self._scene = scene
	self:onInitData()
	self:preloadUI()	

    self.m_pUserItem_ = self._scene._gameFrame:GetMeUserItem()
    self.m_nTableID = self.m_pUserItem_.wTableID
    self.m_nChairID = self.m_pUserItem_.wChairID

	--节点事件
	ExternalFun.registerNodeEvent(self) -- bind node event

	local  btcallback = function(ref, type)
        ExternalFun.btnEffect(ref, type)
        if type == ccui.TouchEventType.ended then
            ExternalFun.playSoundEffect("oxex_click.mp3")
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end
    self._csbNode = cc.CSLoader:createNode(GameViewLayer.RES_PATH.."game/GameScene.csb")
    	:addTo(self, 1)
    --获得节点pos
    self:SetGameNode()

    self.spButtonBg = display.newSprite("#oxex_bg_btnlist.png")
        :setPosition(cc.p(60,662))   
        :setAnchorPoint(cc.p(0.25, 1))
        :setScale(0)
        :setLocalZOrder(GameViewLayer.ORDER_6)
        :addTo(self) 

    self.btExit = ccui.Button:create("oxex_btn_back_normal.png","oxex_btn_back_normal.png","",ccui.TextureResType.plistType)
        :setPosition(cc.p(119,338))
        :setTag(GameViewLayer.BT_EXIT)
        :addTo(self.spButtonBg)
    self.btExit:addTouchEventListener(btcallback)

    self.btChange = ccui.Button:create("oxex_btn_changetable_normal.png","oxex_btn_changetable_normal.png","",ccui.TextureResType.plistType)
        :setPosition(cc.p(119,254))
        :setTag(GameViewLayer.BT_CHANGE)
        :addTo(self.spButtonBg)
    self.btChange:addTouchEventListener(btcallback)

    self.btHelp = ccui.Button:create("oxex_btn_help_normal.png","oxex_btn_help_normal.png","",ccui.TextureResType.plistType)
        :setPosition(cc.p(119,168))
        :setTag(GameViewLayer.BT_HELP)
        :addTo(self.spButtonBg)
    self.btHelp:addTouchEventListener(btcallback)

    self.btSet = ccui.Button:create("oxex_btn_setting_normal.png","oxex_btn_setting_normal.png","",ccui.TextureResType.plistType)
        :setPosition(cc.p(119,77))
        :setTag(GameViewLayer.BT_SET)
        :addTo(self.spButtonBg)
    self.btSet:addTouchEventListener(btcallback)

    self.btSwitch = self._csbNode:getChildByName("m_btn_down")
		:setTag(GameViewLayer.BT_SWITCH)
	self.btSwitch:addTouchEventListener(btcallback)
    
    self.spExplainBg = display.newSprite("#oxex_btn_explain_normal.png")
		:setPosition(cc.p(201,662))   
        :setAnchorPoint(cc.p(0.38, 1))
        :setScale(0)
        :setLocalZOrder(GameViewLayer.ORDER_6)
        :addTo(self) 
    local spspExplain = display.newSprite("#oxex_bg_explain.png")  
        :setPosition(cc.p(261,236))   
        :addTo(self.spExplainBg)

    self.btExplain = self._csbNode:getChildByName("m_btn_explain")
		:setTag(GameViewLayer.BT_EXPLAIN)
	self.btExplain:addTouchEventListener(btcallback)

    -- 底注
    --self.tabCellScore = self._csbNode:getChildByName("m_text_cellscore")

	--普通按钮   
    self.btStart = ccui.Button:create("oxex_btn_yellow_normal.png","oxex_btn_yellow_normal.png","",ccui.TextureResType.plistType)
        :setPosition(yl.DESIGN_WIDTH /2 , yl.DESIGN_HEIGHT/4)
        :setVisible(false)
        :setLocalZOrder(GameViewLayer.ORDER_4)
        :setTag(GameViewLayer.BT_START)
        :addTo(self)
    self.btStart:addTouchEventListener(btcallback)
    local tabStart = display.newSprite("#oxex_btntab_ready.png")
        :setPosition(self.btStart:getContentSize().width/2,self.btStart:getContentSize().height/2)
        :addTo(self.btStart)

    self.btOpenCard = self._csbNode:getChildByName("m_btnopencard")
		:setTag(GameViewLayer.BT_OPENCARD)
		:setVisible(false)
	self.btOpenCard:addTouchEventListener(btcallback)

    self.btCallBanker = self._csbNode:getChildByName("m_btncallbanker")
		:setTag(GameViewLayer.BT_CALLBANKER)
		:setVisible(false)
	self.btCallBanker:addTouchEventListener(btcallback)

	self.btCancel = self._csbNode:getChildByName("m_btnuncallbanker")
		:setTag(GameViewLayer.BT_CANCEL)
		:setVisible(false)
	self.btCancel:addTouchEventListener(btcallback)

	--四个下注的筹码按钮
    self.btChip = {}
	for i = 1, 4 do
		self.btChip[i] = self._csbNode:getChildByName("m_btnchip"..i)
			:setTag(GameViewLayer.BT_CHIP + i)
			:setVisible(false)
		self.btChip[i]:addTouchEventListener(btcallback)
        local textChip = self.btChip[i]:getChildByName("m_text_chip")
            :setFontName("fonts/round_body.ttf")
			:setTag(GameViewLayer.CHIPNUM)
	end

	--时钟
	self.spriteClock = display.newSprite("#oxex_bg_clock.png")
		:setVisible(false)
        :setLocalZOrder(GameViewLayer.ORDER_2)
		:addTo(self)
	local labAtTime = ccui.Text:create("", "", 32)
        :setColor(cc.c3b(197, 0, 0))
		:setPosition(self.spriteClock:getContentSize().width/2, self.spriteClock:getContentSize().height/2-6)
		:setAnchorPoint(cc.p(0.5, 0.5))
		:setTag(GameViewLayer.TIMENUM)
		:addTo(self.spriteClock)

	--用于发牌动作的那张牌
	self.animateCard = display.newSprite(GameViewLayer.RES_PATH.."card.png")
		:move(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2)
		:setVisible(false)
		:setLocalZOrder(GameViewLayer.ORDER_2)
		:addTo(self)
	local cardWidth = self.animateCard:getContentSize().width/13
	local cardHeight = self.animateCard:getContentSize().height/5
	self.animateCard:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))

    --游戏状态节点
    local gStetaNode = self._csbNode:getChildByName("m_gstate_node")

    self.gStateWait = gStetaNode:getChildByName("m_gwait")              --等待游戏开始
        :setVisible(false)
    self.gCbSelf = gStetaNode:getChildByName("m_gcallbanker_self")      --自己叫庄
        :setFontName("fonts/round_body.ttf")
        :setVisible(false)
    self.gCbOther = gStetaNode:getChildByName("m_gcallbanker_other")    --其他玩家叫庄
        :setFontName("fonts/round_body.ttf")
        :setVisible(false)
    self.gBetsSelf = gStetaNode:getChildByName("m_gbets_self")          --自己下注
        :setFontName("fonts/round_body.ttf")
        :setVisible(false)
    self.gBetsOther = gStetaNode:getChildByName("m_gbets_other")        --其他玩家下注
        :setFontName("fonts/round_body.ttf")
        :setVisible(false)   
    self.gAntiCheatWait = gStetaNode:getChildByName("m_ganticheatwait")
        :setFontName("fonts/round_body.ttf")
        :setVisible(false)   
    --玩家状态
    self.pStateCbing = self._csbNode:getChildByName("m_callbankering")  --叫庄
        :setVisible(false)
    self.pStateBets = self._csbNode:getChildByName("m_bets")   --下注
        :setVisible(false)

	--四个玩家
    self.nodePlayer = {}
    self.pStateReady = {}
    self.pStateOpenCard = {}
    for i = 1,cmd.GAME_PLAYER do
        --玩家结点 
        self.nodePlayer[i] = self._csbNode:getChildByName("m_player"..i)
            :setVisible(false)
        --昵称
        local textName = self.nodePlayer[i]:getChildByName("m_text_name")
            :setFontName("fonts/round_body.ttf")
            :setTag(GameViewLayer.NICKNAME)
        --游戏币
        local textScore = self.nodePlayer[i]:getChildByName("m_text_gold")
            :setFontName("fonts/round_body.ttf")
            :setTag(GameViewLayer.SCORE)
        --准备状态
        self.pStateReady[i] = display.newSprite("#oxex_icon_ready.png")
            :setVisible(false)
            :setPosition(pointReady[i])
            :addTo(self,GameViewLayer.ORDER_4)
        --摊牌状态
        self.pStateOpenCard[i] = display.newSprite("#oxex_icon_ready.png")
            :setVisible(false)
            :setPosition(pointOpenCardFlag[i])
            :addTo(self,GameViewLayer.ORDER_3)
    end
    
    --筹码缓存
	self.nodeChipPool = cc.Node:create()
        :setLocalZOrder(GameViewLayer.ORDER_1)
        :addTo(self)
    --玩家断线重连等待操作
    self.ShowWaitPlayer = {}
    self.IsShowWait = false
    self.m_WaitFlag = nil
	--牌节点
	self.nodeCard = {}
	--牌的类型
	self.cardType = {}
	--桌面游戏币
	self.tableScore = {}
    --结算分数
    self.endScore = {}
	for i = 1, cmd.GAME_PLAYER do
		--牌
		self.nodeCard[i] = cc.Node:create()
			:move(pointCard[i].x,pointPlayer[i].y)
            :setLocalZOrder(GameViewLayer.ORDER_2)
			:setAnchorPoint(cc.p(0.5, 0.5))
			:addTo(self)
		for j = 1, 5 do
			local card = display.newSprite(GameViewLayer.RES_PATH.."card.png")
				:setTag(j)
                :setVisible(false)
				:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))
				:addTo(self.nodeCard[i])
		end
		--牌型
		self.cardType[i] = cc.Node:create()
			:setPosition(pointOpenCard[i])
            :setLocalZOrder(GameViewLayer.ORDER_3)
			:setVisible(false)
			:addTo(self)

        self.tableScore[i] = display.newSprite("#oxex_icon_addimg.png")
			:setPosition(pointTableScore[i])
			:setVisible(false)
            :setLocalZOrder(GameViewLayer.ORDER_1)
			:addTo(self)
		cc.LabelAtlas:_create("0", GameViewLayer.RES_PATH.."oxex_fonts_num_normal.png", 27, 36, string.byte("*"))
			:setPosition(self.tableScore[i]:getContentSize().width+15,self.tableScore[i]:getContentSize().height/2)
            :setAnchorPoint(cc.p(0, 0.5))
			:setTag(GameViewLayer.SCORENUM)
			:addTo(self.tableScore[i])
        --结算分数
        self.endScore[i] = display.newSprite()
            :setPosition(ptWinLoseAnimate[i])
            :setVisible(false)
            :setLocalZOrder(GameViewLayer.ORDER_5)
            :addTo(self)
        local endScoreImg = display.newSprite("#oxex_icon_addimg.png")
            :setPosition(0,30)
            :addTo(self.endScore[i])
        cc.LabelAtlas:_create("0", GameViewLayer.RES_PATH.."oxex_fonts_num_win.png", 45, 54, string.byte("/"))
            :setPosition(50,30)
            :setAnchorPoint(cc.p(0, 0.5))
            :setTag(GameViewLayer.SCOREWIN)
            :addTo(self.endScore[i])
        cc.LabelAtlas:_create("0", GameViewLayer.RES_PATH.."oxex_fonts_num_lose.png", 45, 54, string.byte("/"))
            :setPosition(50,30)
            :setAnchorPoint(cc.p(0, 0.5))
            :setTag(GameViewLayer.SCORELOSE)
            :addTo(self.endScore[i])
        --等待操作
        self.ShowWaitPlayer[i] = false
	end
    --胜利失败动画
--    self.WinLose = display.newSprite("#oxex_bg_endbg_fail.png")
--        :setPosition(yl.DESIGN_WIDTH /2, yl.DESIGN_HEIGHT/2)
--        :setVisible(false)
--        :setLocalZOrder(GameViewLayer.ORDER_5)
--        :addTo(self)
--    local WinLoseLight = display.newSprite("#oxex_bg_endlightbg_fail.png")
--        :setLocalZOrder(-2)
--        :setPosition(self.WinLose:getContentSize().width/2,self.WinLose:getContentSize().height/2)
--        :setTag(GameViewLayer.WINLOSELIGHT)
--        :addTo(self.WinLose)
--    local WinLoseTitle = display.newSprite("#oxex_icon_lose.png")
--        :setPosition(self.WinLose:getContentSize().width/2,self.WinLose:getContentSize().height/2+15)
--        :setTag(GameViewLayer.WINLOSETITLE)
--        :addTo(self.WinLose)
--    local WinLoseTab = display.newSprite("#oxex_bg_endtextbg_fail.png")
--        :setLocalZOrder(-1)
--        :setPosition(self.WinLose:getContentSize().width/2,self.WinLose:getContentSize().height/2-20)
--        :setTag(GameViewLayer.WINLOSETAB)
--        :addTo(self.WinLose)
--    local WinLoseGold = display.newSprite("#oxex_icon_gold_normal.png")
--        :setPosition(WinLoseTab:getContentSize().width/2-80,WinLoseTab:getContentSize().height/2)
--        :addTo(WinLoseTab)
--    cc.LabelAtlas:_create(".0000000", GameViewLayer.RES_PATH.."oxex_fonts_num_win.png", 27, 36, string.byte("*"))
--        :setPosition(WinLoseTab:getContentSize().width/2-50,WinLoseTab:getContentSize().height/2)
--        :setAnchorPoint(cc.p(0, 0.5))
--        :setTag(GameViewLayer.WINLOSESCOREWIN)
--        :setVisible(false)
--        :addTo(WinLoseTab)
--    cc.LabelAtlas:_create("/0000000", GameViewLayer.RES_PATH.."oxex_fonts_num_lose.png", 27, 36, string.byte("*"))
--        :setPosition(WinLoseTab:getContentSize().width/2-50,WinLoseTab:getContentSize().height/2)
--        :setAnchorPoint(cc.p(0, 0.5))
--        :setTag(GameViewLayer.WINLOSESCORELOSE)
--        :setVisible(false)
--        :addTo(WinLoseTab)
    

	self.nodeLeaveCard = cc.Node:create():addTo(self)

    -- 玩家头像
	self.m_bNormalState = {}
    
    --庄家标志
    self.spriteBankerFlag = self._csbNode:getChildByName("m_banker")
        :setVisible(false)
    self.spriteRemainBankerFlag = self.spriteBankerFlag:getChildByName("m_remainbanker")
        :setVisible(false)
    self.textRemainBanker = self.spriteRemainBankerFlag:getChildByName("spriteRemainBankerFlag")

    self.btnChat = self._csbNode:getChildByName("m_btnchat")
    self.btnChat:setTag(GameViewLayer.BT_CHAT)
    self.btnChat:addTouchEventListener(btcallback)

	--聊天框
    self._chatLayer = GameChatLayer:create(self._scene._gameFrame)
    self._chatLayer:addTo(self)
	--聊天泡泡
	self.chatBubble = {}
	for i = 1 , cmd.GAME_PLAYER do
		if i == cmd.MY_VIEWID then
		    self.chatBubble[i] = display.newSprite(GameViewLayer.RES_PATH.."game_chat_lbg.png", {scale9 = true ,capInsets=cc.rect(0, 0, 180, 110)})
			    :setAnchorPoint(cc.p(0,0.5))
			    :move(pointChat[i])
			    :setVisible(false)
			    :addTo(self, 2)
		else
		    self.chatBubble[i] = display.newSprite(GameViewLayer.RES_PATH.."game_chat_rbg.png", {scale9 = true ,capInsets=cc.rect(0, 0, 180, 110)})
			    :setAnchorPoint(cc.p(1,0.5))
			    :move(pointChat[i])
			    :setVisible(false)
			    :addTo(self, 2)
		end
	end
	--点击事件
	self:setTouchEnabled(true)
	self:registerScriptTouchHandler(function(eventType, x, y)
		    if eventType == "ended" then
			    self:onEventTouchCallback(x, y)
		    end
		    return true
	    end)
    self:onResetView()
end

function GameViewLayer:onResetView(bStart)
	self.nodeLeaveCard:removeAllChildren()
    self.btStart:setPosition(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/4)
    self.spriteBankerFlag:stopAllActions()
	self.spriteBankerFlag:setVisible(false)
	--重排列牌
	local cardWidth = self.animateCard:getContentSize().width
	local cardHeight = self.animateCard:getContentSize().height
	for i = 1, cmd.GAME_PLAYER do
        local fScale = 1
        if i ~= cmd.MY_VIEWID then
            fScale = 0.8
        end
		self.nodeCard[i]:setContentSize(cc.size(fWidth, cardHeight))
        self.nodeCard[i]:removeAllChildren()
		for j = 1, 5 do
			local card = display.newSprite(GameViewLayer.RES_PATH.."card.png")
                :setPosition((j-1) *cardWidth/2, cardHeight/2)
                :setScale(fScale)
                :setLocalZOrder(1)
				:setTag(j)
				:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))
                :setVisible(false)
				:addTo(self.nodeCard[i])
		end
		self.tableScore[i]:setVisible(false)
		self.cardType[i]:setVisible(false)
        self.endScore[i]:setVisible(false)  
        if bStart ~= 1 then 
            self:setReadyVisible(i,false)
        end
        self:setOpenCardVisible(i, false)
        if bStart == nil then  
            self:OnUpdateUser(i,nil)
        end
	end
	self.bCardOut = {false, false, false, false, false}
	self.bBtnMoving = false
    self:stopAllClock()
    self:ClearTableGold()
    self.pStateCbing:setVisible(false)
    self.animateCard:stopAllActions()
    self.animateCard:setVisible(false)
    if self.pSpCard then 
        self.pSpCard:stopAllActions()
        self.pSpCard:setVisible(false)
    end
end

--更新用户显示
function GameViewLayer:OnUpdateUser(viewId, userItem)
	if not viewId or viewId == yl.INVALID_CHAIR then
		return
	end
	local head = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.FACE)
	if not userItem then
		self.nodePlayer[viewId]:setVisible(false)
        self:setReadyVisible(viewId,false)
		self.cbGender[viewId] = nil
		if head then
			head:setVisible(false)
		end
	else
		self.nodePlayer[viewId]:setVisible(true)
		self:setNickname(viewId, userItem.szNickName)
		self:setScore(viewId, userItem.lScore)
        self:setReadyVisible(viewId,yl.US_READY == userItem.cbUserStatus)
		self.cbGender[viewId] = userItem.cbGender
		if not head then
            local csbHead = self.nodePlayer[viewId]:getChildByName("m_pIconHead")     -- 头像处理
            local csbHeadX, csbHeadY = csbHead:getPosition()
            head = PopupInfoHead:createNormal(userItem, 90)
            local headBg = display.newSprite("#userinfo_head_frame.png")
            headBg:setPosition(cc.p(csbHeadX, csbHeadY))
            headBg:setScale(0.55,0.55)
	        head:setPosition(cc.p(csbHeadX, csbHeadY))
			head:enableHeadFrame(false)
			head:setTag(GameViewLayer.FACE)
            self.nodePlayer[viewId]:addChild(headBg)
			self.nodePlayer[viewId]:addChild(head)
            self.m_bNormalState[viewId] = true
		else
			head:updateHead(userItem)
		end
		head:setVisible(true)

        --掉线头像变灰
		if userItem.cbUserStatus == yl.US_OFFLINE then
			if self.m_bNormalState[viewId] then
				convertToGraySprite(head.m_head.m_spRender)
                self.ShowWaitPlayer[viewId] = true
			end
			self.m_bNormalState[viewId] = false
		else
			if not self.m_bNormalState[viewId] then
				convertToNormalSprite(head.m_head.m_spRender)
                self.ShowWaitPlayer[viewId] = false
			end
			self.m_bNormalState[viewId] = true
		end

        --自己准备后显示等待游戏开始
        if viewId == cmd.MY_VIEWID then  
            if yl.US_READY == userItem.cbUserStatus then    
                if self._scene._gameFrame.bEnterAntiCheatRoom == true and GlobalUserItem.isForfendGameRule() then 
                    self.gAntiCheatWait:setVisible(true)
                else
                    self.gStateWait:setVisible(true)  
                end
            else
                self.gStateWait:setVisible(false) 
                self.gAntiCheatWait:setVisible(false) 
            end      
        end
	end
end

--****************************      计时器        *****************************--
function GameViewLayer:OnUpdataClockView(viewId, time)
	if not viewId or viewId == yl.INVALID_CHAIR or not time then
		self.spriteClock:getChildByTag(GameViewLayer.TIMENUM):setString("")
		self.spriteClock:setVisible(false)
        if viewId ~= cmd.MY_VIEWID then 
            self:setWaitPlayer(true)
        end       
	else
		--self.spriteClock:getChildByTag(GameViewLayer.TIMENUM):setString(time)
        if self.IsShowWait == true then           
            self:setWaitPlayer(false)
        end
	end
end
function GameViewLayer:setHeadClock(viewid,time)
    if time == 0 then return end
    local resSprite = display.newSprite("#oxex_img_time.png")
    if viewid then 
        local playerNode = self.nodePlayer[viewid]
        if playerNode:getChildByTag(GameViewLayer.TAG_CLOCK) == nil then 
            ExternalFun.CreateHeadClock(resSprite,"oxex_time.plist",GameViewLayer.TAG_CLOCK,cc.p(66,88),playerNode,time,nil)
        end
    else
        for i = 1, cmd.GAME_PLAYER do
            local useritem = self._scene._gameFrame:getTableUserItem(self.m_nTableID,i-1)  
            if useritem then
                local viewID = self._scene:SwitchViewChairID(i-1)
                local playerNode = self.nodePlayer[viewID]
                if playerNode:getChildByTag(GameViewLayer.TAG_CLOCK) == nil then 
                    ExternalFun.CreateHeadClock(resSprite,"oxex_time.plist",GameViewLayer.TAG_CLOCK,cc.p(66,88),playerNode,time,nil)
                end
            end
        end
    end
end
function GameViewLayer:stopHeadClock(viewid)
    if viewid then         
        if viewid ~= yl.INVALID_CHAIR then 
            local playerNode = self.nodePlayer[viewid]
            ExternalFun.RemoveHeadClock(GameViewLayer.TAG_CLOCK,playerNode)
        else
            self:stopAllClock()
        end
    else
        self:stopAllClock()
    end
end
function GameViewLayer:stopAllClock()
    for i = 1, cmd.GAME_PLAYER do    
        local playerNode = self.nodePlayer[i]
        ExternalFun.RemoveHeadClock(GameViewLayer.TAG_CLOCK,playerNode)
    end
end
function GameViewLayer:setClockPosition(viewId)
	if viewId then
		self.spriteClock:setPosition(pointClock[viewId])
	else
		self.spriteClock:setPosition(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2)
	end
    self.spriteClock:setVisible(true)
end

function GameViewLayer:MoveHead()
    for i = 1 ,cmd.GAME_PLAYER do  
        local playerNode = self.nodePlayer[i]
        if playerNode:isVisible() then  
            playerNode:stopAllActions() 
            playerNode:setPosition(pointMovePlayer[i])    
            playerNode:runAction(cc.MoveTo:create(0.3,pointPlayer[i]))                    
        end
    end 
end

function GameViewLayer:setWaitPlayer(bShow)
    for k,v in pairs(self.ShowWaitPlayer) do 
        if bShow == true then 
            if v == true then 
                self:ViewWaitPlayer(bShow)
                return 
            end
        else
            self.ShowWaitPlayer[k] = bShow
            self:ViewWaitPlayer(bShow)
        end
    end
end

function GameViewLayer:ViewWaitPlayer(bShow)
    if self.m_WaitFlag == nil then 
        self.m_WaitFlag = ExternalFun.CreateWaitPlayerFlag(self)
        self.m_WaitFlag:setPosition(ptWaitFlag)
    end
    self.m_WaitFlag:setVisible(bShow)
    self.IsShowWait = bShow
end
--**************************      点击事件        ****************************--
--用于触发手牌的点击事件
function GameViewLayer:onEventTouchCallback(x, y)
	--按钮滚回
	if self.bBtnInOutside then
        local worldPos = self:convertToWorldSpace(cc.p(self.spButtonBg:getPositionX(), self.spButtonBg:getPositionY()))
        local cardBox = self.spButtonBg:getBoundingBox()
        cardBox.x = worldPos.x - (self.spButtonBg:getAnchorPoint().x * self.spButtonBg:getContentSize().width)
        cardBox.y = worldPos.y - (self.spButtonBg:getAnchorPoint().y * self.spButtonBg:getContentSize().height)
            
        if cc.rectContainsPoint(cardBox, cc.p(x, y)) == false then
		    self:onButtonSwitchAnimate()
        end
	end
    if self.bExplainInOutside then
        local worldPos = self._csbNode:convertToWorldSpace(cc.p(self.spExplainBg:getPositionX(), self.spExplainBg:getPositionY()))
        local cardBox = self.spExplainBg:getBoundingBox()
        cardBox.x = worldPos.x - (self.spExplainBg:getAnchorPoint().x * self.spExplainBg:getContentSize().width)
        cardBox.y = worldPos.y - (self.spExplainBg:getAnchorPoint().y * self.spExplainBg:getContentSize().height)
            
        if cc.rectContainsPoint(cardBox, cc.p(x, y)) == false then 
            self:onButtonExplainAnimate()
        end
	end
	-- --聊天框
	-- if self._chatLayer:isVisible() then
	-- 	self._chatLayer:showGameChat(false)
	-- end

	--牌可点击
	if self.bCanMoveCard == true then
		local size1 = self.nodeCard[cmd.MY_VIEWID]:getContentSize()
		local x1, y1 = self.nodeCard[cmd.MY_VIEWID]:getPosition()
		for i = 1, 5 do
			local card = self.nodeCard[cmd.MY_VIEWID]:getChildByTag(i)
			local x2, y2 = card:getPosition()
			local size2 = card:getContentSize()
			local rect = card:getTextureRect()
			rect.x = x1 - size1.width/2 + x2 - size2.width/2
			rect.y = y1 - size1.height/2 + y2 - size2.height/2
			if cc.rectContainsPoint(rect, cc.p(x, y)) then
				if self.bCardOut[i] == false then
					card:move(x2, y2 + 30)
				elseif self.bCardOut[i] == true then
					card:move(x2, y2 - 30)
				end
				self.bCardOut[i] = not self.bCardOut[i]
				self:updateCardPrompt()
				return
			end
		end
	end
end
function GameViewLayer:onBtnStart()
    self.btStart:setVisible(false)   
    self:ClearTableGold()
    self.winChairID = {}     
    if self._scene._gameFrame.bEnterAntiCheatRoom == true and GlobalUserItem.isForfendGameRule() then 
        self.gAntiCheatWait:setVisible(true)
    end
    self._scene:onStartGame()
end

--按钮点击事件
function GameViewLayer:onButtonClickedEvent(tag,ref)
	if tag == GameViewLayer.BT_START then
		self:onBtnStart()
	elseif tag == GameViewLayer.BT_SWITCH then
		self:onButtonSwitchAnimate()
	elseif tag == GameViewLayer.BT_EXIT then
		self:onButtonSwitchAnimate()
		self._scene:onQueryExitGame()
	elseif tag == GameViewLayer.BT_CHAT then
        local item = self:getChildByTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
        if item ~= nil then
            item:resetData()
        else
            local gameSystemMessage = GameSystemMessage:create()
            gameSystemMessage:setLocalZOrder(100)
            gameSystemMessage:setTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
            self:addChild(gameSystemMessage)
        end
	elseif tag == GameViewLayer.BT_SET then
        if nil == self.layerSet then
	        local mgr = self._scene._scene:getApp():getVersionMgr()
	        local nVersion = mgr:getResVersion(cmd.KIND_ID) or "0"
		    self.layerSet = SettingLayer:create(nVersion)
            self:addChild(self.layerSet)
            self.layerSet:setLocalZOrder(GameViewLayer.ORDER_SET)
        else
            self.layerSet:onShow()
        end
		self:onButtonSwitchAnimate()
    elseif tag == GameViewLayer.BT_HELP then
        if nil == self.layerHelp then
            self.layerHelp = HelpLayer:create(self, cmd.KIND_ID, 0)
            self.layerHelp:addTo(self)
            self.layerHelp:setLocalZOrder(GameViewLayer.ORDER_HELP)
        else
            self.layerHelp:onShow()
        end
        self:onButtonSwitchAnimate()
    elseif tag == GameViewLayer.BT_CHANGE then
        --防作弊判断
        if self._scene._gameFrame.bEnterAntiCheatRoom == true and GlobalUserItem.isForfendGameRule() then
            showToast(cc.Director:getInstance():getRunningScene(), "游戏进行中无法换桌...", 2)
        elseif self._scene.m_cbGameStatus ~= cmd.GS_TK_FREE and self._scene:GetMeUserItem().cbUserStatus == yl.US_PLAYING then
            showToast(cc.Director:getInstance():getRunningScene(), "游戏进行中无法换桌...", 2)
        else
    	    if self.bBtnInOutside then
		        self:onButtonSwitchAnimate()
	        end
            if self.bExplainInOutside then
		        self:onButtonExplainAnimate()
	        end
            self._scene:onChangeDesk()
            self:onResetView() 							--重置   
        end
    elseif tag == GameViewLayer.BT_EXPLAIN then
        self:onButtonExplainAnimate()
	elseif tag == GameViewLayer.BT_OPENCARD then
		self.bCanMoveCard = false
		self.btOpenCard:setVisible(false)
		self._scene:onOpenCard()
	elseif tag == GameViewLayer.BT_CALLBANKER then
		self.btCallBanker:setVisible(false)
		self.btCancel:setVisible(false)
		self._scene:onBanker(1)
	elseif tag == GameViewLayer.BT_CANCEL then
		self.btCallBanker:setVisible(false)
		self.btCancel:setVisible(false)
		self._scene:onBanker(0)
	elseif tag - GameViewLayer.BT_CHIP == 1 or
			tag - GameViewLayer.BT_CHIP == 2 or
			tag - GameViewLayer.BT_CHIP == 3 or
			tag - GameViewLayer.BT_CHIP == 4 then
		for i = 1, 4 do
			self.btChip[i]:setVisible(false)
		end       
		local index = tag - GameViewLayer.BT_CHIP
		self._scene:onAddScore(self.lUserMaxScore[index])
	else
		showToast(cc.Director:getInstance():getRunningScene(),"功能尚未开放！",1)
	end
end
--根据下注金额获取
function GameViewLayer:getGoldNum(chipScore)
    return math.floor(chipScore/self.lUserMaxScore[4])*2
end
--播放下注金币动画
function GameViewLayer:runChipAnimate(goldNum,viewID)
    local newChipList = {}
    for i = 1,goldNum do        
        local sGold = display.newSprite("#oxex_icon_gold_small.png")
                    :setLocalZOrder(GameViewLayer.ORDER_1)
                    :setPosition(pointPlayer[viewID])
        table.insert(newChipList,1,sGold)
        sGold:runAction(cc.MoveTo:create(0.4, self:getTableGoldPosOnTable()))       
    end
    for _,v in pairs(newChipList) do
		v:addTo(self.nodeChipPool)
    end
end
--获取下注金币停留位置
function GameViewLayer:getTableGoldPosOnTable()
    local x = math.random(rectTableGold.x,rectTableGold.x+rectTableGold.width);
    local y = math.random(rectTableGold.y,rectTableGold.y+rectTableGold.height);
    return cc.p(x,y)
end
--吐出多输的金币动画
function GameViewLayer:runOtherGoldAnimate(tLoseScore) 
    local bOutGold = false
    for k,v in pairs(tLoseScore) do 
        if v > 0 then 
            self.WinChairID = k
        else
            local bScore = tonumber(self.tableScore[k]:getChildByTag(GameViewLayer.SCORENUM):getString()) or 0 
            if math.abs(v) > bScore then 
                local goldNum = self:getGoldNum(math.abs(v)-bScore)
                if goldNum > 16*5 then 
                    goldNum = 16*5
                end
                self:runChipAnimate(goldNum,k)
                bOutGold = true
            end
        end
        self:setUserTableScore(k, 0)
    end
    if bOutGold == true then
        local seq = cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
            self:runGoldAnimate()
            end));  
        self:runAction(seq);  
    else
        self:runGoldAnimate()
    end

end
--结算金币动画
function GameViewLayer:runGoldAnimate()
    local children = self.nodeChipPool:getChildren()
	for k, v in pairs(children) do
		v:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*(#children - k)),
			cc.MoveTo:create(0.15, cc.p(pointPlayer[self.WinChairID].x, pointPlayer[self.WinChairID].y )),
			cc.CallFunc:create(function(node)
				node:removeFromParent()
			end)))
	end
end

--清空金币
function GameViewLayer:ClearTableGold()
    self.nodeChipPool:removeAllChildren()
end

function GameViewLayer:onButtonExplainAnimate()
	local fSpeed = 0.2
	local fScale = 0

    if self.bExplainInOutside then
		fScale = 0
	else
		fScale = 1
        if this.bBtnInOutside then 
            self:onButtonSwitchAnimate()
        end
	end

    --背景图移动
    this.bExplainInOutside = not this.bExplainInOutside
    self.spExplainBg:runAction(cc.ScaleTo:create(fSpeed, fScale, fScale, 1))
end


function GameViewLayer:onButtonSwitchAnimate()
	local fSpeed = 0.2
	local fScale = 0

	if self.bBtnInOutside then
		fScale = 0
	else
		fScale = 1
        if this.bExplainInOutside then 
            self:onButtonExplainAnimate()
        end
	end

	--背景图移动
    this.bBtnInOutside = not this.bBtnInOutside
    self.spButtonBg:runAction(cc.ScaleTo:create(fSpeed, fScale, fScale, 1))
end

function GameViewLayer:gameCallBanker(callBankerViewId, bFirstTimes)
    self.pStateCbing:setVisible(true)
    self.pStateCbing:setPosition(pointState[callBankerViewId])
	if callBankerViewId == cmd.MY_VIEWID then   --自己叫庄
        if self._scene.cbDynamicJoin == 0 then
            ExternalFun.playSoundEffect("oxex_player_chip.mp3")
        end
        self.btCallBanker:setVisible(true)
        self.btCancel:setVisible(true)
        self.gCbSelf:setVisible(true)
        self.gCbOther:setVisible(false)        
    else                                        --其他玩家叫庄
        self.gCbSelf:setVisible(false)
        self.gCbOther:setVisible(true)
    end

    --关闭游戏等待提示
    self.gStateWait:setVisible(false)
    self.gAntiCheatWait:setVisible(false)

    if bFirstTimes then
		display.newSprite()
			:move(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2)
			:addTo(self, 1)
			:runAction(self:getAnimate("start", true))
    end
end

function GameViewLayer:gameStart(bankerViewId)
    self.pStateBets:setVisible(true)    
    if bankerViewId ~= cmd.MY_VIEWID then
        for i = 1, 4 do
            self.btChip[i]:setVisible(true)
        end   
        if self._scene.cbDynamicJoin == 0 then
            ExternalFun.playSoundEffect("oxex_player_chip.mp3")
        end
        self.gBetsSelf:setVisible(true)  
        self.gBetsOther:setVisible(false) 
        self.pStateBets:setPosition(pointState[cmd.MY_VIEWID])
    else
        self.gBetsSelf:setVisible(false) 
        self.gBetsOther:setVisible(true)   
        self.pStateBets:setPosition(pointState[2])
    end
    self.gCbSelf:setVisible(false)
    self.gCbOther:setVisible(false)
    self.pStateCbing:setVisible(false)
end

function GameViewLayer:gameAddScore(viewId, score,bShowEct)
	local strScore = ""..score
	if score < 0 then
		strScore = "/"..math.abs(score)
	end
    self.tableScore[viewId]:getChildByTag(GameViewLayer.SCORENUM):setString(strScore)
	self.tableScore[viewId]:setVisible(true)
    if bShowEct then 
        display.newSprite()
	            :setPosition(pointTableScore[viewId].x+80,pointTableScore[viewId].y)
	            :addTo(self,GameViewLayer.ORDER_2)
                :runAction(self:getAnimate("addscore", true)) 
    end

    local labelScore = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SCORE)
    local lScore = tonumber(labelScore:getString())
    self:setScore(viewId, lScore - score)
end
function GameViewLayer:setGoldNum()
    local goldNum = 0
    for i = 1 ,cmd.GAME_PLAYER do 
        local labelScore = self.tableScore[i]:getChildByTag(GameViewLayer.SCORENUM)       
        local lScore = tonumber(labelScore:getString())
        if lScore ~= 0 then 
            goldNum = self:getGoldNum(lScore,i)
        end
    end
    local Num = goldNum - self.nodeChipPool:getChildrenCount()
    if Num > 0 then
        local newChipList = {}
        for i = 1,Num do        
            local sGold = display.newSprite("#oxex_icon_gold_small.png")
                        :setLocalZOrder(GameViewLayer.ORDER_1)
                        :setPosition(self:getTableGoldPosOnTable())
            table.insert(newChipList,1,sGold)  
        end
        for _,v in pairs(newChipList) do
		    v:addTo(self.nodeChipPool)
        end 
    end
end

function GameViewLayer:gameSendCard(firstViewId, totalCount)
	--开始发牌
	self:runSendCardAnimate(firstViewId, totalCount)
    self.gBetsSelf:setVisible(false) 
    self.gBetsOther:setVisible(false) 
    self.pStateBets:setVisible(false)
end

--开牌
function GameViewLayer:gameOpenCard(wViewChairId, cbOx, bEnded)
--	local cardWidth = self.animateCard:getContentSize().width
--	local cardHeight = self.animateCard:getContentSize().height
--	local fSpacing = GameViewLayer.CARDSPACING
--	local fWidth
--	if cbOx > 0 then
--		fWidth = cardWidth + fSpacing*2
--	else
--		fWidth = cardWidth + fSpacing*4
--	end
--	--牌的排列
--	self.nodeCard[wViewChairId]:setContentSize(cc.size(fWidth, cardHeight))
--	for i = 1, 5 do
--        local card = self.nodeCard[wViewChairId]:getChildByTag(i)
--		if wViewChairId == cmd.MY_VIEWID then
--			card:move(cardWidth/2 + fSpacing*(i - 1), cardHeight/2)
--            card:setLocalZOrder(GameViewLayer.ORDER_2)
--		end

--		if cbOx > 0 and i >= 4 then
--			local positionX, positionY = card:getPosition()
--			positionX = positionX - (fSpacing*2 + fSpacing/2)
--			positionY = positionY + 50
--			card:move(positionX, positionY)
--			card:setLocalZOrder(GameViewLayer.ORDER_1)
--		end
--	end
--	--牌型
--	if cbOx >= 10 then
--		cbOx = 10
--	end
--	local strFile = string.format("oxex_icon_ox%d.png", cbOx)
--	local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(strFile)
--	self.cardType[wViewChairId]:setSpriteFrame(spriteFrame)
--	self.cardType[wViewChairId]:setVisible(true)
    --牌型
    self:ShowCardType(cbOx,wViewChairId)
	--隐藏摊牌图标
    self:setOpenCardVisible(wViewChairId, false)
    --声音
    if bEnded and wViewChairId == cmd.MY_VIEWID then
    	local strGender = "GIRL"
    	if self.cbGender[wViewChairId] == 1 then
			strGender = "BOY"
		end
		local strSound = "BOY/oxex_ox_"..cbOx..".mp3"
        ExternalFun.playSoundEffect(strSound)
    end
end
function GameViewLayer:ShowCardType(cbOx,wViewChairId)
    if self.cardType[wViewChairId]:isVisible() then return end

    if self.cardType[wViewChairId] then
        self.cardType[wViewChairId]:removeAllChildren()
    end
    if cbOx >10 then 
        cbOx = 11
    end
    local offsetX = 0
    local offsetY = 0
    local scale = 1
    if wViewChairId ~= cmd.MY_VIEWID then
        scale = 0.8
    end
    local pSprite = display.newSprite(string.format("#oxex_icon_ox%d.png", cbOx))
    local pSpBg = nil 
    if cbOx == 0 then
        pSpBg = display.newSprite("#oxex_bg_cardtype0.png")
    else       
        if cbOx >= 10 then 
            pSpBg = display.newSprite("#oxex_bg_cardtype2.png")
        else
            pSpBg = display.newSprite("#oxex_bg_cardtype1.png")
        end
        offsetX = -2+2*(math.random(1,3)-1)
        offsetY = -2+2*(math.random(1,3)-1)
        pSprite:setScale(3)
        pSpBg:setScale(0)
    end  

    self.cardType[wViewChairId]:addChild(pSprite,1)
    self.cardType[wViewChairId]:addChild(pSpBg)
    self.cardType[wViewChairId]:setVisible(true)

    pSpBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, scale, scale),cc.FadeIn:create(0.2)))

    pSprite:runAction(cc.Sequence:create(
                               cc.Spawn:create(cc.ScaleTo:create(0.3, scale, scale),cc.FadeIn:create(0.2)),
                               cc.MoveBy:create(0.05, cc.p(offsetX,offsetY)),
                               cc.MoveBy:create(0.05, cc.p(-offsetX*2,-offsetY*2)),
                               cc.MoveBy:create(0.05, cc.p(offsetX,offsetY))))
end
function GameViewLayer:gameScenePlaying()
    self.btOpenCard:setVisible(true)
end

--function GameViewLayer:setCellScore(cellscore)
--	if not cellscore then
--		self.txt_CellScore:setString("底注：")
--        self.tabCellScore:setString("0");
--	else
--		self.txt_CellScore:setString("底注："..cellscore)
--        self.tabCellScore:setString(cellscore);
--	end
--end

--function GameViewLayer:setTableID(id)
--	if not id or id == yl.INVALID_TABLE then
--		self.txt_TableID:setString("桌号：")
--	else
--		self.txt_TableID:setString("桌号："..(id + 1))
--	end
--end

function GameViewLayer:setCardTextureRect(viewId, tag, cardValue, cardColor)
	if viewId < 1 or viewId > 4 or tag < 1 or tag > 5 then
		print("card texture rect error!")
		return
	end
	
	local card = self.nodeCard[viewId]:getChildByTag(tag)
	local rectCard = card:getTextureRect()
	rectCard.x = rectCard.width*(cardValue - 1)
	rectCard.y = rectCard.height*cardColor 
	card:setTextureRect(rectCard)
end
function GameViewLayer:setCardTextureRectEx(viewId, tag, cardValue, cardColor)
	if viewId < 1 or viewId > 4 or tag < 1 or tag > 5 then
		print("card texture rect error!")
		return
	end
	
	local card = self.nodeCard[viewId]:getChildByTag(tag)
	local rectCard = card:getTextureRect()
	rectCard.x = rectCard.width*(cardValue - 1)
	rectCard.y = rectCard.height*cardColor
    if viewId == cmd.MY_VIEWID then 
        card:setTextureRect(rectCard)
    else
        card:runAction(cc.Sequence:create(
                        cc.DelayTime:create(tag*0.1),
                        self:getAnimate("opencard", true),
                        cc.CallFunc:create(function(ref)
                            local pNode = display.newSprite(GameViewLayer.RES_PATH.."card.png")
                            pNode:setTextureRect(rectCard)
                            pNode:setTag(tag)
                            pNode:setScale(0.8)  
                            pNode:setPosition(ref:getPosition())
                            pNode:addTo(self.nodeCard[viewId])
                        end),
                        cc.RemoveSelf:create()))       
    end
end
function GameViewLayer:setNickname(viewId, strName)
	local name = string.EllipsisByConfig(strName, 105, string.getConfig(appdf.FONT_FILE, 20))
	local labelNickname = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.NICKNAME)
	labelNickname:setString(name)
end

function GameViewLayer:setScore(viewId, lScore)
	local labelScore = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SCORE)
	labelScore:setString(lScore)

	local labelWidth = labelScore:getContentSize().width
	if labelWidth > 98 then
		labelScore:setScaleX(98/labelWidth)
	elseif labelScore:getScaleX() ~= 1 then
		labelScore:setScaleX(1)
	end
end

function GameViewLayer:setUserScore(wViewChairId, lScore)
	self.nodePlayer[wViewChairId]:getChildByTag(GameViewLayer.SCORE):setString(lScore)
end

function GameViewLayer:setReadyVisible(wViewChairId, isVisible)
    self.pStateReady[wViewChairId]:setVisible(isVisible)
end

function GameViewLayer:setOpenCardVisible(wViewChairId, isVisible)
	self.pStateOpenCard[wViewChairId]:setVisible(isVisible)
end

function GameViewLayer:setTurnMaxScore(lTurnMaxScore)
    local MaxScore = 0
    for k,v in pairs(lTurnMaxScore) do 
        if v > 0 then 
            MaxScore = v 
            break
        end
    end
	for i = 1, 4 do
		self.lUserMaxScore[i] = math.max(MaxScore, 1)
		self.btChip[i]:getChildByTag(GameViewLayer.CHIPNUM):setString(self.lUserMaxScore[i])
		MaxScore = math.floor(MaxScore/2)
	end
end

function GameViewLayer:setBankerUser(wViewChairId,cbDynamicJoin)
    if cbDynamicJoin == 0 then 
        local fSpeed = 0.5
        self.spriteBankerFlag:setVisible(true)
        self.spriteBankerFlag:setScale(1)
        self.spriteBankerFlag:setPosition(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2)
        self.spriteBankerFlag:runAction(cc.Spawn:create(cc.ScaleTo:create(fSpeed,0.4),cc.MoveTo:create(fSpeed, pointBankerFlag[wViewChairId])))
    else       
	    self.spriteBankerFlag:move(pointBankerFlag[wViewChairId])
	    self.spriteBankerFlag:setVisible(true)
    end  
end

function GameViewLayer:setUserTableScore(wViewChairId, lScore)
	if lScore == 0 then
        self.tableScore[wViewChairId]:getChildByTag(GameViewLayer.SCORENUM):setString(""..lScore)
	    self.tableScore[wViewChairId]:setVisible(false)
		return
	end
	local strScore = ""..lScore
	if lScore < 0 then
		strScore = "/"..(-lScore)
	end
    
    self.tableScore[wViewChairId]:getChildByTag(GameViewLayer.SCORENUM):setString(strScore)
	self.tableScore[wViewChairId]:setVisible(true) 
end


--发牌动作
function GameViewLayer:runSendCardAnimate(wViewChairId, nCount)
	if nCount == cmd.GAME_PLAYER*5 then
		self.animateCard:setVisible(true)
	elseif nCount < 1 then
        if self.pSpCard then 
            self.pSpCard:stopAllActions()
            self.pSpCard:setVisible(false)
            self.pSpCard = nil
        end
		self.bCanMoveCard = true
		self.animateCard:setVisible(false)
		self.btOpenCard:setVisible(true)
		return
	end

    self.pSpCard = display.newSprite(GameViewLayer.RES_PATH.."card.png")
        :setTextureRect(cc.rect(2*110.0,4*150.0,110,150))
        :setPosition(cc.p(950,560))
		:setVisible(false)
		:setLocalZOrder(3)
        :setRotation(-70)
        :setScale(0.3)
		:addTo(self)
    self.animateCard:setVisible(false)

    local cardNum = math.floor(5 - nCount/cmd.GAME_PLAYER) + 1

    local pos = cc.p(pointCard[wViewChairId].x + (cardNum-1) * self.animateCard:getContentSize().width/2,pointCard[wViewChairId].y)
    local otherScale
    local fSpeed = 0.15
    if wViewChairId == cmd.MY_VIEWID then
        otherScale = 1
    else
        otherScale = 0.8
    end

    local aniCard = nil

    if wViewChairId == cmd.MY_VIEWID then    
        aniCard = cc.Sequence:create(
                        cc.Show:create(),
			            cc.Spawn:create(cc.ScaleTo:create(fSpeed,otherScale),cc.MoveTo:create(fSpeed, pos),cc.RotateTo:create(fSpeed,0)),
                        self:getAnimate("opencard", true),                         
                        cc.RemoveSelf:create(),                        
			            cc.CallFunc:create(function()
				            --显示一张牌
				            local nTag = math.floor(5 - nCount/cmd.GAME_PLAYER) + 1
                            local card = self.nodeCard[wViewChairId]:getChildByTag(nTag)
				            if not card then return end
				            card:setVisible(true)
                            --开始下一个人的发牌
				            --开始下一个人的发牌
				            wViewChairId = wViewChairId == 1 and 2 or 1
				            self:runSendCardAnimate(wViewChairId, nCount - 1)
                        end))
    else
        aniCard = cc.Sequence:create(
                        cc.Show:create(),
			            cc.Spawn:create(cc.ScaleTo:create(fSpeed,otherScale),cc.MoveTo:create(fSpeed, pos),cc.RotateTo:create(fSpeed,0)),                      
                        cc.RemoveSelf:create(),                        
			            cc.CallFunc:create(function()
				            --显示一张牌
				            local nTag = math.floor(5 - nCount/cmd.GAME_PLAYER) + 1
                            local card = self.nodeCard[wViewChairId]:getChildByTag(nTag)
				            if not card then return end
				            card:setVisible(true)
                            --开始下一个人的发牌
				            --开始下一个人的发牌
				            wViewChairId = wViewChairId == 1 and 2 or 1
				            self:runSendCardAnimate(wViewChairId, nCount - 1)
                        end))
    end 
    self.pSpCard:runAction(aniCard)
end

--检查牌类型
function GameViewLayer:updateCardPrompt()
	--弹出牌显示，统计和
	local nSumTotal = 0
	local nSumOut = 0
	local nCount = 1
	for i = 1, 5 do
		local nCardValue = self._scene:getMeCardLogicValue(i)
		nSumTotal = nSumTotal + nCardValue
		if self.bCardOut[i] then
--	 		if nCount <= 3 then
--	 			self.labAtCardPrompt[nCount]:setString(nCardValue)
--	 		end
	 		nCount = nCount + 1
			nSumOut = nSumOut + nCardValue
		end
	end
--	for i = nCount, 3 do
--		self.labAtCardPrompt[i]:setString("")
--	end
	--判断是否构成牛
--	local nDifference = nSumTotal - nSumOut
--	if nCount == 1 then
--		self.labCardType:setString("")
--	elseif nCount == 3 then 		--弹出两张牌
--		if self:mod(nDifference, 10) == 0 then
--			self.labCardType:setString("牛  "..(nSumOut > 10 and nSumOut - 10 or nSumOut))
--		else
--			self.labCardType:setString("无牛")
--		end
--	elseif nCount == 4 then 		--弹出三张牌
--		if self:mod(nSumOut, 10) == 0 then
--			self.labCardType:setString("牛  "..(nDifference > 10 and nDifference - 10 or nDifference))
--		else
--			self.labCardType:setString("无牛")
--		end
--	else
--		self.labCardType:setString("无牛")
--	end
end

function GameViewLayer:preloadUI()
	for i = 1, #AnimationRes do
		local animation = cc.Animation:create()
		animation:setDelayPerUnit(AnimationRes[i].fInterval)
		animation:setLoops(AnimationRes[i].nLoops)

		for j = 1, AnimationRes[i].nCount do
			local strFile = AnimationRes[i].file..string.format("%d.png", j)
			animation:addSpriteFrameWithFile(strFile)
		end

		cc.AnimationCache:getInstance():addAnimation(animation, AnimationRes[i].name)
	end

    cc.SpriteFrameCache:getInstance():addSpriteFrames(GameViewLayer.RES_PATH..  "oxex_all.plist")
    cc.Director:getInstance():getTextureCache():addImage("game/card.png")
end

function GameViewLayer:getAnimate(name, bEndRemove)
	local animation = cc.AnimationCache:getInstance():getAnimation(name)
	local animate = cc.Animate:create(animation)

	if bEndRemove then
		animate = cc.Sequence:create(animate, cc.CallFunc:create(function(ref)
			ref:removeFromParent()
		end))
	end

	return animate
end

function GameViewLayer:promptOx()
	--首先将牌复位
	for i = 1, 5 do
		if self.bCardOut[i] == true then
			local card = self.nodeCard[cmd.MY_VIEWID]:getChildByTag(i)
			local x, y = card:getPosition()
			y = y - 30
			card:move(x, y)
			self.bCardOut[i] = false
		end
	end
	--将牛牌弹出
	local index = self._scene:GetMeChairID() + 1
	local cbDataTemp = self:copyTab(self._scene.cbCardData[index])
	if self._scene:getOxCard(cbDataTemp) then
		for i = 1, 5 do
			for j = 1, 3 do
				if self._scene.cbCardData[index][i] == cbDataTemp[j] then
					local card = self.nodeCard[cmd.MY_VIEWID]:getChildByTag(i)
					local x, y = card:getPosition()
					y = y + 30
					card:move(x, y)
					self.bCardOut[i] = true
				end
			end
		end
	end
	self:updateCardPrompt()
end

--用户聊天
function GameViewLayer:userChat(wViewChairId, chatString)
	if chatString and #chatString > 0 then
		self._chatLayer:showGameChat(false)
		--取消上次
		if self.chatDetails[wViewChairId] then
			self.chatDetails[wViewChairId]:stopAllActions()
			self.chatDetails[wViewChairId]:removeFromParent()
			self.chatDetails[wViewChairId] = nil
		end

		--创建label
		local limWidth = 24*12
		local labCountLength = cc.Label:createWithSystemFont(chatString,"fonts/round_body.ttf", 24)  
		if labCountLength:getContentSize().width > limWidth then
			self.chatDetails[wViewChairId] = cc.Label:createWithSystemFont(chatString,"fonts/round_body.ttf", 24, cc.size(limWidth, 0))
		else
			self.chatDetails[wViewChairId] = cc.Label:createWithSystemFont(chatString,"fonts/round_body.ttf", 24)
		end
		if wViewChairId == cmd.MY_VIEWID then
			self.chatDetails[wViewChairId]:move(pointChat[wViewChairId].x + 24 , pointChat[wViewChairId].y + 9)
				:setAnchorPoint( cc.p(0, 0.5) )
		else
			self.chatDetails[wViewChairId]:move(pointChat[wViewChairId].x - 24 , pointChat[wViewChairId].y + 9)
				:setAnchorPoint(cc.p(1, 0.5))
		end
		self.chatDetails[wViewChairId]:addTo(self, 2)

	    --改变气泡大小
		self.chatBubble[wViewChairId]:setContentSize(self.chatDetails[wViewChairId]:getContentSize().width+48, self.chatDetails[wViewChairId]:getContentSize().height + 40)
			:setVisible(true)
		--动作
	    self.chatDetails[wViewChairId]:runAction(cc.Sequence:create(
	    	cc.DelayTime:create(3),
	    	cc.CallFunc:create(function()
	    		self.chatDetails[wViewChairId]:removeFromParent()
				self.chatDetails[wViewChairId] = nil
				self.chatBubble[wViewChairId]:setVisible(false)
	    	end)))
    end
end

--用户表情
function GameViewLayer:userExpression(wViewChairId, wItemIndex)
	if wItemIndex and wItemIndex >= 0 then
		self._chatLayer:showGameChat(false)
		--取消上次
		if self.chatDetails[wViewChairId] then
			self.chatDetails[wViewChairId]:stopAllActions()
			self.chatDetails[wViewChairId]:removeFromParent()
			self.chatDetails[wViewChairId] = nil
		end

	    local strName = string.format("e(%d).png", wItemIndex)
	    self.chatDetails[wViewChairId] = cc.Sprite:createWithSpriteFrameName(strName)
	        :move(pointChat[wViewChairId])
	        :addTo(self, 2)
	    if wViewChairId == cmd.MY_VIEWID then
			self.chatDetails[wViewChairId]:move(pointChat[wViewChairId].x + 45 , pointChat[wViewChairId].y + 5)
		else
			self.chatDetails[wViewChairId]:move(pointChat[wViewChairId].x - 45 , pointChat[wViewChairId].y + 5)
		end

	    --改变气泡大小
		self.chatBubble[wViewChairId]:setContentSize(90,80)
			:setVisible(true)

	    self.chatDetails[wViewChairId]:runAction(cc.Sequence:create(
	    	cc.DelayTime:create(3),
	    	cc.CallFunc:create(function()
	    		self.chatDetails[wViewChairId]:removeFromParent()
				self.chatDetails[wViewChairId] = nil
				self.chatBubble[wViewChairId]:setVisible(false)
	    	end)))
    end
end

--拷贝表
function GameViewLayer:copyTab(st)
    local tab = {}
    for k, v in pairs(st) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = self:copyTab(v)
        end
    end
    return tab
 end

--取模
function GameViewLayer:mod(a,b)
    return a - math.floor(a/b)*b
end
--运行输赢动画
function GameViewLayer:runWinLoseAnimate(viewid, score)
    self.endScore[viewid]:setVisible(true)
    self.endScore[viewid]:setPosition(ptWinLoseAnimate[viewid])
    if score > 0 then    
        self.endScore[viewid]:getChildByTag(GameViewLayer.SCOREWIN):setString("/"..score)
            :setVisible(true)
        self.endScore[viewid]:getChildByTag(GameViewLayer.SCORELOSE):setVisible(false)

        local bgFram = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxex_bg_winhead.png")
        self.nodePlayer[viewid]:setSpriteFrame(bgFram) 
        display.newSprite()
	            :setPosition(pointPlayer[viewid])
	            :addTo(self,GameViewLayer.ORDER_2)
                :runAction(cc.Sequence:create(
                                self:getAnimate("win", true), 
                                cc.CallFunc:create(function()
                                    local bgFram = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxex_bg_head.png")
                                    self.nodePlayer[viewid]:setSpriteFrame(bgFram)
                                end)))
    else      
        self.endScore[viewid]:getChildByTag(GameViewLayer.SCOREWIN):setVisible(false)
        self.endScore[viewid]:getChildByTag(GameViewLayer.SCORELOSE):setString("/"..math.abs(score))
            :setVisible(true)
    end

    local nTime = 1.5
    self.endScore[viewid]:runAction(cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveBy:create(nTime, cc.p(0, 50)), 
			cc.FadeIn:create(nTime)),
		cc.DelayTime:create(3),
		cc.CallFunc:create(function()
			self.endScore[viewid]:setVisible(false)
		end)))
end

function GameViewLayer:gameEnd(MeScore)
	if MeScore > 0 then
        ExternalFun.playSoundEffect("oxex_game_win.mp3")
	elseif MeScore < 0 then
        ExternalFun.playSoundEffect("oxex_game_lose.mp3")
	end
    if MeScore ~= 0 then 
        self.btStart:setPosition(self.btOpenCard:getPosition())
    end
    --self:runWinLoseEnd(MeScore)   
    self.btStart:setVisible(true)
    self.btCallBanker:setVisible(false)
    self.btCancel:setVisible(false)
end

function GameViewLayer:runWinLoseEnd(score)
    self.WinLose:setVisible(true)
    self.WinLose:setScale(0)

    local bgFram
    local lightFrame
    local TitleFrame
    local TabFrame

    local Light = self.WinLose:getChildByTag(GameViewLayer.WINLOSELIGHT)
    local Title = self.WinLose:getChildByTag(GameViewLayer.WINLOSETITLE)
    Title:setScale(0.3)
    local Tab = self.WinLose:getChildByTag(GameViewLayer.WINLOSETAB)
    Tab:setPosition(self.WinLose:getContentSize().width/2,self.WinLose:getContentSize().height/2-20)
    local WinText = Tab:getChildByTag(GameViewLayer.WINLOSESCOREWIN)
    local LoseText = Tab:getChildByTag(GameViewLayer.WINLOSESCORELOSE)

    if score > 0 then
        bgFram = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxex_bg_endbg_win.png")
        lightFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxex_bg_endlightbg_win.png")
        TitleFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxex_icon_win.png")
        TabFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxex_bg_endtextbg_win.png")
        WinText:setVisible(true)
        LoseText:setVisible(false)
        WinText:setString("."..score)
    else
        bgFram = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxex_bg_endbg_fail.png")
        lightFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxex_bg_endlightbg_fail.png")
        TitleFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxex_icon_lose.png")
        TabFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxex_bg_endtextbg_fail.png")
        WinText:setVisible(false)
        LoseText:setVisible(true)
        LoseText:setString("/"..math.abs(score))
    end
    self.WinLose:setSpriteFrame(bgFram) 
    Light:setSpriteFrame(lightFrame) 
    Title:setSpriteFrame(TitleFrame) 
    Tab:setSpriteFrame(TabFrame) 

    self.WinLose:runAction(cc.Sequence:create(
                            cc.ScaleTo:create(0.2, 1, 1, 1),
                            cc.DelayTime:create(2.3),
		                    cc.CallFunc:create(function()
			                    self.WinLose:setVisible(false)
                                self.btStart:setVisible(true)
		                    end)))
    Light:runAction(cc.RotateBy:create(2.5, 360))
    Title:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.2),
                    cc.ScaleTo:create(0.3, 1, 1, 1)))
    Tab:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.5),
                    cc.MoveBy:create(0.5, cc.p(0,10-self.WinLose:getContentSize().height/2))))           
end

function GameViewLayer:showPopWait( )
	self._scene:showPopWait()
end

function GameViewLayer:dismissPopWait( )
	self._scene:dismissPopWait()
end

return GameViewLayer