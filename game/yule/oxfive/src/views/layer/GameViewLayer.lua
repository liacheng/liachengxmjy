local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)

local cmd = appdf.req(appdf.GAME_SRC.."yule.oxfive.src.models.CMD_Game")
local GameSetLayer = appdf.req(appdf.GAME_SRC.."yule.oxfive.src.views.layer.GameSetLayer")
local HelpLayer = appdf.req(appdf.GAME_SRC.."yule.oxfive.src.views.layer.HelpLayer")
local CardSprite = appdf.req(appdf.GAME_SRC.."yule.oxfive.src.views.layer.CardSprite")
local PopupInfoHead = appdf.req("client.src.external.PopupInfoHead")
local GameChatLayer = appdf.req(appdf.PUB_GAME_VIEW_SRC.."GameChatLayer")
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationMgr = appdf.req(appdf.EXTERNAL_SRC .. "AnimationMgr")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.oxfive.src.models.GameLogic")
local GameSystemMessage = require(appdf.EXTERNAL_SRC .. "GameSystemMessage")
GameViewLayer.TAG_GAMESYSTEMMESSAGE = 6751

GameViewLayer.BT_PROMPT 			= 2
-- 摊牌
GameViewLayer.BT_OPENCARD 			= 3
GameViewLayer.BT_START 				= 4

GameViewLayer.BT_SWITCH 			= 12
GameViewLayer.BT_SET 				= 13
GameViewLayer.BT_CHANGE 			= 14
GameViewLayer.BT_CHAT 				= 15
GameViewLayer.BT_EXPLAIN 			= 16
GameViewLayer.BT_HELP 				= 17
GameViewLayer.BT_EXIT 				= 18
GameViewLayer.BT_CANCEL             = 19
GameViewLayer.BT_CHIP1              = 20
GameViewLayer.BT_CHIP2              = 21
GameViewLayer.BT_CHIP3              = 22
GameViewLayer.BT_CHIP4              = 23
GameViewLayer.NUM_CHIP              = 24 
GameViewLayer.BT_MUL1               = 25
GameViewLayer.BT_MUL2               = 26
GameViewLayer.BT_MUL3               = 27
GameViewLayer.BT_MUL4               = 28

GameViewLayer.TAG_START				= 100
GameViewLayer.TAG_CLOCK             = 100

GameViewLayer.TopZorder = 30
GameViewLayer.ZORDER_CHAT = 20

GameViewLayer.FRAME 				= 1
GameViewLayer.NICKNAME 				= 2
GameViewLayer.SCORE 				= 3
GameViewLayer.FACE 					= 7

GameViewLayer.TIMENUM   			= 1
GameViewLayer.CHIPNUM 				= 1
GameViewLayer.SCORENUM 				= 1
GameViewLayer.SCOREWIN 				= 1
GameViewLayer.SCORELOSE 			= 2

--层级
GameViewLayer.ORDER_1               = 1         --下注数和金币层
GameViewLayer.ORDER_2               = 2         --卡牌层
GameViewLayer.ORDER_3               = 3         --牌型和时钟层
GameViewLayer.ORDER_4               = 4         --开始按钮层
GameViewLayer.ORDER_5               = 5         --结算层
GameViewLayer.ORDER_6               = 6         --其他按钮
GameViewLayer.ORDER_SET             = 9
GameViewLayer.ORDER_HELP            = 10
GameViewLayer.RES_PATH 				= "game/yule/oxfive/res/"

local AnimationRes = 
{
	{name = "opencard", file = GameViewLayer.RES_PATH.."animation/oxfive_effect_opencard", nCount = 3, fInterval = 0.07, nLoops = 1},
	{name = "addscore", file = GameViewLayer.RES_PATH.."animation/oxfive_effect_chip", nCount = 5, fInterval = 0.15, nLoops = 1},
	{name = "win", file = GameViewLayer.RES_PATH.."animation/oxfive_effect_win", nCount = 8, fInterval = 0.15, nLoops = 1},
}

local pointOpenCardFlag ={}
local pointTableScore = {}
local pointBankerFlag = {}
local pointState = {}
local pointReady = {}
local ptWaitFlag = cc.p(667,500)
local ptWinLoseAnimate = {}
local pointCardType = {}

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
    pointCardType = {}
    local CardTypeNode = self._csbNode:getChildByName("m_cardtype_node")
    for i = 1 ,cmd.GAME_PLAYER do
        local _CardTypeNode = CardTypeNode:getChildByName("m_node_"..i)
        local x,y = _CardTypeNode:getPosition();
        table.insert(pointCardType,cc.p(x,y))
    end 
    --桌面分数区域
    rectTableGold = nil
    local x = (yl.DESIGN_WIDTH/2) - 80;                          
    local y = (yl.DESIGN_HEIGHT/2) - 60;                          
    local w = 80 * 2;                        
    local h = 60 * 2;                            
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

function GameViewLayer:getParentNode()
	return self._scene
end

function GameViewLayer:onInitData()
	self.bCardOut = {false, false, false, false, false}
    self.sGoldNum = {0,0,0,0,0}
	self.cbCombineCard = {}
	self.chatDetails = {}
	self.bCanMoveCard = false
    self.bBtnInOutside = false
    self.bExplainInOutside = false
	self.cbGender = {}
    self.bankerChairID = nil
	self.bBtnInOutside = false
	self.bSpecialType  = false --特殊牌型标识
	self.cbSpecialCardType = 0 --特殊牌型代码
	self.bIsShowMenu = false --是否显示菜单
    self.bIsSendLastCard = false

	-- 用户头像
    self.m_tabUserHead = {}

    self._nMultiple = {}

	--房卡需要
	self.m_UserItem = {}
    self.sTableGold = {}
end

function GameViewLayer:onResetView()
    self:onRestart()
    self:stopAllClock()
    for i=1,cmd.GAME_PLAYER do
      self:OnUpdateUserExit(i)
	  self.tableScore[i]:setVisible(false)
      self.endScore[i]:setVisible(false)
	  self.cardType[i]:setVisible(false)  
    end
end

function GameViewLayer:showBtn(visible)
    self.btOpenCard:setVisible(visible)
    self.btPrompt:setVisible(visible)
end

function GameViewLayer:onRestart()
	self.spriteCalculate:setVisible(false)
	self._scene:stopAllActions()
    self.spriteBankerFlag:stopAllActions()
	self.spriteBankerFlag:setVisible(false)
    self:ClearTableGold()
    self.sTableGold = {}
    self.noOxImg:setVisible(false)
    for i=1,cmd.GAME_PLAYER do
      for j=1, cmd.MAX_CARDCOUNT do
        local pcard = self.nodeCard[i][j]
        pcard:setVisible(false)
        self:setCardTextureRect(i,j)
        if i == cmd.MY_VIEWID then
		    pcard:setPositionX(118*(j-1))
        else
            pcard:setPositionX(40*(j-1))
            pcard:setScale(0.8)
        end
      end
      
      self.pStateOpenCard[i]:setVisible(false)
      self:setReadyVisible(i,false)
      self:hiddenMultiple(i)
      self:setCallingBankerStatus(false,i)
      self.tableScore[i]:setVisible(false)
	  self.cardType[i]:setVisible(false)  
      self.endScore[i]:setVisible(false)  
      self:setBetsVisible(i,false)
      self:hiddenMulBet(i,false)
    end

	self.bCardOut = {false, false, false, false, false}
	self.bBtnMoving = false
    self.bIsSendLastCard = false
	self.labCardResult:setString("")
    self.bankerChairID = nil
    self.gCbSelf:setVisible(false)
    self.gCbOther:setVisible(false)
    self.gBetsSelf:setVisible(false)
    self.gOpenCardSelf:setVisible(false)
    self.btOpenCard:setVisible(false) --隐藏确定
    self.btPrompt:setVisible(false)   --隐藏提示
	for i = 1, 3 do
		self.labAtCardPrompt[i]:setString("")
	end

	local nodeCard = self._csbNode:getChildByName("m_opecard_node")
    for i=1, cmd.MAX_CARDCOUNT do
    	local panelCard = nodeCard:getChildByName(string.format("m_node_%d",i))
        local card = self.nodeCard[cmd.MY_VIEWID][i]
        card:setPosition(118*(i-1), panelCard:getContentSize().height/2)
    end

	self.cbCombineCard = {}	   --组合扑克
	self.bSpecialType  = false --特殊牌型标识
	self.cbSpecialCardType = 0 --特殊牌型代码

	self._scene.bAddScore = false
    self._scene.m_lMaxTurnScore = 0

	for viewId=1,cmd.GAME_PLAYER do
		if viewId ~= cmd.MY_VIEWID then 
			self:stopCardAni(viewId)
		end
	end	
    if self.pSpCard then 
        self.pSpCard:stopAllActions()
        self.pSpCard:setVisible(false)
    end

end


function GameViewLayer:onExit()
	print("GameViewLayer onExit")
	self:gameDataReset()
	cc.Director:getInstance():getTextureCache():removeTextureForKey("card.png")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("oxfive_all.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("oxfive_all.png")
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()

    AnimationMgr.removeCachedAnimation(cmd.VOICE_ANIMATION_KEY)
    for i=1,#AnimationRes do
    	cc.AnimationCache:getInstance():removeAnimation(AnimationRes[i].name)
    end 
end

function GameViewLayer:gameDataReset()
  --播放大厅背景音乐
  ExternalFun.playPlazzBackgroudAudio()
  self:unLoadRes()
end

local this
function GameViewLayer:ctor(scene)
	this = self
	self._scene = scene

	self.m_tabUserItem = {}
	self:onInitData()
	self:preloadUI()

	--牌节点
	self.nodeCard = {}
	--牌的类型
	self.cardType = {}
	
	--摊牌标志
	self.flag_openCard = {}

  	--导入资源
	self:loadRes()

    --初始化csb界面
    local rootLayer, csbNode = ExternalFun.loadRootCSB("game/GameScene.csb",self)
    self._csbNode = csbNode
    self:SetGameNode()
  	self:initCsbRes()
	self:initUserInfo()

    local mgr = self._scene._scene:getApp():getVersionMgr()
	local nVersion = mgr:getResVersion(cmd.KIND_ID) or "0"
	self._setLayer = GameSetLayer:create(nVersion)
    self:addChild(self._setLayer)
    self._setLayer:setLocalZOrder(GameViewLayer.ORDER_SET)
    self._setLayer:setVisible(false)

	--节点事件
	ExternalFun.registerNodeEvent(self) -- bind node event

    --播放背景音乐
    ExternalFun.setBackgroundAudio("sound_res/backMusic.mp3")

	--房卡需要
	--语音按钮
    if yl.HIDE_PAGE == false and GlobalUserItem.bPrivateRoom then
        self._scene._scene:createVoiceBtn(cc.p(1250, 200), 0, self)
    end

    -- 玩家头像
	self.m_bNormalState = {}

    -- 语音动画
    AnimationMgr.loadAnimationFromFrame("record_play_ani_%d.png", 1, 3, cmd.VOICE_ANIMATION_KEY)	

	--点击事件
	self:setTouchEnabled(true)
	self:registerScriptTouchHandler(function(eventType, x, y)
		return self:onEventTouchCallback(eventType, x, y)
	end)
end

--加载资源
function GameViewLayer:loadRes( )
  cc.Director:getInstance():getTextureCache():addImage("card.png")
  -- 语音动画
  AnimationMgr.loadAnimationFromFrame("record_play_ani_%d.png", 1, 3, cmd.VOICE_ANIMATION_KEY)

end

--移除资源
function GameViewLayer:unLoadRes()
  --卡牌
  cc.Director:getInstance():getTextureCache():removeTextureForKey("card.png")
  --语音动画
  AnimationMgr.removeCachedAnimation(cmd.VOICE_ANIMATION_KEY)

  cc.Director:getInstance():getTextureCache():removeUnusedTextures()
  cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

--加载csb
function GameViewLayer:initCsbRes()
    local  btcallback = function(ref, type)
        ExternalFun.btnEffect(ref, type)
        if type == ccui.TouchEventType.ended then
--            ExternalFun.playSoundEffect("oxnew_click.mp3")
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

     self.spButtonBg = display.newSprite("#oxfive_bg_btnlist.png")
        :setPosition(cc.p(60,662))   
        :setAnchorPoint(cc.p(0.25, 1))
        :setScale(0)
        :setLocalZOrder(GameViewLayer.ORDER_6)
        :addTo(self) 

    self.btExit = ccui.Button:create("oxfive_btn_back_normal.png","oxfive_btn_back_normal.png","",ccui.TextureResType.plistType)
        :setPosition(cc.p(119,338))
        :setTag(GameViewLayer.BT_EXIT)
        :addTo(self.spButtonBg)
    self.btExit:addTouchEventListener(btcallback)

    self.btChange = ccui.Button:create("oxfive_btn_changetable_normal.png","oxfive_btn_changetable_normal.png","",ccui.TextureResType.plistType)
        :setPosition(cc.p(119,254))
        :setTag(GameViewLayer.BT_CHANGE)
        :addTo(self.spButtonBg)
    self.btChange:addTouchEventListener(btcallback)

    self.btHelp = ccui.Button:create("oxfive_btn_help_normal.png","oxfive_btn_help_normal.png","",ccui.TextureResType.plistType)
        :setPosition(cc.p(119,168))
        :setTag(GameViewLayer.BT_HELP)
        :addTo(self.spButtonBg)
    self.btHelp:addTouchEventListener(btcallback)

    self.btSet = ccui.Button:create("oxfive_btn_setting_normal.png","oxfive_btn_setting_normal.png","",ccui.TextureResType.plistType)
        :setPosition(cc.p(119,77))
        :setTag(GameViewLayer.BT_SET)
        :addTo(self.spButtonBg)
    self.btSet:addTouchEventListener(btcallback)

    self.btSwitch = self._csbNode:getChildByName("m_btn_down")
		:setTag(GameViewLayer.BT_SWITCH)
	self.btSwitch:addTouchEventListener(btcallback)

    --说明
    self.spExplainBg = display.newSprite("#oxfive_btn_explain_normal.png")
		:setPosition(cc.p(201,662))   
        :setAnchorPoint(cc.p(0.38, 1))
        :setScale(0)
        :setLocalZOrder(GameViewLayer.ORDER_6)
        :addTo(self) 
    local spspExplain = display.newSprite("#oxfive_bg_explain.png")  
        :setPosition(cc.p(261,236))   
        :addTo(self.spExplainBg)

    self.btExplain = self._csbNode:getChildByName("m_btn_explain")
		:setTag(GameViewLayer.BT_EXPLAIN)
	self.btExplain:addTouchEventListener(btcallback)

    --庄家标志
    self.spriteBankerFlag = self._csbNode:getChildByName("m_banker")
        :setVisible(false)
    self.spriteRemainBankerFlag = self.spriteBankerFlag:getChildByName("m_remainbanker")
        :setVisible(false)
    self.textRemainBanker = self.spriteRemainBankerFlag:getChildByName("spriteRemainBankerFlag")

    --聊天按钮
    self.btnChat = self._csbNode:getChildByName("m_btnchat")
    self.btnChat:setTag(GameViewLayer.BT_CHAT)
    self.btnChat:addTouchEventListener(btcallback)

    --聊天框
    self._chatLayer = GameChatLayer:create(self._scene._gameFrame)
    self._chatLayer:addTo(self, 3)

    self.noOxImg = display.newSprite("#oxfive_icon_ox0.png")
         :setVisible(false)
         :setPosition(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2)
         :setLocalZOrder(GameViewLayer.ORDER_5)
         :setScale(0.3)
         :addTo(self)

	--桌面游戏币
	self.tableScore = {}
    --结算分数
    self.endScore = {}
	for i = 1, cmd.GAME_PLAYER do

        --牌型
		self.cardType[i] = cc.Node:create()
            :setPosition(pointCardType[i])
            :setLocalZOrder(GameViewLayer.ORDER_3)
			:setVisible(false)
			:addTo(self)

        --桌面游戏币
	    self.tableScore[i] = display.newSprite("#oxfive_icon_addimg.png")
		    :setPosition(pointTableScore[i])
		    :setVisible(false)
            :setLocalZOrder(GameViewLayer.ORDER_1)
	        :addTo(self)
	    cc.LabelAtlas:_create("0", GameViewLayer.RES_PATH.."oxfive_fonts_num1.png", 27, 36, string.byte("*"))
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
        local endScoreImg = display.newSprite("#oxfive_icon_addimg.png")
            :setPosition(0,30)
            :addTo(self.endScore[i])
        cc.LabelAtlas:_create("0", GameViewLayer.RES_PATH.."oxfive_fonts_num_win.png", 45, 54, string.byte("/"))
            :setPosition(50,30)
            :setAnchorPoint(cc.p(0, 0.5))
            :setTag(GameViewLayer.SCOREWIN)
            :addTo(self.endScore[i])
        cc.LabelAtlas:_create("0", GameViewLayer.RES_PATH.."oxfive_fonts_num_lose.png", 45, 54, string.byte("/"))
            :setPosition(50,30)
            :setAnchorPoint(cc.p(0, 0.5))
            :setTag(GameViewLayer.SCORELOSE)
            :addTo(self.endScore[i])
    end
    
    self.btOpenCard = self._csbNode:getChildByName("m_btnopencard")
		:setTag(GameViewLayer.BT_OPENCARD)
		:setVisible(false)
	self.btOpenCard:addTouchEventListener(btcallback)

    self.btPrompt = self._csbNode:getChildByName("m_btnprompt")
		:setTag(GameViewLayer.BT_PROMPT)
		:setVisible(false)
	self.btPrompt:addTouchEventListener(btcallback)

    --下注按钮
    self.btChip = {}
    for i = 1, 4 do
        self.btChip[i] = self._csbNode:getChildByName(string.format("m_btnchip%d",i))
    end

    self.txtBaseScore = self._csbNode:getChildByName("m_basescore_node"):getChildByName("m_basescore_txt")
    self.txtBaseScore:enableOutline(cc.c4b(167, 69, 75, 255), 1)
    self.txtBaseScore:setFontName(appdf.FONT_FILE)

    --叫庄倍数
    self.btMul = {}
    for i = 1, 6 do
        self.btMul[i] = self._csbNode:getChildByName(string.format("m_btncallbanker%d",i))
        local text = self.btMul[i]:getChildByName("text")
            :enableOutline(cc.c4b(255, 193, 100, 255), 2)
            :setFontName(appdf.FONT_FILE)
    end

    --开始
	self.btStart = self._csbNode:getChildByName("m_btnready")
		:setTag(GameViewLayer.BT_START)
	self.btStart:addTouchEventListener(btcallback)
	self.btStart:setVisible(false)

    --卡牌
    local nodeCard = self._csbNode:getChildByName("m_opecard_node")
    for i=1,cmd.GAME_PLAYER do
      local panelCard = nodeCard:getChildByName(string.format("m_node_%d",i))
      self.nodeCard[i] = {}
      for j=1, cmd.MAX_CARDCOUNT do
        local pcard = CardSprite:createCard()
        pcard:setVisible(false)
        pcard:setTag(j)
        panelCard:addChild(pcard)
        pcard:setLocalZOrder(j)
        table.insert(self.nodeCard[i], pcard)
        self:setCardTextureRect(i,j)
        if i == cmd.MY_VIEWID then
			pcard:setPosition(118*(j-1), panelCard:getContentSize().height/2)
        else
        	pcard:setPosition(40*(j-1), panelCard:getContentSize().height/2)
        	pcard:setScale(0.8)
        end

      end
    end

    --计分器
    self.spriteCalculate = self._csbNode:getChildByName("m_imgcalculate") 
    self.spriteCalculate:setVisible(false)

	--牌值
	self.labAtCardPrompt = {}
	for i = 1, 3 do
		self.labAtCardPrompt[i] = self.spriteCalculate:getChildByName(string.format("Text_%d",i)) 
	end
	self.labCardResult = self.spriteCalculate:getChildByName("Text_4")
    self.labCardType = self.spriteCalculate:getChildByName("m_ox")

    --游戏状态节点
    local gStetaNode = self._csbNode:getChildByName("m_gstate_node")

    self.gStateWait = gStetaNode:getChildByName("m_gwait")              --等待游戏开始
        :setVisible(false)
    self.gCbSelf = gStetaNode:getChildByName("m_gcallbanker_self")      --自己叫庄
        :setFontName("fonts/round_body.ttf")
        :setVisible(false)
    self.gCbOther = gStetaNode:getChildByName("m_gcallbanker_other")    --其他玩家叫庄
        :setVisible(false)
    self.gBetsSelf =  display.newSprite("#oxfive_icon_pleaseTZ.png")
        :setPosition(yl.WIDTH/2,341)
        :setVisible(false)
        :addTo(self,GameViewLayer.ORDER_2)
    self.gAntiCheatWait = gStetaNode:getChildByName("m_ganticheatwait")
        :setFontName("fonts/round_body.ttf")
        :setVisible(false)  
    self.gOpenCardSelf = display.newSprite("#oxfive_icon_pleaseTP.png")
        :setPosition(yl.WIDTH/2,341)
        :setVisible(false)
        :addTo(self,GameViewLayer.ORDER_2) 
    
    --用于发牌动作的那张牌
	self.animateCard = display.newSprite(GameViewLayer.RES_PATH.."card.png")
		:move(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2)
		:setVisible(false)
		:setLocalZOrder(3)
		:addTo(self)
	local cardWidth = self.animateCard:getContentSize().width/13
	local cardHeight = self.animateCard:getContentSize().height/5
	self.animateCard:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))
end

function GameViewLayer:setHeadClock(viewid,time)
    if time == 0 then return end
    local resSprite = display.newSprite("#oxfive_img_time.png")
    if viewid then 
        local playerNode = self.nodePlayer[viewid]
        if playerNode:getChildByTag(GameViewLayer.TAG_CLOCK) == nil then 
            ExternalFun.CreateHeadClock(resSprite,"oxfive_time.plist",GameViewLayer.TAG_CLOCK,cc.p(66,88),playerNode,time,nil)
        end
    else
        for i = 1, cmd.GAME_PLAYER do
            local useritem = self._scene._gameFrame:getTableUserItem(self.m_nTableID,i-1)  
            if useritem then
                local viewID = self._scene:SwitchViewChairID(i-1)
                local playerNode = self.nodePlayer[viewID]
                if playerNode:getChildByTag(GameViewLayer.TAG_CLOCK) == nil then 
                    ExternalFun.CreateHeadClock(resSprite,"oxfive_time.plist",GameViewLayer.TAG_CLOCK,cc.p(66,88),playerNode,time,nil)
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

function GameViewLayer:initUserInfo()
	print("faceNode",faceNode)
    --玩家断线重连等待操作
    self.ShowWaitPlayer = {}
    self.IsShowWait = false
    self.m_WaitFlag = nil

    --五个玩家
	self.nodePlayer = {}
    self.pStateOpenCard = {}
    self.pStateReady = {}
    self.pStateBets = {}
    self.pStateCbing = {}
    self.pStateRobMul = {}
    self.pStateMul = {}
    self.pStateMulNum = {}
    self.pStateRobMulNum = {}

    --房主标识
    self.flag_roomer = {}    
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
        self.pStateReady[i] = display.newSprite("#oxfive_icon_ready.png")
            :setPosition(pointReady[i])  
            :setVisible(false)
            :addTo(self,GameViewLayer.ORDER_4)      
        --摊牌状态
        self.pStateOpenCard[i] = display.newSprite("#oxfive_icon_ready.png")
            :setVisible(false)
            :setPosition(pointOpenCardFlag[i])
            :addTo(self,GameViewLayer.ORDER_3)
       
        --房主标识
		if GlobalUserItem.bPrivateRoom then
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("27_sp_roomerflag.png")
			if nil ~= frame then
				self.flag_roomer[i] = cc.Sprite:createWithSpriteFrame(frame)
					:move(-35, 60)
					:setVisible(false)
					:setLocalZOrder(1)
					:addTo(self.nodePlayer[i])
			end
		end
        --下注中标识
        self.pStateBets[i] = self.nodePlayer[i]:getChildByName("m_icon_bets")
            :setVisible(false)
            :setLocalZOrder(6)
        
        --玩家状态
        self.pStateCbing[i] = self.nodePlayer[i]:getChildByName("m_icon_opencard")  --叫庄
            :setVisible(false)
            :setLocalZOrder(6)

        self.pStateRobMul[i] = self.nodePlayer[i]:getChildByName("m_icon_rob_mul")
            :setVisible(false)

        self.pStateMul[i] = self.nodePlayer[i]:getChildByName("m_icon_mul")
            :setVisible(false)

        self.pStateMulNum[i] = self.nodePlayer[i]:getChildByName("m_text_mulnum")
            :setVisible(false)

        self.pStateRobMulNum[i] = self.nodePlayer[i]:getChildByName("m_text_rob_mulnum")
            :setVisible(false)

        --等待操作
        self.ShowWaitPlayer[i] = false
    end
end


--更新用户显示
function GameViewLayer:OnUpdateUser(viewId, userItem)
	if not viewId or viewId == yl.INVALID_CHAIR then
		print("OnUpdateUser viewId is nil")
		return
	end

    local spFlag = self.flag_roomer[viewId]
	self.m_tabUserItem[viewId] = userItem
	local head = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.FACE)
	if not userItem then
		self.nodePlayer[viewId]:setVisible(false)
        self:setReadyVisible(viewId, false)
		self.cbGender[viewId] = nil
		if head then
			head:setVisible(false)
            head:removeFromParent()
		end
		if spFlag then
			spFlag:setVisible(false)
		end
	else
		self.nodePlayer[viewId]:setVisible(true)
		self:setNickname(viewId, userItem.szNickName)
		self:setScore(viewId, userItem.lScore)
        self:setReadyVisible(viewId, yl.US_READY == userItem.cbUserStatus)
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

		local bRoomer = PriRoom:getInstance().m_tabPriData.dwTableOwnerUserID == userItem.dwUserID
		-- 桌主标识
		if GlobalUserItem.bPrivateRoom and nil ~= spFlag and bRoomer then
			spFlag:setVisible(true)
		end

         --自己准备后显示等待游戏开始
        if viewId == cmd.MY_VIEWID then  
            if yl.US_READY == userItem.cbUserStatus then 
                if self._scene._gameFrame.bEnterAntiCheatRoom == true and GlobalUserItem.isForfendGameRule() then 
                    self.gAntiCheatWait:setVisible(true)
                else
                    self.gStateWait:setVisible(true)  
                end
                self.btStart:setVisible(false)
                self.bankerChairID = nil
            else
                if yl.US_PLAYING == userItem.cbUserStatus or yl.US_LOOKON == userItem.cbUserStatus then 
                    self.btStart:setVisible(false)
                end
                self.gStateWait:setVisible(false)  
                self.gAntiCheatWait:setVisible(false) 
            end      
        end
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

-- 设置私有房的层级
function GameViewLayer:priGameLayerZorder()
    return 2
end
--****************************      计时器        *****************************--
function GameViewLayer:OnUpdataClockView(viewId, time)
	--print("计时器,viewId,time",viewId,time)
	if not viewId or viewId == yl.INVALID_CHAIR or not time then
        if viewId then 
            if viewId ~= cmd.MY_VIEWID then 
                self:setWaitPlayer(true)
            end  
        end 
	else
        if self.IsShowWait == true then           
            self:setWaitPlayer(false)
        end
	end
end

--**************************      点击事件        ****************************--
--点击事件
function GameViewLayer:onEventTouchCallback(eventType, x, y)
	if eventType == "began" then
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
            local worldPos = self:convertToWorldSpace(cc.p(self.spExplainBg:getPositionX(), self.spExplainBg:getPositionY()))
			local cardBox = self.spExplainBg:getBoundingBox()
            cardBox.x = worldPos.x - (self.spExplainBg:getAnchorPoint().x * self.spExplainBg:getContentSize().width)
            cardBox.y = worldPos.y - (self.spExplainBg:getAnchorPoint().y * self.spExplainBg:getContentSize().height)
            
            if cc.rectContainsPoint(cardBox, cc.p(x, y)) == false then 
		        self:onButtonExplainAnimate()
            end
	    end
	elseif eventType == "ended" then
		print("begin eventType,x,y",eventType,x,y)
		--用于触发手牌
		if self.bCanMoveCard ~= true then
			return false
		end
		local nodeCard = self._csbNode:getChildByName("m_opecard_node")
	    local panelCard = nodeCard:getChildByName(string.format("m_node_%d",cmd.MY_VIEWID))
		for i = 1, 5 do
			local card = self.nodeCard[cmd.MY_VIEWID][i]
			local pos2 = cc.p(card:getPositionX(),card:getPositionY())
			local pos2World = panelCard:convertToWorldSpace(pos2)  
			local size2 = card:getTextureRect()   --getContentSize()
			local rect = card:getTextureRect()
			local pos = cc.p(pos2World.x - size2.width/2, pos2World.y - size2.height/2)
			rect.x = pos.x  --x1 - size1.width/2 + x2 - size2.width/2
			rect.y = pos.y  --y1 - size1.height/2 + y2 - size2.height/2
		
			if cc.rectContainsPoint(rect, cc.p(x, y)) then
				if false == self.bCardOut[i] then
					--检测是否有三个牌了
					local selcetNum = 0
					for j=1,#self.bCardOut do
						if true == self.bCardOut[j] then
							selcetNum = selcetNum + 1
						end
					end
					if selcetNum >= 3 then
						print("已经有三张牌弹出")
						card:runAction(cc.Sequence:create(cc.MoveBy:create(0.1,cc.p(0,10)),cc.MoveBy:create(0.1,cc.p(0,-10))))
						return
					else
						card:runAction(cc.MoveTo:create(0.2,cc.p(pos2.x, pos2.y + 20)))
					end
				elseif true == self.bCardOut[i] then
					card:runAction(cc.MoveTo:create(0.25,cc.p(pos2.x, pos2.y - 20)))
				end
				self.bCardOut[i] = not self.bCardOut[i]
				self:updateCardPrompt()
				return true
			end
		end
	end
	return true
end

--按钮点击事件
function GameViewLayer:onButtonClickedEvent(tag,ref)
	if tag == GameViewLayer.BT_START then   --开始
		self.btStart:setVisible(false)
        self:ClearTableGold()
        if self._scene._gameFrame.bEnterAntiCheatRoom == true and GlobalUserItem.isForfendGameRule() then 
            self.gAntiCheatWait:setVisible(true)
        end
		self._scene:onStartGame()
	elseif tag == GameViewLayer.BT_SWITCH then  --菜单
		self:onButtonSwitchAnimate()
    elseif tag == GameViewLayer.BT_EXPLAIN then  --说明
        self:onButtonExplainAnimate()
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
		print("设置")
		self:onButtonSwitchAnimate()
		self._setLayer:onShow()
	elseif tag == GameViewLayer.BT_HELP then
		print("玩法")
		self:onButtonSwitchAnimate()
        if nil == self.layerHelp then
            self.layerHelp = HelpLayer:create(self, cmd.KIND_ID, 0)
            self.layerHelp:addTo(self)
            self.layerHelp:setLocalZOrder(GameViewLayer.ORDER_HELP)
        else
            self.layerHelp:onShow()
        end
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

            self._scene:onChangeDesk(1)
		    self:onResetView() 							--重置    
        end 
	elseif tag == GameViewLayer.BT_EXIT then
		self:onButtonSwitchAnimate()
		self._scene:onQueryExitGame()
	elseif tag == GameViewLayer.BT_OPENCARD then
        self.gOpenCardSelf:setVisible(false)
		self:onButtonConfirm(cmd.MY_VIEWID)
		self._scene:onOpenCard(self.cbCombineCard)
		dump(self.cbCombineCard, "the orignal cards")
	elseif tag == GameViewLayer.BT_PROMPT then
		self:promptOx()
--	elseif tag == TAG_ENUM.BT_CALLBANKER then
--		for i = 1, #self.btMul do
--			self.btMul[i]:setVisible(false)
--		end
--		self:showCallBankerMul()
	elseif tag == GameViewLayer.BT_CANCEL then
		for i = 1, #self.btMul do
			self.btMul[i]:setVisible(false)
		end
		self._scene:onBanker(false,0)
	elseif tag - GameViewLayer.BT_CHIP1 == 0 or tag - GameViewLayer.BT_CHIP1 == 1 or tag - GameViewLayer.BT_CHIP1 == 2 or tag - GameViewLayer.BT_CHIP1 == 3 or tag - GameViewLayer.BT_CHIP1 == 4  then
        for i = 1, #self.btChip do
	        self.btChip[i]:setVisible(false)
	    end
        
		local index = tag - GameViewLayer.BT_CHIP1+1
		self:getParentNode():onAddScore(index*5)
	elseif tag - GameViewLayer.BT_MUL1 == 0 or tag - GameViewLayer.BT_MUL1 == 1 or tag - GameViewLayer.BT_MUL1 == 2 or tag - GameViewLayer.BT_MUL1 == 3 or tag - GameViewLayer.BT_MUL1 == 4 then
        for i = 1, #self.btMul do
			self.btMul[i]:setVisible(false)
		end
		local index = tag - GameViewLayer.BT_MUL1+1

		print("index",index)
		self._scene:onBanker(true,index)
	else
		print("tag",tag)
		showToast(self,"功能尚未开放！",1)
	end
end

--自己开牌视图
function GameViewLayer:onButtonConfirm(viewid)
    if viewid  == cmd.MY_VIEWID then
        self.btOpenCard:setVisible(false) --隐藏确定框
        self.btPrompt:setVisible(false)   --隐藏提示
        self.spriteCalculate:setVisible(false) --隐藏计算框
        self.labCardType:setVisible(false)
        self.bCanMoveCard = false  --牌是否可以移动
    end
    
    local nodeCard = self._csbNode:getChildByName("m_opecard_node")
    local panelCard = nodeCard:getChildByName(string.format("m_node_%d",viewid))

	--牌回复位置
	for i=1, cmd.MAX_CARDCOUNT do
        local card = self.nodeCard[cmd.MY_VIEWID][i]
		card:setPosition(118*(i-1), panelCard:getContentSize().height/2)
    end
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

--叫庄
function GameViewLayer:gameCallBanker(callBankerViewId)
    if (callBankerViewId ~= cmd.MY_VIEWID) then 
        self.pStateCbing[callBankerViewId]:setVisible(true)
    end
    
	if callBankerViewId == cmd.MY_VIEWID then
		if self._scene.cbDynamicJoin == 0 then
        	self:showCallBankerMul()
        end
    end

    --关闭游戏等待提示
    self.gStateWait:setVisible(false)
    self.gAntiCheatWait:setVisible(false)
end

--叫庄
function GameViewLayer:onCallBanker(isShow)
    if isShow == nil then
        self.gCbSelf:setVisible(false)
        self.gCbOther:setVisible(false) 
        return 
    end

    if isShow then
        self.gCbSelf:setVisible(true)
        self.gCbOther:setVisible(false)                    
    else                                        --其他玩家叫庄
        self.gCbSelf:setVisible(false)
        self.gCbOther:setVisible(true)
    end

    --关闭游戏等待提示
    self.gStateWait:setVisible(false)
    self.gAntiCheatWait:setVisible(false)

end

--抢庄倍数
function GameViewLayer:setCallMultiple( callBankerViewId,multiple )
	self:setMultiple(callBankerViewId,multiple)
end

function GameViewLayer:setBankerMultiple(BankerViewId)
	for i=1,cmd.GAME_PLAYER do
    	local viewid = self._scene:SwitchViewChairID(i-1)
        if viewid ~= BankerViewId  then
    	    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),
    			cc.CallFunc:create(function ()
                     self:hiddenMultiple(viewid)
    		end)))
    	else	
    		if self._nMultiple[viewid] == 0 then
    			self:setCallMultiple(viewid,1)
    		end	
    	end
        self:setCallingBankerStatus(false,viewid)
    end
end

--显示叫庄倍数
function GameViewLayer:showCallBankerMul(visiable)
	if self._scene.cbDynamicJoin == 1 then
		return
	end
	
	if visiable == 0 then
        for i = 1, 6 do
		    self.btMul[i]:setVisible(false)
        end
		return
	end

	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
         	if ref:getTag() ~= 118 then
         		print("the tag ",ref:getTag())
         		self:playEffect("rober_bank_",GlobalUserItem.tabAccountInfo.cbGender)
         	end
        end
    end

	for i = 1, 6 do
		--按钮
		self.btMul[i]:setTag(GameViewLayer.BT_MUL1 + i -1)
	    self.btMul[i]:addTouchEventListener(btcallback)
        self.btMul[i]:setVisible(true)

	    if i == 6 then
	        self.btMul[i]:setTag(GameViewLayer.BT_CANCEL)
	    end
		
		--动画
	    self.btMul[i]:runAction(cc.Sequence:create(
	    	cc.DelayTime:create(0.1*(i-1)),
	    	cc.MoveBy:create(0.1,cc.p(0,25)),
	    	cc.MoveBy:create(0.1,cc.p(0,-25))
	    	))
	end
end

--游戏开始
function GameViewLayer:showChipBtn(bankerViewId)
    if bankerViewId ~= cmd.MY_VIEWID then
    	if self._scene.cbDynamicJoin == 0 then
	        for i = 1, #self.btChip do
	            self.btChip[i]:setVisible(true)
	        end
	    end
    end
end

function GameViewLayer:resetEffect( )
	   --停止闪烁
--    for i=1,cmd.GAME_PLAYER do
--    	local viewid = self._scene:SwitchViewChairID(i-1)
--    	if self.m_tabUserHead[viewid] then
--    		self.m_tabUserHead[viewid]:showFlashBg(false)
--    	end
--    end
end

function GameViewLayer:setCombineCard( data )
	self.cbCombineCard = clone(data)
end

function GameViewLayer:setSpecialInfo( bSpecial,cardType )
	--还有一种无牛的情况 扑克也不可操作
	if not GameLogic:getOxCard(self.cbCombineCard) then 
		self.bSpecialType = true
		self.cbSpecialCardType = 0
		self.bCanMoveCard = false

		return
	end

	self.bSpecialType = bSpecial
	self.bCanMoveCard = not bSpecial
	if cardType then
		self.cbSpecialCardType = cardType
	end


end

function GameViewLayer:gameAddScore(viewId, Mul,bShowEct)
    self.bIsSendLastCard = true
    local Score = tonumber(self.txtBaseScore:getString())*Mul
    local strScore = ""..Score
--	if score < 0 then
--		strScore = "/"..(-score)
--	end
    self.sGoldNum[viewId] = self:getGoldNum(math.abs(Mul),viewId)
	self.tableScore[viewId]:getChildByTag(GameViewLayer.SCORENUM):setString(strScore)
	self.tableScore[viewId]:setVisible(true)
    if bShowEct then 
        display.newSprite()
	            :setPosition(pointTableScore[viewId].x+80,pointTableScore[viewId].y)
	            :addTo(self,GameViewLayer.ORDER_2)
                :runAction(self:getAnimate("addscore", true)) 
    end 

   -- local labelScore = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SCORE)
    --local lScore = tonumber(labelScore:getString())
   -- self:setScore(viewId, lScore-Score)
    if viewId == cmd.MY_VIEWID then
        self.gBetsSelf:setVisible(false)
    end
    self:setMulBet(viewId,Mul)
    self:setBetsVisible(viewId, false)
    -- 自己下注, 隐藏下注信息
    if viewId == cmd.MY_VIEWID then
    	for i = 1, 4 do
	        self.btChip[i]:setVisible(false)
	    end
    end
end

--发牌
function GameViewLayer:gameSendCard(firstViewId, sendCount)
	print("开始发牌")
	if sendCount == 0 then
		print("发牌数为0")
		return
	end
    self.gBetsSelf:setVisible(false) 
    --self:setBankerWaitStatus(false)

	--开始发牌
	local wViewChairId = firstViewId  --首先发牌的玩家
    for i=1,cmd.GAME_PLAYER do
        wViewChairId = self._scene:SwitchViewChairID(i - 1)
		if self._scene:isPlayerPlaying(wViewChairId) then
            break
        end
    end
    self:sendCardAnimate(wViewChairId,sendCount * self._scene:getPlayNum())
    self._scene:sendCardFinish()
end

--parm viewId 发送到哪一个位置
--parm count 发送的数量
function GameViewLayer:sendCardAnimate(wViewChairId,sendCount)
    local nodeCard = self._csbNode:getChildByName("m_opecard_node")
    local sendCardPosX,sendCardPosY =self._csbNode:getChildByName("m_sendcard"):getPosition()
    local panelCard = {}
    for i =1,cmd.GAME_PLAYER  do
        panelCard[i] = nodeCard:getChildByName(string.format("m_node_%d",i))
    end

    local nPlayerNum = self._scene:getPlayNum()
    local nCount = sendCount
	if nCount == nPlayerNum*5 then
		self.animateCard:setVisible(true)
        --ExternalFun.playSoundEffect("oxnew_send_card.mp3")
	elseif nCount < 1 then
		self.animateCard:setVisible(false)
        if self.pSpCard then 
            self.pSpCard:stopAllActions()
            self.pSpCard:setVisible(false)
            self.pSpCard = nil
        end
        if self._scene:isPlayerPlaying(cmd.MY_VIEWID) then
            self:showBtn(true)
        end 
		self.bCanMoveCard = true
		return
--    elseif  nCount == nPlayerNum  then
--        self.animateCard:setVisible(true)
	end

    self.pSpCard = CardSprite:createCard()
        :setTextureRect(cc.rect(2*110.0,4*150.0,110,150))
        :setPosition(cc.p(sendCardPosX,sendCardPosY))
        :setVisible(false)
        :setLocalZOrder(3)
        :setRotation(70)
        :setScale(0.3)
    	:addTo(self)
    self.animateCard:setVisible(false)

    local cardNum = 1
    if self.bIsSendLastCard then
        cardNum = math.floor(5 - nCount/(nPlayerNum))+1
        print("cardNUm......................",cardNum)
    else
        cardNum = math.floor(5 - nCount/(nPlayerNum))
    end
    
    local pos = cc.p(0,0)
    if wViewChairId == cmd.MY_VIEWID then
        pos = cc.p(panelCard[wViewChairId]:getPositionX() + (cardNum-1) * self.animateCard:getContentSize().width,panelCard[wViewChairId]:getPositionY())
    else
        pos = cc.p(panelCard[wViewChairId]:getPositionX() + (cardNum-1) * 40,panelCard[wViewChairId]:getPositionY())
    end
    
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
                            local nTag = 1
                            if self.bIsSendLastCard then
                                nTag = math.floor(5 - nCount/(nPlayerNum))+1
                            else
                                nTag = math.floor(5 - nCount/(nPlayerNum))
                            end
                            local card = self.nodeCard[wViewChairId][nTag]
				            if not card then return end
				            card:setVisible(true)
                            --开始下一个人的发牌
				            wViewChairId = wViewChairId + 1
				            if wViewChairId > 5 then
					            wViewChairId = 1
				            end
				            while not self._scene:isPlayerPlaying(wViewChairId) do
					            wViewChairId = wViewChairId + 1
					            if wViewChairId > 5 then
						            wViewChairId = 1
					            end
				            end
				            self:sendCardAnimate(wViewChairId, nCount - 1)
                        end))
    else
        aniCard = cc.Sequence:create(
                        cc.Show:create(),
			            cc.Spawn:create(cc.ScaleTo:create(fSpeed,otherScale),cc.MoveTo:create(fSpeed, pos),cc.RotateTo:create(fSpeed,0)),                         
                        cc.RemoveSelf:create(),                       
			            cc.CallFunc:create(function()
				            --显示一张牌
                            local nTag = 1
                            if self.bIsSendLastCard then
                                nTag = math.floor(5 - nCount/(nPlayerNum))+1
                            else
                                nTag = math.floor(5 - nCount/(nPlayerNum))
                            end
                            local card = self.nodeCard[wViewChairId][nTag]
				            if not card then return end
				            card:setVisible(true)
                            --开始下一个人的发牌
				            wViewChairId = wViewChairId + 1
				            if wViewChairId > 5 then
					            wViewChairId = 1
				            end
				            while not self._scene:isPlayerPlaying(wViewChairId) do
					            wViewChairId = wViewChairId + 1
					            if wViewChairId > 5 then
						            wViewChairId = 1
					            end
				            end
				            self:sendCardAnimate(wViewChairId, nCount - 1)
                        end))
    end
	self.pSpCard:runAction(aniCard)
end

--摆牌动画
function GameViewLayer:puttingCardAni(viewId)
	for i=1,cmd.MAX_CARDCOUNT do
	    local action = cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(0,10)), cc.MoveBy:create(0.1, cc.p(0, -10)))
	    local repaction = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(i*0.05), action, cc.DelayTime:create((cmd.MAX_CARDCOUNT-i)*0.05 )))
	    local card = self.nodeCard[viewId][i]
	    if nil ~= card then
	      card:stopAllActions()
	      card:runAction(repaction)
	    end
  	end
end

--停止卡牌摆牌运动
function GameViewLayer:stopCardAni( wViewChairId )
	if wViewChairId ~= cmd.MY_VIEWID then
		local nodeCard = self._csbNode:getChildByName("m_opecard_node")
		local panelCard = nodeCard:getChildByName(string.format("m_node_%d",wViewChairId))
		for i=1,cmd.MAX_CARDCOUNT do
			self.nodeCard[wViewChairId][i]:stopAllActions()
			self.nodeCard[wViewChairId][i]:setPosition(28*(i-1), panelCard:getContentSize().height/2)
		end
	end
end



--获取移动动画
--inorout,0表示加速飞出,1表示加速飞入
--isreverse,0表示不反转,1表示反转
function GameViewLayer:getMoveActionEx(time,startPoint, endPoint,height,angle)
   	--把角度转换为弧度
    angle = angle or 90
    height = height or 50
    local radian = angle*3.14159/180.0
    --第一个控制点为抛物线左半弧的中点  
    local q1x = startPoint.x+(endPoint.x - startPoint.x)/4.0;  
    local q1 = cc.p(q1x, height + startPoint.y+math.cos(radian)*q1x);         
    -- 第二个控制点为整个抛物线的中点  
    local q2x = startPoint.x + (endPoint.x - startPoint.x)/2.0;  
    local q2 = cc.p(q2x, height + startPoint.y+math.cos(radian)*q2x);  
    --曲线配置  
    local bezier = {
        q1,
        q2,
        endPoint
    }
    --使用EaseInOut让曲线运动有一个由慢到快的变化，显得更自然  
    local beaction = cc.BezierTo:create(time, bezier)
    --if inorout == 0 then
    local easeoutaction = cc.EaseOut:create(beaction, 1)
    return easeoutaction
    --else
        --return cc.EaseIn:create(beaction, 1)
    --end
end

--获取移动动画
--inorout,0表示加速飞出,1表示加速飞入
--isreverse,0表示不反转,1表示反转
-- function GameViewLayer:getMoveAction(time,beginpos, endpos, inorout, isreverse)
--     local offsety = (endpos.y - beginpos.y)*0.7
--     local controlpos = cc.p(beginpos.x, beginpos.y+offsety)
--     if isreverse == 1 then
--         offsety = (beginpos.y - endpos.y)*0.7
--         controlpos = cc.p(endpos.x, endpos.y+offsety)
--     end
--     local bezier = {
--         controlpos,
--         endpos,
--         endpos
--     }
--     local beaction = cc.BezierTo:create(time, bezier)
--     if inorout == 0 then
--         return cc.EaseOut:create(beaction, 1)
--     else
--         return cc.EaseIn:create(beaction, 1)
--     end
-- end

--开牌动画 --viewid 玩家视图位置  index 
function GameViewLayer:openCardAnimate( viewid,index )
	local scaleMul = viewid == cmd.MY_VIEWID and 1 or 0.8
	if index then --单张牌
		local card = self.nodeCard[viewid][index]
		card:runAction(cc.Sequence:create(
			cc.ScaleTo:create(0.15,0.1,scaleMul),
			cc.CallFunc:create(function ( )
				self._scene:openOneCard(viewid,index)
			end),
			cc.ScaleTo:create(0.15,scaleMul,scaleMul)
			))
	else --五张牌
		for i=1,cmd.MAX_CARDCOUNT do
			local card = self.nodeCard[viewid][i]
			card:runAction(cc.Sequence:create(
				cc.DelayTime:create(i*0.05),
				cc.ScaleTo:create(0.15,0.1,scaleMul),
				cc.CallFunc:create(function (  )
					self._scene:openOneCard(viewid,i,true)
				end),
				cc.ScaleTo:create(0.15,scaleMul,scaleMul)
				))
		end
	end
end
function GameViewLayer:resetCardByType(cards,cardType )
	--dump(cards, "the card data =====")
	--dump(cardType, "the card type =====")
	for i=1,cmd.GAME_PLAYER do
		for idx=1,cmd.MAX_CARDCOUNT do
			if (cards[i][idx] ~= 0) and (cardType[i] >= 0) then
				local viewId = self._scene:SwitchViewChairID(i-1)
				local card = self.nodeCard[viewId][idx]
				assert(card)
				local nodeCard = self._csbNode:getChildByName("m_opecard_node")
				local panelCard = nodeCard:getChildByName(string.format("m_node_%d",viewId))
				local posX = (viewId==cmd.MY_VIEWID) and 118*(idx-1) or 40*(idx-1)
--				if (cardType[i] > 0 and idx > 3) then
--					posX = posX + ((viewId==cmd.MY_VIEWID) and 40 or 25)
--				end
			
				card:setPosition(posX, panelCard:getContentSize().height/2)	
			end
		end
	end
end

--开牌
function GameViewLayer:gameOpenCard(wViewChairId, cbOx)

	--开牌动画
	--self:openCardAnimate(wViewChairId)
	--牌型
	if cbOx >= 10 then
		self._scene:PlaySound(GameViewLayer.RES_PATH.."sound/GAME_OXOX.wav")
		cbOx = 10
	end

	--隐藏摊牌图标
    self:setOpenCardVisible(wViewChairId, false)
    --声音
    if bEnded and wViewChairId == cmd.MY_VIEWID then
    	local strGender = "GIRL"
    	if self.cbGender[wViewChairId] == 1 then
			strGender = "BOY"
		end
    	local strSound = GameViewLayer.RES_PATH.."sound/"..strGender.."/ox_"..cbOx..".MP3"
		self._scene:PlaySound(strSound)
    end
end

--游戏结束
function GameViewLayer:gameEnd(lScore,lCardType,cbPlayStatus)
    self.btOpenCard:setVisible(false)
    self.btPrompt:setVisible(false)   --隐藏提示
	local bankerViewId = self._scene:SwitchViewChairID(self._scene.wBankerUser)
	local index = self._scene:GetMeChairID() + 1
	local bMeWin = lScore[index] > 0
	if bMeWin then
		self:playEffect("gameWin.mp3")
	else
		self:playEffect("gameLose.mp3")
	end

    self.btStart:setVisible(true)
	-- 隐藏牌信息
	self.spriteCalculate:setVisible(false)
    self.labCardType:setVisible(false)
    for i = 1, cmd.GAME_PLAYER do 
        --桌面游戏币
	    self.tableScore[i]:setVisible(false)
        self:setOpenCardVisible(i,false)
    end

    for i = 1, #self.btMul do
		self.btMul[i]:setVisible(false)
    end

    for i = 1, #self.btChip do
        self.btChip[i]:setVisible(false)
    end
    
	for i=1,cmd.GAME_PLAYER do	
		--类型
		local viewid = self._scene:SwitchViewChairID(i-1)
        
		--分数
        if cbPlayStatus[i] == 1 then
            self:ShowCardType(lCardType[i] ,viewid)
            self:runWinLoseAnimate(viewid,lScore[i])
        end
		if  (self._scene.cbCardData and #self._scene.cbCardData>0 and self._scene.cbPlayStatus and self._scene.cbPlayStatus[i] > 0 ) then		
			if self._scene.cbCardData[i][1] ~= 0 and lCardType[i] then
				if lCardType[i] >=0 and  lCardType[i] <= 10 then
					print("lCardType[i]",lCardType[i])
					if viewid == cmd.MY_VIEWID then
						local soundFile = "niu_"..string.format("%d_",lCardType[i])
						self:playEffect(soundFile,GlobalUserItem.tabAccountInfo.cbGender)
					end	
				elseif lCardType[i] > 10 then --特殊牌型
					if soundFile and  (viewid == cmd.MY_VIEWID) then
						self:playEffect(soundFile,GlobalUserItem.tabAccountInfo.cbGender)
					end
				end
			end
		end	
	end
end

function GameViewLayer:showRoomRule( config )
	local roomRuleInfoStr = ""
    local roomRuleInfoTTF =  self._csbNode:getChildByName("Text_info")
    assert(roomRuleInfoTTF)
  

      --房间类型
    local cardType = {"经典模式","疯狂加倍"}
    local sendType = {"发四等五","下注发牌"}
    local bankerType = {"霸王庄","倍数抢庄","牛牛上庄","无牛下庄"}

    roomRuleInfoStr = roomRuleInfoStr..cardType[config.cardType-22+1]..","..sendType[config.sendCardType-32+1]..","..bankerType[config.bankGameType-52+1]
    roomRuleInfoTTF:setString(roomRuleInfoStr)
    roomRuleInfoTTF:setVisible(true)

end

--计算器动画
--1.是否显示 2.是否有动画 
function GameViewLayer:showCalculate(isShow,isAni)
	if self._scene.cbDynamicJoin == 1 then
		return
	end
     
	if self.bSpecialType then  --特殊牌型 只显示牌型按钮
		if self._scene.m_tabPrivateRoomConfig.cardType == cmd.CARDTYPE_CONFIG.CT_CLASSIC then  --经典模式
			self.labCardType:loadTexture(string.format("oxfive_icon_ox%d.png",self.cbSpecialCardType),1)
		elseif self._scene.m_tabPrivateRoomConfig.cardType == cmd.CARDTYPE_CONFIG.CT_ADDTIMES then --疯狂加倍
			self.labCardType:loadTexture(string.format("oxfive_icon_ox%d.png",self.cbSpecialCardType),1)
		end	
		self.labCardType:setScale(0.6)
		return
	end

	isAni = isAni or false
	local moveTime = 1
	local moveDistanceY = 50
	local spriteCalculatePos = cc.p(self.spriteCalculate:getPositionX(),self.spriteCalculate:getPositionY())
	if isShow then --是否显示
		if isAni == true then --动画
			self.spriteCalculate:setVisible(isShow)
			self.spriteCalculate:setPosition(cc.p(spriteCalculatePos.x,spriteCalculatePos.y-moveDistanceY))
			local moveAction = cc.EaseBackInOut:create(cc.MoveBy:create(moveTime,cc.p(0,moveDistanceY)))
			local spawn = cc.Spawn:create(cc.FadeIn:create(moveTime),moveAction)
			self.spriteCalculate:runAction(cc.Sequence:create(
				spawn,
				cc.CallFunc:create(function ()
					self.spriteCalculate:setVisible(isShow)
					--self.btOpenCard:setVisible(isShow)
				end)
				))
		else
			self.spriteCalculate:setPosition(spriteCalculatePos)
			self.spriteCalculate:setVisible(isShow)
			--self.btOpenCard:setVisible(isShow)
		end
	else
		if isAni == true then --动画
			self.spriteCalculate:setPosition(spriteCalculatePos)
			local moveAction = cc.EaseBackIn:create(cc.MoveBy:create(moveTime,cc.p(0,-moveDistanceY)))
			local spawn = cc.Spawn:create(cc.FadeIn:create(moveTime),moveAction)
			self.spriteCalculate:runAction(cc.Sequence:create(
				spawn,
				cc.CallFunc:create(function (  )
					self.spriteCalculate:setVisible(isShow)
					--self.btOpenCard:setVisible(isShow)
				end)
				))
		else
			self.spriteCalculate:setVisible(isShow)
			--self.btOpenCard:setVisible(isShow)
		end
	end
end

--游戏状态
--function GameViewLayer:gameScenePlaying()
--	if self._scene.cbDynamicJoin == 0 then
--		if self.bSpecialType then 
--            self.btOpenCard:setVisible(true)
--            self.btPrompt:setVisible(true)
--			if self._scene.m_tabPrivateRoomConfig.cardType == cmd.CARDTYPE_CONFIG.CT_CLASSIC then  --经典模式
--				self.labCardType:loadTexture(string.format("oxfive_icon_ox%d.png",self.cbSpecialCardType),1)
--			elseif self._scene.m_tabPrivateRoomConfig.cardType == cmd.CARDTYPE_CONFIG.CT_ADDTIMES then --疯狂加倍
--				self.labCardType:loadTexture(string.format("oxfive_icon_ox%d.png",self.cbSpecialCardType),1)
--			end	
--		    self.labCardType:setScale(0.6)
--			return
--		end

--	    self.spriteCalculate:setVisible(true)
--	end
--end

--设置底分
function GameViewLayer:setCellScore(cellscore)
	if not cellscore then
		self.txt_CellScore:setString("底注：")
	else
		self.txt_CellScore:setString("底注："..cellscore)
	end
end

--设置纹理
function GameViewLayer:setCardTextureRect(viewId, tag, cardValue, cardColor)
	if viewId < 1 or viewId > 5 or tag < 1 or tag > 5 then
		print("card texture rect error!")
		return
	end
	if cardValue == nil or  cardColor == nil then --背面牌
		--print("背面牌")
		local card = self.nodeCard[viewId][tag]
		local rectCard = card:getTextureRect()
		rectCard.x = rectCard.width*2
		rectCard.y = rectCard.height*4
		card:setTextureRect(rectCard)
	else
		--特殊处理大小王
		local tempCardValue = cardValue
		if cardValue == 14 then --小王
			tempCardValue = 2
		elseif cardValue == 15 then --大王
			tempCardValue = 1
		end
		local card = self.nodeCard[viewId][tag]
		local rectCard = card:getTextureRect()
		rectCard.x = rectCard.width*(tempCardValue - 1)
		rectCard.y = rectCard.height*cardColor
		card:setTextureRect(rectCard)
	end

end

function GameViewLayer:updateScore(viewId)
--	if self.m_tabUserHead[viewId] then
--		self.m_tabUserHead[viewId]:updateStatus()
--	end	
end

function GameViewLayer:setTableID(id)
	if not id or id == yl.INVALID_TABLE then
		self.txt_TableID:setString("桌号：")
	else
		self.txt_TableID:setString("桌号："..(id + 1))
	end
end


function GameViewLayer:setUserScore(wViewChairId, lScore)
	self.nodePlayer[wViewChairId]:getChildByTag(GameViewLayer.SCORE):setString(lScore)
end

function GameViewLayer:OnUpdateUserExit(viewId)
    self:OnUpdateUser(viewId,nil)
end

-- 积分按钮
function GameViewLayer:setScoreJetton( )
	if self._scene.cbDynamicJoin == 1 then
		return
	end
	
	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    self:showCallBankerMul(0)

    --配置下注积分的数目
	for i = 1, 4 do
            self.btChip[i]:setTag(GameViewLayer.BT_CHIP1 + i -1)
            self.btChip[i]:setVisible(false)
			self.btChip[i]:addTouchEventListener(btcallback)

            local chipText = self.btChip[i]:getChildByName("m_text_chip")
            chipText:setFontName(appdf.FONT_FILE)
            chipText:setString( string.format("%d倍", i*5))
            chipText:enableOutline(cc.c4b(255, 193, 100, 255), 2)

	        self.btChip[i]:runAction(cc.Sequence:create(
	        	cc.DelayTime:create(0.1*(i-1)),
	        	cc.MoveBy:create(0.1,cc.p(0,25)),
	        	cc.MoveBy:create(0.1,cc.p(0,-25))
	        	))
	end
end

--function GameViewLayer:setTurnMaxMulToScore()
--end

function GameViewLayer:setBankerUser(wViewChairId,cbDynamicJoin)
    self.bankerChairID = wViewChairId
    if cbDynamicJoin == 0 then 
        local fSpeed = 0.5
        self.spriteBankerFlag:setVisible(true)
        self.spriteBankerFlag:setScale(1)
        self.spriteBankerFlag:setPosition(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2)
        self.spriteBankerFlag:runAction(cc.Spawn:create(cc.ScaleTo:create(fSpeed,0.4),cc.MoveTo:create(fSpeed, pointBankerFlag[wViewChairId])))
        --ExternalFun.playSoundEffect("oxnew_player_chip.mp3")
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

--检查牌类型
function GameViewLayer:updateCardPrompt()
	--弹出牌显示，统计和
	local nSumTotal = 0
	local nSumOut = 0
	local nCount = 1
	local bJoker = false  --大小王百搭标识
	--dump(self._scene.cbCardData)
	self.cbCombineCard = {}
	local normalCard = {}
	for i = 1, 5 do
		local nCardValue = self._scene:getMeCardLogicValue(i)
		nSumTotal = nSumTotal + nCardValue
		if self.bCardOut[i] then  --选中的卡牌
	 		if nCount <= 3 then
	 			local  temp = nCardValue
	 			if temp == GameLogic.KingValue then 
	 				temp = 10 
	 				nCardValue = temp
	 				bJoker = true
	 				self.labAtCardPrompt[nCount]:setString("王")
	 			else
	 				self.labAtCardPrompt[nCount]:setString(temp)
	 			end
	 			
	 		end
	 		nCount = nCount + 1
			nSumOut = nSumOut + nCardValue
			table.insert(self.cbCombineCard,self._scene:getMeCardValue(i))
		else
			table.insert(normalCard, i)	
		end
		
	end

	for i = nCount, 3 do
		self.labAtCardPrompt[i]:setString("")
		self:setCombineCard(self._scene:getMeCardValue())
	end

	--判断是否构成牛
	if nCount == 1 then
		self.labCardResult:setString("")
        self.labCardType:setVisible(false)
		self:setCombineCard(self._scene:getMeCardValue())
	elseif nCount == 3 then 		--弹出两张牌
		self.labCardResult:setString("")
		self:setCombineCard(self._scene:getMeCardValue())
	elseif nCount == 4 then 		--弹出三张牌
		if true == bJoker then
			nSumOut = nSumOut - 10
			local mod = math.mod(nSumOut,10)
			nSumOut = nSumOut - mod
			nSumOut = nSumOut + 10
		end
		self.labCardResult:setString(nSumOut)

		for i=1,#normalCard do
			local index = normalCard[i]
			table.insert(self.cbCombineCard,self._scene:getMeCardValue(index))
		end
		self.labCardType:setVisible(true)
		local ox_type = GameLogic:getCardType(self.cbCombineCard)
         print("牌型%d",ox_type)
		self.labCardType:loadTexture(string.format("oxfive_icon_ox%d.png",ox_type),1)
		normalCard = {}
	else
		self.labCardResult:setString("")
        self.labCardType:setVisible(false)
		self:setCombineCard(self._scene:getMeCardValue())
	end
end

function GameViewLayer:onShowNoOx()
    self.noOxImg:setVisible(true)
    self.noOxImg:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(1),cc.ScaleTo:create(1,0.5)),
                                            cc.Spawn:create(cc.FadeOut:create(1),cc.ScaleTo:create(1,0.5)),
                                            cc.CallFunc:create(function()
                                                                    self.noOxImg:setVisible(false)
                                                                    self.noOxImg:setScale(0.3)
                                                                end)))
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
    cc.SpriteFrameCache:getInstance():addSpriteFrames(GameViewLayer.RES_PATH.."oxfive_all.plist")
end

function GameViewLayer:getAnimate(name, bEndRemove)
	print("name",name)
	local animation = cc.AnimationCache:getInstance():getAnimation(name)
	print("animation",animation)
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
			local card = self.nodeCard[cmd.MY_VIEWID][i]
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
					local card = self.nodeCard[cmd.MY_VIEWID][i]
					local x, y = card:getPosition()
					y = y + 30
					card:move(x, y)
					self.bCardOut[i] = true
				end
			end
		end
    else
        if self.noOxImg:getNumberOfRunningActions() == 0 then
            self:onShowNoOx()
        end
	end

	self:updateCardPrompt()
end

-- 文本聊天
function GameViewLayer:onUserChat(chatdata, viewId)
    local playerItem = self.m_tabUserHead[viewId]
    print("获取当前显示聊天的玩家头像", playerItem, viewId, chatdata.szChatString)
    if nil ~= playerItem then
        playerItem:textChat(chatdata.szChatString)
        self._chatLayer:showGameChat(false)
    end
end

-- 表情聊天
function GameViewLayer:onUserExpression(chatdata, viewId)
    local playerItem = self.m_tabUserHead[viewId]
    if nil ~= playerItem then
        playerItem:browChat(chatdata.wItemIndex)
        self._chatLayer:showGameChat(false)
    end
end

--显示语音
function GameViewLayer:ShowUserVoice(viewid, isPlay)
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

--根据下注金额获取
function GameViewLayer:getGoldNum(chipMul,viewId)    
    return math.floor(chipMul)
end

function GameViewLayer:logicClockInfo(chair,time,clockId)
	 -- body
    if clockId == cmd.IDI_NULLITY then
        if time <= 5 then
        	if self._scene.cbDynamicJoin == 0 then
            	self:playEffect("GAME_WARN.WAV")
       		end
        end
    elseif clockId == cmd.IDI_START_GAME then
        if time <= 0 then
        	if self._scene.cbDynamicJoin == 0 then
           		self._scene._gameFrame:setEnterAntiCheatRoom(false)--退出防作弊
                self._scene:onExitTable()--及时退出房间
        	end
            self._scene:KillGameClock()
        elseif time <= 5 then
            self:playEffect("GAME_WARN.WAV")
        end
    elseif clockId == cmd.IDI_CALL_BANKER then
--        if time < 1 then
--        	if self._scene.cbDynamicJoin == 0 then
--	            self:onButtonClickedEvent(GameViewLayer.BT_CANCEL)
--        	end	
--            self._scene:KillGameClock()
--        end
    elseif clockId == cmd.IDI_TIME_USER_ADD_SCORE then
        if time < 1 then
--        	if self._scene.cbDynamicJoin == 0 then
--	            if self._scene.wBankerUser ~= self._scene:GetMeChairID() then
--	                self:onButtonClickedEvent(GameViewLayer.BT_CHIP1)
--	            end
--        	end	

--            self._scene:KillGameClock()
        elseif time <= 5 then
        	if self._scene.cbDynamicJoin == 0 then
           		self:playEffect("GAME_WARN.WAV")
        	end
        end
    elseif clockId == cmd.IDI_TIME_OPEN_CARD then
        self.gOpenCardSelf:setVisible(false)
--        if time < 1 then
--        	if self._scene.cbDynamicJoin == 0 then
--	            self:setCombineCard(self._scene:getMeCardValue())
--                self:onButtonClickedEvent(GameViewLayer.BT_OPENCARD)
--        	end	

--            self._scene:KillGameClock()
--        end
    end
end

function GameViewLayer:playEffect( file,sex )
    if GlobalUserItem.nSound == 0 then
        return
    end

  if nil ~= sex then
  	assert((sex==0) or (sex==1))
  	if (sex>1) or (sex<0) then
  		return
  	end
  	local extra = (sex==0) and "w.mp3" or "m.mp3"
  	file = "sound_res/"..file..extra
  else
  	file = "sound_res/"..file
  end

  print("the file is =================================",file)
 
  ExternalFun.playSoundEffect(file)
end

function GameViewLayer:setMultiple(viewId,multiple )
    self._nMultiple[viewId] = multiple
    self:setCallingBankerStatus(false,viewId)
    if 0 ~= multiple then
        self.pStateRobMulNum[viewId]:setVisible(true)
        self.pStateRobMulNum[viewId]:setString(multiple)
        self.pStateRobMul[viewId]:loadTexture("oxfive_icon_robmul.png",1)
    else
        self.pStateRobMulNum[viewId]:setVisible(false)
        self.pStateRobMul[viewId]:loadTexture("oxfive_icon_norob.png",1)
    end
    self.pStateRobMul[viewId]:setVisible(true)
end

function GameViewLayer:hiddenMultiple(viewId)
    self.pStateRobMul[viewId]:setVisible(false)
    self.pStateRobMulNum[viewId]:setVisible(false)
end

function GameViewLayer:hiddenMulBet(viewId)
    self.pStateMul[viewId]:setVisible(false)
    self.pStateMulNum[viewId]:setVisible(false)
end

function GameViewLayer:setMulBet(viewId,lMul)
    self.pStateMul[viewId]:setVisible(true)
    self.pStateMulNum[viewId]:setVisible(true)
    self.pStateMulNum[viewId]:setString(lMul)
end

function GameViewLayer:setReadyVisible(wViewChairId, isVisible)
    self.pStateReady[wViewChairId]:setVisible(isVisible)
end

function GameViewLayer:setBetsVisible(wViewChairId, isVisible)
    self.pStateBets[wViewChairId]:setVisible(isVisible)
end

function GameViewLayer:setRobVisible(wViewChairId, isVisible)
    self.pStateRob[wViewChairId]:setVisible(isVisible)
end

function GameViewLayer:setOpenCardVisible(wViewChairId, isVisible)
	self.pStateOpenCard[wViewChairId]:setVisible(isVisible)
end

function GameViewLayer:setCallingBankerStatus(isCalling,viewId)
    if isCalling == true then
       self:hiddenMultiple(viewId)
    end
   
    if (viewId ~= cmd.MY_VIEWID) then 
        self.pStateCbing[viewId]:setVisible(isCalling)
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

function GameViewLayer:setBankerWaitStatus(isShow)
    -- self.gBetsOther:setVisible(isShow)  
end

--运行输赢动画
function GameViewLayer:runWinLoseAnimate(viewid, score)
    self.endScore[viewid]:setVisible(true)
    self.endScore[viewid]:setPosition(ptWinLoseAnimate[viewid])
    if score > 0 then   
        self.endScore[viewid]:getChildByTag(GameViewLayer.SCOREWIN):setString("/"..score)
            :setVisible(true)
        self.endScore[viewid]:getChildByTag(GameViewLayer.SCORELOSE):setVisible(false)

        local bgFram = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxfive_bg_winhead.png")
        self.nodePlayer[viewid]:setSpriteFrame(bgFram) 
        display.newSprite()
	            :setPosition(self.nodePlayer[viewid]:getPosition())
	            :addTo(self,GameViewLayer.ORDER_2)
                :runAction(cc.Sequence:create(
                                self:getAnimate("win", true), 
                                cc.CallFunc:create(function()
                                    local bgFram = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxfive_bg_head.png")
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
                self.cardType[viewid]:setVisible(false)
            end)))
end

--播放下注金币动画
function GameViewLayer:runChipAnimate(goldNum,viewID)
    for i = 1,goldNum do 
        local sGold = display.newSprite("#oxfive_icon_gold_normal.png")
                    :setLocalZOrder(GameViewLayer.ORDER_1)
                    :setPosition(self.nodePlayer[viewID]:getPosition())
                    :addTo(self)
        sGold:runAction(cc.MoveTo:create(0.5, self:getTableGoldPosOnTable()))
        table.insert(self.sTableGold,sGold)
    end
end

--获取下注金币停留位置
function GameViewLayer:getTableGoldPosOnTable()
    local x = math.random(rectTableGold.x,rectTableGold.x+rectTableGold.width);
    local y = math.random(rectTableGold.y,rectTableGold.y+rectTableGold.height);
    return cc.p(x,y)
end

function GameViewLayer:setGoldAnimateTime(index)
    if #self.sTableGold >= 60 and #self.sTableGold <= 90 then 
        index = math.floor(index/2+0.5)
    elseif #self.sTableGold > 90 and #self.sTableGold <= 120 then 
        index = math.floor(index/3+0.7)
    elseif #self.sTableGold > 120 then 
        index = math.floor(index/4+0.8)
    end
    return index
end

--清空金币
function GameViewLayer:ClearTableGold()
    if self.sTableGold ~= nil then 
        for k,v in pairs(self.sTableGold) do
            self.sTableGold[k]:stopAllActions()
            self.sTableGold[k]:removeFromParent()          
            self.sTableGold[k] = nil;
        end
    end
    self.sGoldNum = {0,0,0,0,0}
end

--吐出多输的金币动画
function GameViewLayer:runOtherGoldAnimate(tLoseScore)
    if self.bankerChairID == nil then -- 无庄家
        print("庄家信息错误")
        return 
    end 
    dump(tLoseScore) 
    local bOutGold = false
    local winloseNum = {0,0,0,0,0}
    local endNum = {0,0,0,0,0}

    for k,v in pairs(tLoseScore) do 
        if self.bankerChairID ~= k then 
            local num = v/tonumber(self.txtBaseScore:getString()) 
            --local num = self:getGoldNum(lMul,k) 
            winloseNum[k] = num
            if v < 0 then  --输钱
                if num + self.sGoldNum[k] < 0 then
                    self:runChipAnimate(math.abs(num + self.sGoldNum[k]),k)
                    bOutGold = true 
                end
                endNum[k] =  winloseNum[k] + self.sGoldNum[k]
            else
                endNum[k] =  winloseNum[k]
            end
        end
        self:setUserTableScore(k, 0)
    end
    local bankNum = self:getBankWinLoseNum(endNum,self.sGoldNum)
    if bankNum > 0 then 
        self:runChipAnimate(bankNum,self.bankerChairID)
        bOutGold = true
    else
        endNum[self.bankerChairID] = math.abs(bankNum)
    end
    if bOutGold == true then 
        local seq = cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
                            self:runGoldAnimate(endNum)
			                end));  
        self:runAction(seq); 
    else
        self:runGoldAnimate(endNum)
    end
end

function GameViewLayer:getBankWinLoseNum(tabEnd,tabBegin)
    local num = 0
    for i = 1 ,cmd.GAME_PLAYER do 
        num = tabEnd[i] - tabBegin[i] + num 
    end
    return num  
end

function GameViewLayer:setGoldNum()
    local goldNum = 0
    for i = 1 ,cmd.GAME_PLAYER do 
        local labelScore = self.tableScore[i]:getChildByTag(GameViewLayer.SCORENUM)       
        local lMul = tonumber(labelScore:getString())/tonumber(self.txtBaseScore:getString())

        if lMul == 0 then 
            self.sGoldNum[i] = 0
        else
            self.sGoldNum[i] = self:getGoldNum(lMul,i)
        end
        goldNum = self.sGoldNum[i] + goldNum
    end
    local Num = goldNum - #self.sTableGold
    if Num > 0 then 
        for i = 1,Num do 
            local sGold = display.newSprite("#oxfive_icon_gold_normal.png")
                        :setLocalZOrder(GameViewLayer.ORDER_1)
                        :setPosition(self:getTableGoldPosOnTable())
                        :addTo(self)
            table.insert(self.sTableGold,sGold)
        end
    end
end

--结算金币动画
function GameViewLayer:runGoldAnimate(winGoldNum)
--    local beginNum = 0   
--    local allNum = 0
--    local time = 1
--    if #self.sTableGold >= 40 and #self.sTableGold <= 90 then 
--        time = 3
--    elseif #self.sTableGold > 90 then 
--        time = 4
--    end
--    local timeGap = time/#self.sTableGold
--    if self.sTableGold ~= nil then 
--        for k,v in pairs(winGoldNum) do 
--            if v > 0 then 
--                allNum = allNum + v
--                for i = beginNum + 1, allNum do
--                    if self.sTableGold[i] ~= nil then 
--                        self.sTableGold[i]:setLocalZOrder(GameViewLayer.ORDER_4)
--                        self.sTableGold[i]:runAction(cc.Sequence:create(        
--                            cc.DelayTime:create((i-1)*timeGap),                
--			                cc.MoveTo:create(0.3, cc.p(self.nodePlayer[k]:getPositionX(),self.nodePlayer[k]:getPositionY())),
--			                cc.CallFunc:create(function()
--                                self.sTableGold[i]:removeFromParent()          
--                                self.sTableGold[i] = nil;
--			                end)))
--                     end
--                end 
--                beginNum = allNum
--            end
--        end
--    end

    local allTime = 1
    if #self.sTableGold > 20 then
        allTime = 2
    end
    local timeGap = allTime/#self.sTableGold
    for i = 1, #self.sTableGold do 
        local pgold = self.sTableGold[i]      
        for k, v in pairs(winGoldNum) do  
            if v > 0 then 
                local moveaction = cc.MoveTo:create(0.3, cc.p(self.nodePlayer[k]:getPositionX(), self.nodePlayer[k]:getPositionY()))
                pgold:runAction(
                    cc.Sequence:create(
                        cc.DelayTime:create((i-1)*timeGap + 1.6),
                        moveaction,
                        cc.CallFunc:create(function()
                                self.sTableGold[i]:removeFromParent()          
                                self.sTableGold[i] = nil;
			                end)
                    )
                )
                winGoldNum[k] = winGoldNum[k] - 1
                break
            end                    
        end
    end
end

function GameViewLayer:ShowCardType(cbOx,wViewChairId)
    if self.cardType[wViewChairId]:isVisible() then return end

    if self.cardType[wViewChairId] then
        self.cardType[wViewChairId]:removeAllChildren()
    end

    local offsetX = 0
    local offsetY = 0
    local scale = 1
    if wViewChairId ~= cmd.MY_VIEWID then
        scale = 0.8
    end   
    local pSprite = display.newSprite(string.format("#oxfive_icon_ox%d.png", cbOx))
    local pSpBg = nil   
    if cbOx == 0 then
        pSpBg = display.newSprite("#oxfive_bg_cardtype0.png")
    else       
        if cbOx >= 10 then 
            pSpBg = display.newSprite("#oxfive_bg_cardtype2.png")
        else
            pSpBg = display.newSprite("#oxfive_bg_cardtype1.png")
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

function GameViewLayer:setBaseScore(lScore)
    self.txtBaseScore:setString(lScore)
end

return GameViewLayer