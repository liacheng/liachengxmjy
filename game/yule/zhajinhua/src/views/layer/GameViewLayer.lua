local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)

local module_pre = "game.yule.zhajinhua.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local GameChat = appdf.req(appdf.PUB_GAME_VIEW_SRC.."GameChatLayer")
local cmd = appdf.req(appdf.GAME_SRC.."yule.zhajinhua.src.models.CMD_Game")
local PopupInfoHead = appdf.req("client.src.external.PopupInfoHead")

local CompareView = appdf.req(appdf.GAME_SRC.."yule.zhajinhua.src.views.layer.CompareView")
local GameEndView = appdf.req(appdf.GAME_SRC.."yule.zhajinhua.src.views.layer.GameEndView")
local SettingLayer = appdf.req(appdf.GAME_SRC.."yule.zhajinhua.src.views.layer.GameSetLayer")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationMgr = appdf.req(appdf.EXTERNAL_SRC .. "AnimationMgr")
local HelpLayer = appdf.req(module_pre .. ".views.layer.HelpLayer")
local GameSystemMessage = require(appdf.EXTERNAL_SRC .. "GameSystemMessage")
GameViewLayer.TAG_GAMESYSTEMMESSAGE = 6751

GameViewLayer.BT_EXIT 				= 1
GameViewLayer.BT_CHAT 				= 2
GameViewLayer.BT_GIVEUP				= 3
GameViewLayer.BT_READY				= 4
GameViewLayer.BT_LOOKCARD			= 5
GameViewLayer.BT_FOLLOW				= 6
GameViewLayer.BT_ADDSCORE			= 7
GameViewLayer.BT_CHIP				= 8
GameViewLayer.BT_CHIP_1				= 9
GameViewLayer.BT_CHIP_2				= 10
GameViewLayer.BT_CHIP_3				= 11
GameViewLayer.BT_COMPARE 			= 12
GameViewLayer.BT_CARDTYPE			= 13
GameViewLayer.BT_SET				= 14
GameViewLayer.BT_MENU				= 15
GameViewLayer.BT_BANK 				= 16
GameViewLayer.BT_VOICE_ENDED		= 17
GameViewLayer.BT_VOICE_BEGAN		= 18
GameViewLayer.BT_HELP 				= 19
GameViewLayer.BT_EXPLAIN            = 20
GameViewLayer.BT_CHANGE             = 21
GameViewLayer.CHIPNUM 				= 100

GameViewLayer.TIMENUM   			= 1
GameViewLayer.FRAME 				= 1
GameViewLayer.NICKNAME 				= 2
GameViewLayer.SCORE 				= 3
GameViewLayer.READY 				= 4
GameViewLayer.BGANTE                = 5
GameViewLayer.ANTE                  = 6
GameViewLayer.FACE 					= 7

GameViewLayer.ORDER_1               = 1
GameViewLayer.ORDER_2               = 2
GameViewLayer.ORDER_3               = 3
GameViewLayer.ORDER_4               = 4
GameViewLayer.ORDER_5               = 5
GameViewLayer.ORDER_SET             = 9
GameViewLayer.ORDER_HELP            = 10


local ptPlayer = {cc.p(91, 540), cc.p(91, 279), cc.p(168, 63), cc.p(1245, 280), cc.p(1245, 540)}
local ptCoin = {}
local ptCard = {cc.p(237, 562), cc.p(237, 300), cc.p(605, 179), cc.p(1013, 300), cc.p(1013, 562)}
local ptArrow = {}
local ptLookCard = {cc.p(280, 530), cc.p(280, 270), cc.p(660, 190), cc.p(1055, 270), cc.p(1055, 530)}
local ptAddScore = {cc.p(280, 530), cc.p(280, 270), cc.p(660, 190), cc.p(1055, 270), cc.p(1055, 530)}
local ptGiveUpCard = {cc.p(280, 530), cc.p(280, 270), cc.p(660, 190), cc.p(1060, 270), cc.p(1060, 530)}
local ptStateFlag = {cc.p(285, 530), cc.p(285, 270), cc.p(660, 190), cc.p(1060, 270), cc.p(1060, 530)}
local ptState = {}
local ptChat = {cc.p(175, 635), cc.p(175, 395), cc.p(524, 312), cc.p(1159, 395), cc.p(1159, 635)}
local ptUserInfo = {cc.p(175, 430), cc.p(130, 340), cc.p(593, 225), cc.p(790, 340), cc.p(746, 430)}
local anchorPoint = {cc.p(0, 0), cc.p(0, 0), cc.p(0, 0), cc.p(1, 0), cc.p(1, 0)}
local pointClock = {}
local StateFlag = {0,0,0,0,0}
local ptWaitFlag = cc.p(667,500)

function GameViewLayer:OnResetView(bStart)
	self:stopAllActions()

	self.btReady:setVisible(false)
	self:OnShowIntroduce(false)

	self.m_ChipBG:setVisible(false)
	self.nodeButtomButton:setVisible(false)
    self.m_GameEndView:setVisible(false)

	--self:SetBanker(yl.INVALID_CHAIR)
	self:SetAllTableScore(0)
	self:SetCompareCard(false)
	self:CleanAllJettons()
	self:StopCompareCard()
	self:SetMaxCellScore(0)
   
	for i = 1 ,cmd.GAME_PLAYER do
        if bStart == nil then 
            self:OnUpdateUser(i,nil)
        end
		self:SetLookCard(i, false)
		self:SetUserCardType(i)
		self:SetUserTableScore(i, 0)
		self:SetUserGiveUp(i,false)
		self:SetUserCard(i, nil)
        self:clearCard(i)
	end
end

function GameViewLayer:onExit()
	print("GameViewLayer onExit")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(cmd.RES.."zhajinhua_all.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey(cmd.RES.."zhajinhua_all.png")
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()

    AnimationMgr.removeCachedAnimation(cmd.VOICE_ANIMATION_KEY)
    self.m_actVoiceAni:release()
    self.m_actVoiceAni = nil
end

function GameViewLayer:getParentNode()
    return self._scene
end
function GameViewLayer:SetGameNode()
    --时钟节点
    pointClock = {}
    local ClockNode = self._csbNode:getChildByName("m_clock_node")
    for i = 1 ,cmd.GAME_PLAYER do
        local _ClockNode = ClockNode:getChildByName("m_node_"..i)
        local x,y = _ClockNode:getPosition();
        table.insert(pointClock,cc.p(x,y))
    end
    --状态节点
    ptState = {}
    local StateNode = self._csbNode:getChildByName("m_pstate_node")
    for i = 1 ,cmd.GAME_PLAYER do
        local _StateNode = StateNode:getChildByName("m_node_"..i)
        local x,y = _StateNode:getPosition();
        table.insert(ptState,cc.p(x,y))
    end
    --下注节点
    ptCoin = {}
    local ChipNode = self._csbNode:getChildByName("m_chip_node")
    for i = 1 ,cmd.GAME_PLAYER do
        local _ChipNode = ChipNode:getChildByName("m_node_"..i)
        local x,y = _ChipNode:getPosition();
        table.insert(ptCoin,cc.p(x,y))
    end
    --比牌箭头
    ptArrow = {}
    local ArrowNode = self._csbNode:getChildByName("m_arrow_node")
    for i = 1 ,cmd.GAME_PLAYER do
        local _ArrowNode = ArrowNode:getChildByName("m_node_"..i)
        local x,y = _ArrowNode:getPosition();
        table.insert(ptArrow,cc.p(x,y))
    end
end
function GameViewLayer:ctor(scene)
    ExternalFun.setBackgroundAudio("sound_res/zhajinhua_bgm.mp3")
	local this = self

    self.m_UserChat = {}
    ExternalFun.registerNodeEvent(self) -- bind node event

	self._scene = scene

	self.nChip = {1, 2, 5}

    display.loadSpriteFrames(cmd.RES.."zhajinhua_all.plist",cmd.RES.."zhajinhua_all.png")
	-- 语音动画
    AnimationMgr.loadAnimationFromFrame("record_play_ani_%d.png", 1, 3, cmd.VOICE_ANIMATION_KEY)

    self._csbNode = cc.CSLoader:createNode(cmd.RES.."game/GameScene.csb")
		:addTo(self, 1)
    --获得节点pos
    self:SetGameNode()

	--按钮回调
	local  btcallback = function(ref, type)
        ExternalFun.btnEffect(ref, type)
        if type == ccui.TouchEventType.began then
            ExternalFun.playSoundEffect("zhajinhua_click.mp3")
            ExternalFun.popupTouchFilter(1, false)
        elseif type == ccui.TouchEventType.canceled then
            ExternalFun.dismissTouchFilter()
        elseif type == ccui.TouchEventType.ended then
        	ExternalFun.dismissTouchFilter()
			this:OnButtonClickedEvent(ref:getTag(),ref)
        end
    end


	--筹码缓存
	self.nodeChipPool = cc.Node:create():addTo(self)
        :setLocalZOrder(GameViewLayer.ORDER_2)

    --所有下注
	self.m_txtAllScore = self._csbNode:getChildByName("m_score_zongzhu")

    self.nodeButtomButton = self._csbNode:getChildByName("m_btn_bottom")        
		:setVisible(false)

	--弃牌按钮
	self.btGiveUp = self.nodeButtomButton:getChildByName("m_btn_qipai")
		:setTag(GameViewLayer.BT_GIVEUP)

	--看牌按钮
	self.btLookCard = self.nodeButtomButton:getChildByName("m_btn_kanpai")
		:setTag(GameViewLayer.BT_LOOKCARD)

	self.bCompareChoose = false
	--比牌按钮
	self.btCompare = self.nodeButtomButton:getChildByName("m_btn_bipai")
		:setTag(GameViewLayer.BT_COMPARE)
	
	--加注按钮
	self.btAddScore = self.nodeButtomButton:getChildByName("m_btn_jiazhu")
		:setTag(GameViewLayer.BT_ADDSCORE)
	
	--跟注按钮
	self.btFollow = self.nodeButtomButton:getChildByName("m_btn_genzhu")
		:setTag(GameViewLayer.BT_FOLLOW)
	
	self.btGiveUp:addTouchEventListener(btcallback)
	self.btLookCard:addTouchEventListener(btcallback)
	self.btCompare:addTouchEventListener(btcallback)
	self.btAddScore:addTouchEventListener(btcallback)
	self.btFollow:addTouchEventListener(btcallback)

	--玩家
	self.nodePlayer = {}
	--比牌判断区域
	self.rcCompare = {}

	self.m_UserHead = {}

	self.txtConfig = string.getConfig(appdf.FONT_FILE , 20)
	self.MytxtConfig = string.getConfig(appdf.FONT_FILE , 24)

    --玩家
    self.nodePlayer = {}
    for i = 1,cmd.GAME_PLAYER do
        self.rcCompare[i] = cc.rect(ptPlayer[i].x - 78 , ptPlayer[i].y - 96 , 157 , 192)
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
        local stateReady = self.nodePlayer[i]:getChildByName("m_icon_ready")
            :setVisible(false)
            :setTag(GameViewLayer.READY)
    end

	--时钟
	self.m_TimeProgress = {}

    --时钟
	self.spriteClock = display.newSprite("#zhajinhua_bg_clock.png")
		:setVisible(false)
        :setLocalZOrder(GameViewLayer.ORDER_2)
		:addTo(self)
	local labAtTime = ccui.Text:create("", "fonts/round_body.ttf", 32)
        :setColor(cc.c3b(197, 0, 0))
		:setPosition(self.spriteClock:getContentSize().width/2, self.spriteClock:getContentSize().height/2-6)
		:setAnchorPoint(cc.p(0.5, 0.5))
		:setTag(GameViewLayer.TIMENUM)
		:addTo(self.spriteClock)

	--手牌显示
	self.userCard = {}
	--下注显示
	self.m_ScoreView = {}
	--准备显示
	--self.m_flagReady = {}
	--比牌箭头
	self.m_flagArrow = {}
	--看牌标示
	self.m_LookCard = {}
	--弃牌标示
	self.m_GiveUp = {}
    --跟注标示
	self.m_Follow = {}
	--加注标示
	self.m_AddScore = {}
    --状态表示框
    self.m_StateK = {}

    --玩家断线重连等待操作
    self.ShowWaitPlayer = {}
    self.IsShowWait = false
    self.m_WaitFlag = nil
    -- 玩家头像
	self.m_bNormalState = {}
	for i = 1, cmd.GAME_PLAYER do
		self.m_ScoreView[i] = {}
		--下注背景
		--if i ~= cmd.MY_VIEWID then
			self.m_ScoreView[i].frame = display.newSprite("#zhajinhuabg_xiazhu_kuang.png")
                :setLocalZOrder(GameViewLayer.ORDER_2)
				:setPosition(ptCoin[i])
				:setVisible(false)
				:addTo(self)
		--end
		--下注数额
		self.m_ScoreView[i].score = cc.LabelAtlas:create("0",cmd.RES.."zhajinhua_fonts_normal.png",18,25,string.byte("*"))
            :setAnchorPoint(cc.p(0,0.5))
		    :setPosition(55,21)
            :setVisible(false)
            :addTo(self.m_ScoreView[i].frame)
        --金币标签
        display.newSprite("#zhajinhua_icon_gold_small.png")
            :setPosition(22,20)
            :addTo(self.m_ScoreView[i].frame)

		self.userCard[i] = {}
		self.userCard[i].card = {}
		--牌区域
		self.userCard[i].area = cc.Node:create()
            :setLocalZOrder(GameViewLayer.ORDER_2)
			:setVisible(false)
			:addTo(self)
        
        
		--牌显示
		for j = 1, 3 do
			self.userCard[i].card[j] = display.newSprite("#zhajinhua_card_back.png")
					:move(ptCard[i].x + (i==cmd.MY_VIEWID and 60 or 45)*(j - 1), ptCard[i].y)
					:setVisible(false)
					:addTo(self.userCard[i].area)

			if i ~= cmd.MY_VIEWID then
				self.userCard[i].card[j]:setScale(0.7)
			end
		end

		--牌类型
		self.userCard[i].cardType = display.newSprite("#zhajinhua_icon_cardtype_0.png")
			:move(ptCard[i].x +  (i==cmd.MY_VIEWID and 70 or 55), ptCard[i].y- (i == 3 and 32 or 21))
			:setVisible(false)
			:addTo(self.userCard[i].area)


		--等待比牌箭头
		self.m_flagArrow[i] = display.newSprite("#zhajinhua_bg_jiantou.png")
                :setLocalZOrder(GameViewLayer.ORDER_1)
				:move(ptArrow[i])
				:setVisible(false)
				:addTo(self)

		--看牌标记
		self.m_LookCard[i] = display.newSprite("#zhajinhua_icon_kanpai.png")
			:setVisible(false)
            :setLocalZOrder(GameViewLayer.ORDER_3)
			:move(ptStateFlag[i])
			:addTo(self)

		--弃牌标示
		self.m_GiveUp[i] = display.newSprite("#zhajinhua_icon_qipai.png")
			:setVisible(false)
            :setLocalZOrder(GameViewLayer.ORDER_3)
			:move(ptStateFlag[i])
			:addTo(self)

        --跟注标示
		self.m_Follow[i] = display.newSprite("#zhajinhua_icon_genzhu.png")
			:setVisible(false)
            :setLocalZOrder(GameViewLayer.ORDER_3)
			:move(ptStateFlag[i])
			:addTo(self)

        --加注标示
		self.m_AddScore[i] = display.newSprite("#zhajinhua_icon_jiazhu.png")
			:setVisible(false)
            :setLocalZOrder(GameViewLayer.ORDER_3)
			:move(ptStateFlag[i])
			:addTo(self)

        --状态框标示
        self.m_StateK[i] = display.newSprite("#zhajinhua_bg_gezhu_kuang.png",{scale9 = true ,capInsets=cc.rect(15, 44, 16, 46)})
            :setVisible(false)
            :setPosition(ptState[i])   
            :setLocalZOrder(GameViewLayer.ORDER_3)
            :addTo(self)         
        if i== 3 then
            self.m_StateK[i]:setContentSize(cc.size(246, 164))
        else
            self.m_StateK[i]:setContentSize(cc.size(208, 148))
        end
--		self.m_flagReady[i] =  display.newSprite("#room_ready.png")
--			:move(ptReady[i])
--			:setVisible(false)
--			:addTo(self)

		if i ~= cmd.MY_VIEWID then
			self.userCard[i].cardType:setScale(0.9)
		end
        self.ShowWaitPlayer[i] = false
	end

    --底注信息
	self.txt_CellScore = self._csbNode:getChildByName("m_score_danzhu")
    self.txt_CellScore:setFontName("fonts/round_body.ttf")
	--封顶显示
	self.txt_MaxCellScore = self._csbNode:getChildByName("m_score_fengding")
    self.txt_MaxCellScore:setFontName("fonts/round_body.ttf")
			
	--庄家
--	self.m_BankerFlag = display.newSprite("#banker.png")
--		:setVisible(false)
--		:addTo(self)
	--筹码按钮
--	self.m_ChipBG = display.newSprite("#game_chip_bg.png")		--背景
--		:move(1000, 145)
--		:setVisible(false)
--		:addTo(self)
    self.m_ChipBG = self._csbNode:getChildByName("m_chip")		--背景
        :setVisible(false)
	self.btChip = {}
    for i = 1, 3 do 
        self.btChip[i] = self.m_ChipBG:getChildByName("m_btn_chip"..i)
            :setTag(GameViewLayer.BT_CHIP + i)     
        self.btChip[i]:getChildByName("m_text_score")
            :setFontName("fonts/round_body.ttf")
            :setString("")
            :setTag(GameViewLayer.CHIPNUM)
        self.btChip[i]:addTouchEventListener(btcallback)
    end

    self.btMenu = self._csbNode:getChildByName("m_btn_down")
        :setTag(GameViewLayer.BT_MENU)
    self.btMenu:addTouchEventListener(btcallback)

	--显示菜单
	self.m_bShowMenu = false

    self.m_AreaMenu = display.newSprite("#zhajinhua_bg_back.png",{scale9 = true ,capInsets=cc.rect(0, 50, 146, 32)})
        :setPosition(cc.p(58,675))   
        :setContentSize(cc.size(235, 389))
        :setAnchorPoint(cc.p(0.2, 1))
        :setScale(0)
        :setLocalZOrder(GameViewLayer.ORDER_5)
        :addTo(self) 

    self.btExit = ccui.Button:create("zhajinhua_btn_back_normal.png","zhajinhua_btn_back_normal.png","",ccui.TextureResType.plistType)
        :setPosition(cc.p(117,310))
        :setTag(GameViewLayer.BT_EXIT)
        :addTo(self.m_AreaMenu)
    self.btExit:addTouchEventListener(btcallback)

    self.btChange = ccui.Button:create("zhajinhua_btn_changetable_normal.png","zhajinhua_btn_changetable_normal.png","",ccui.TextureResType.plistType)
        :setPosition(cc.p(117,227))
        :setTag(GameViewLayer.BT_CHANGE)
        :addTo(self.m_AreaMenu)
    self.btChange:addTouchEventListener(btcallback)

    self.btHelp = ccui.Button:create("zhajinhua_btn_help_normal.png","zhajinhua_btn_help_normal.png","",ccui.TextureResType.plistType)
        :setPosition(cc.p(117,142))
        :setTag(GameViewLayer.BT_HELP)
        :addTo(self.m_AreaMenu)
    self.btHelp:addTouchEventListener(btcallback)

    self.btSet = ccui.Button:create("zhajinhua_btn_setting_normal.png","zhajinhua_btn_setting_normal.png","",ccui.TextureResType.plistType)
        :setPosition(cc.p(117,58))
        :setTag(GameViewLayer.BT_SET)
        :addTo(self.m_AreaMenu)
    self.btSet:addTouchEventListener(btcallback)

    --说明
    self.m_bShowExplain = false
    self.btExplain = self._csbNode:getChildByName("m_btn_explain")
        :setTag(GameViewLayer.BT_EXPLAIN)
    self.btExplain:addTouchEventListener(btcallback)

    --菜单背景
    self.m_AreaExplain = display.newSprite("#zhajinhua_bg_back.png",{scale9 = true ,capInsets=cc.rect(50, 50, 46, 32)})
		:setPosition(cc.p(146,675))   
        :setContentSize(cc.size(300,472))
        :setAnchorPoint(cc.p(0.44, 1))
        :setScale(0)
        :setLocalZOrder(GameViewLayer.ORDER_5)
        :addTo(self) 
    local spspExplain = display.newSprite("#zhajinhua_bg_explain.png")  
        :setPosition(cc.p(150,226))   
        :addTo(self.m_AreaExplain)

    --开始按钮
    self.btReady = ccui.Button:create("zhajinhua_btn_yellow_normal.png","zhajinhua_btn_yellow_normal.png","",ccui.TextureResType.plistType)
        :setPosition(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/4)
        :setVisible(false)
        :setLocalZOrder(GameViewLayer.ORDER_4)
        :setTag(GameViewLayer.BT_READY)
        :addTo(self)
    self.btReady:addTouchEventListener(btcallback)
    local tabReady = display.newSprite("#zhajinhua_btntab_ready.png")
        :setPosition(self.btReady:getContentSize().width/2,self.btReady:getContentSize().height/2)
        :addTo(self.btReady)
    
    --游戏状态节点
    self.gStateWait = self._csbNode:getChildByName("m_gwait")              --等待游戏开始
        :setVisible(false)

    self.gAntiCheatWait = self._csbNode:getChildByName("m_ganticheatwait")
        :setFontName("fonts/round_body.ttf")
        :setVisible(false)
--	--缓存聊天
--	self.m_UserChatView = {}
--	--聊天泡泡
--	for i = 1 , cmd.GAME_PLAYER do
--		if i <= cmd.MY_VIEWID then
--		self.m_UserChatView[i] = display.newSprite("#game_chat_lbg.png"	,{scale9 = true ,capInsets=cc.rect(30, 14, 46, 20)})
--			:setAnchorPoint(cc.p(0,0.5))
--			:move(ptChat[i])
--			:setVisible(false)
--			:addTo(self)
--		else
--		self.m_UserChatView[i] = display.newSprite( "#game_chat_rbg.png",{scale9 = true ,capInsets=cc.rect(14, 14, 46, 20)})
--			:setAnchorPoint(cc.p(1,0.5))
--			:move(ptChat[i])
--			:setVisible(false)
--			:addTo(self)
--		end
--	end

	--牌型介绍
	self.bIntroduce = false
--	self.cardTypeIntroduce = display.newSprite("#card_type.png")
--		:move(-163, display.cy)
--		:setVisible(false)
--		:addTo(self)
--        :setLocalZOrder(GameViewLayer.ORDER_5)

	--点击事件
--	local touch = display.newLayer()
--		:setLocalZOrder(10)
--		:addTo(self)
--	touch:setTouchEnabled(true)
--	touch:registerScriptTouchHandler(function(eventType, x, y)
--		return this:onTouch(eventType, x, y)
--	end)
    --点击事件
	self:setTouchEnabled(true)
	self:registerScriptTouchHandler(function(eventType, x, y)
		return self:onEventTouchCallback(eventType, x, y)
	end)


	--比牌层
	self.m_CompareView = CompareView:create()
		:setVisible(false)
		:addTo(self, GameViewLayer.ORDER_4)
	--普通结算层
	self.m_GameEndView	= GameEndView:create(self.MytxtConfig)
		:setVisible(false)
		:addTo(self, GameViewLayer.ORDER_5)

	--聊天窗口层
	self.m_GameChat = GameChat:create(scene._gameFrame)
		:setLocalZOrder(10)
        :addTo(self)

    --聊天按钮
    self.m_btnChat = self._csbNode:getChildByName("m_btn_chat")
        :setTag(GameViewLayer.BT_CHAT)
        :addTouchEventListener(btcallback)
	-- 语音按钮 gameviewlayer -> gamelayer -> clientscene
--	local btnVoice = ccui.Button:create("btn_voice_zjh_0.png","btn_voice_zjh_1.png","btn_voice_zjh_0.png",ccui.TextureResType.plistType)
--		:move(380, 180)
--		:addTo(self)
--	btnVoice:addTouchEventListener(function(ref, eventType)
-- 		if eventType == ccui.TouchEventType.began then
-- 			self:getParentNode():getParentNode():startVoiceRecord()
--        elseif eventType == ccui.TouchEventType.ended 
--        	or eventType == ccui.TouchEventType.canceled then
--        	self:getParentNode():getParentNode():stopVoiceRecord()
--        end
--	end)
--    if not GlobalUserItem.bPrivateRoom then
--        btnVoice:setVisible(false)
--    end

    -- 语音动画
    local param = AnimationMgr.getAnimationParam()
    param.m_fDelay = 0.1
    param.m_strName = cmd.VOICE_ANIMATION_KEY
    local animate = AnimationMgr.getAnimate(param)
    self.m_actVoiceAni = cc.RepeatForever:create(animate)
    self.m_actVoiceAni:retain()
    
    


    self:OnResetView()
end

--更新时钟
function GameViewLayer:OnUpdataClockView(viewId,time)
    if not viewId or viewId == yl.INVALID_CHAIR or not time then
		self.spriteClock:getChildByTag(GameViewLayer.TIMENUM):setString("")
		self.spriteClock:setVisible(false)
        if viewId ~= cmd.MY_VIEWID then 
            self:setWaitPlayer(true)
        end
	else
		self.spriteClock:getChildByTag(GameViewLayer.TIMENUM):setString(time)
        if self.IsShowWait == true then           
            self:setWaitPlayer(false)
        end
	end
end
function GameViewLayer:setClockPosition(viewId)
    if viewId then
		self.spriteClock:setPosition(pointClock[viewId])
	else
		self.spriteClock:setPosition(display.cx, display.cy)
	end
    self.spriteClock:setVisible(true)
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
--更新用户显示
function GameViewLayer:OnUpdateUser(viewId,userItem)
	if not viewId or viewId == yl.INVALID_CHAIR then
		print("OnUpdateUser viewId is nil")
		return
	end
	self.nodePlayer[viewId]:setVisible(userItem ~= nil)
    local head = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.FACE)
	if not userItem then
        self.nodePlayer[viewId]:setVisible(false)
        self.nodePlayer[viewId]:getChildByTag(GameViewLayer.READY):setVisible(false)
        if head then
			head:setVisible(false)
		end
	else
		self.nodePlayer[viewId]:setVisible(true)
        self:setNickname(viewId, userItem.szNickName)
		self:setScore(viewId, userItem.lScore)
        self.nodePlayer[viewId]:getChildByTag(GameViewLayer.READY):setVisible(yl.US_READY == userItem.cbUserStatus)
        if not head then
            local csbHead = self.nodePlayer[viewId]:getChildByName("m_pIconHead")     -- 头像处理
            local csbHeadX, csbHeadY = csbHead:getPosition()
            head = PopupInfoHead:createNormal(userItem, 90)
            local headBg = display.newSprite("#userinfo_head_frame.png")
            headBg:setPosition(cc.p(csbHeadX, csbHeadY))
            headBg:setScale(0.55,0.55)
	        head:setPosition(cc.p(csbHeadX, csbHeadY))
			head:enableHeadFrame(false)
			--head:enableInfoPop(true, ptUserInfo[viewId], anchorPoint[viewId])
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
                StateFlag = {0,0,0,0,0}
            else
                self.gStateWait:setVisible(false)  
                self.gAntiCheatWait:setVisible(false)
            end  
            self._selfScore = userItem.lScore or 0        
        end
	end
end

function GameViewLayer:setNickname(viewid, strName)
	local name = ExternalFun.GetShortName(strName,12,10)
	local labelNickname = self.nodePlayer[viewid]:getChildByTag(GameViewLayer.NICKNAME)
	labelNickname:setString(name)
end

function GameViewLayer:setScore(viewid, lScore)
	local labelScore = self.nodePlayer[viewid]:getChildByTag(GameViewLayer.SCORE)
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
    return 9
end
--屏幕点击
function GameViewLayer:onEventTouchCallback(eventType, x, y)

	if eventType == "began" then
		--牌型显示判断
		if self.bIntroduce == true then
			return true
		end
        if self.m_bShowMenu == true then
            self:ShowMenu()
        end
        if self.m_bShowExplain == true then
            self:ShowExplain()
        end

        if self.m_ChipBG:isVisible() == true then 
            self.m_ChipBG:setVisible(false)
            self.nodeButtomButton:setVisible(true)
        end

		--比牌选择判断
		if self.bCompareChoose == true then
			for i = 1, cmd.GAME_PLAYER do
                local rect = self.rcCompare[i]
                local realPos = self:convertToNodeSpace(cc.p(rect.x,rect.y)) 
                rect.x = realPos.x
                rect.y = realPos.y
        	    if cc.rectContainsPoint(rect, cc.p(x,y)) == false then
        		    return true
    		    end
			end
		end

		--结算框
		if self.m_GameEndView:isVisible() then
			local rc = self.m_GameEndView:GetMyBoundingBox()
			if rc and not cc.rectContainsPoint(rc, cc.p(x, y)) then
				--self.m_GameEndView:setVisible(false)
				return true
			end
		end

		return false
	elseif eventType == "ended" then
		--取消牌型显示
		if self.bIntroduce == true then
--			local rectIntroduce = self.cardTypeIntroduce:getBoundingBox()
--			if rectIntroduce and not cc.rectContainsPoint(rectIntroduce, cc.p(x, y)) then
--				self:OnShowIntroduce(false)
--			end
		end
        
		--比牌选择
		if self.bCompareChoose == true then
			for i = 1, cmd.GAME_PLAYER do
                local rect = self.rcCompare[i]
                local realPos = self:convertToNodeSpace(cc.p(rect.x,rect.y)) 
                rect.x = realPos.x
                rect.y = realPos.y
				if cc.rectContainsPoint(rect,cc.p(x,y)) then
					self._scene:OnCompareChoose(i)
					break
				end
			end
		end      

	end

	return true
end
function GameViewLayer:ShowEndView(bShow)
    self.m_GameEndView:setVisible(bShow)
    ExternalFun.showLayer(self, self.m_GameEndView)
end
--牌类型介绍的弹出与弹入
function GameViewLayer:OnShowIntroduce(bShow)
	if self.bIntroduce == bShow then
		return
	end

	local point
	if bShow then
		point = cc.p(163, display.cy) 			--移入的位置
	else
		point = cc.p(-163, display.cy)			--移出的位置
	end
	self.bIntroduce = bShow
--	self.cardTypeIntroduce:stopAllActions()
--	if bShow == true then
--		self.cardTypeIntroduce:setVisible(true)
--		self:ShowMenu()
--	end
--	local this = self
--	self.cardTypeIntroduce:runAction(cc.Sequence:create(
--		cc.MoveTo:create(0.3, point), 
--		cc.CallFunc:create(function()
--				this.cardTypeIntroduce:setVisible(this.bIntroduce)
--			end)
--		))

end

--筹码移动
function GameViewLayer:PlayerJetton(wViewChairId, num,notani)
	if not num or num < 1 or not self.m_lCellScore or self.m_lCellScore < 1 then
		return
	end
    local newChipList = {}
    local jettonCount = num/self.m_lCellScore

    if jettonCount > 5 then
        jettonCount = 5
    end

    for i = 1, jettonCount do 
        local chip = display.newSprite("#zhajinhua_icon_gold_normal.png")
        table.insert(newChipList, 1, chip)
        if notani == true then
            
            chip:move( cc.p(400 + math.random(534), 340 + math.random(210)))
--			if wViewChairId < 3 then	
--				chip:move( cc.p(400 + math.random(270), 390 + math.random(160)))
--			elseif wViewChairId > 3 then
--				chip:move(cc.p(667+ math.random(270), 390 + math.random(160)))
--			else
--				chip:move(cc.p(507+ math.random(270), 390 + math.random(160)))
--			end
		else
			chip:move(ptCoin[wViewChairId].x,  ptCoin[wViewChairId].y)
            chip:runAction(cc.MoveTo:create(0.2, cc.p(400+ math.random(534), 390 + math.random(160))))
--			if wViewChairId < 3 then	
--				chip:runAction(cc.MoveTo:create(0.2, cc.p(400+ math.random(270), 390 + math.random(160))))
--			elseif wViewChairId > 3 then
--				chip:runAction(cc.MoveTo:create(0.2, cc.p(667+ math.random(270), 390 + math.random(160))))
--			else
--				chip:runAction(cc.MoveTo:create(0.2, cc.p(507+ math.random(270), 390 + math.random(160))))
--			end
		end
    end
--	local chipscore = num
--	while chipscore > 0 
--	do
--		local strChip
--		local strScore 
--		if chipscore >= self.m_lCellScore * 5 then
--			strChip = "#bigchip_2.png"
--			chipscore = chipscore - self.m_lCellScore * 5
--			strScore = (self.m_lCellScore*5)..""
--		elseif chipscore >= self.m_lCellScore*2 then
--			strChip = "#bigchip_1.png"
--			chipscore = chipscore - self.m_lCellScore * 2
--			strScore = (self.m_lCellScore*2)..""
--		else
--			strChip = "#bigchip_0.png"
--			chipscore = chipscore - self.m_lCellScore 
--			strScore = self.m_lCellScore..""
--		end
--        print("m_lCellScore:"..chipscore)
--		local chip = display.newSprite(strChip)
--			:setScale(0.7)
--        table.insert(newChipList, 1, chip)  --大的筹码中上面

--		cc.Label:createWithTTF(strScore, appdf.FONT_FILE, 18)
--			:move(54, 53)
--			:setColor(cc.c3b(48, 48, 48))
--			:addTo(chip)
--		if notani == true then
--			if wViewChairId < 3 then	
--				chip:move( cc.p(350+ math.random(315), 390 + math.random(190)))
--			elseif wViewChairId > 3 then
--				chip:move(cc.p(667+ math.random(315), 390 + math.random(190)))
--			else
--				chip:move(cc.p(507+ math.random(315), 390 + math.random(190)))
--			end
--		else
--			chip:move(ptCoin[wViewChairId].x,  ptCoin[wViewChairId].y)
--			if wViewChairId < 3 then	
--				chip:runAction(cc.MoveTo:create(0.2, cc.p(350+ math.random(315), 390 + math.random(190))))
--			elseif wViewChairId > 3 then
--				chip:runAction(cc.MoveTo:create(0.2, cc.p(667+ math.random(315), 390 + math.random(190))))
--			else
--				chip:runAction(cc.MoveTo:create(0.2, cc.p(507+ math.random(315), 390 + math.random(190))))
--			end
--		end
--	end
    for _,v in pairs(newChipList) do
		v:addTo(self.nodeChipPool)
    end
	if not notani then
        ExternalFun.playSoundEffect("zhajinhua_add_score.mp3")
	end
end

--停止比牌动画
function GameViewLayer:StopCompareCard()
	self.m_CompareView:setVisible(false)
	self.m_CompareView:StopCompareCard()
end

--比牌
function GameViewLayer:CompareCard(firstuser,seconduser,firstcard,secondcard,bfirstwin,callback)
	self.m_CompareView:setVisible(true)
	self.m_CompareView:CompareCard(firstuser,seconduser,firstcard,secondcard,bfirstwin,callback)
end

--底注显示
function GameViewLayer:SetCellScore(cellscore)
	self.m_lCellScore = cellscore
	if not cellscore then
		self.txt_CellScore:setString("0")
		for i = 1, 3 do
			self.btChip[i]:getChildByTag(GameViewLayer.CHIPNUM):setString("")
		end
	else
		self.txt_CellScore:setString(cellscore)
        self:SetChipScore(cellscore)
	end
end
function GameViewLayer:SetChipScore(cellscore)
    if cellscore ~= nil then
       for i = 1, 3 do          
             if cellscore*self.nChip[i] < self._selfScore then 
                  self.btChip[i]:setEnabled(true)            
             else
                  self.btChip[i]:setEnabled(false)           
             end		 
             self.btChip[i]:getChildByTag(GameViewLayer.CHIPNUM):setString(cellscore*self.nChip[i])  
	   end
    end
end
--封顶分数
function GameViewLayer:SetMaxCellScore(cellscore)
	if not cellscore then
		self.txt_MaxCellScore:setString("")
	else
		self.txt_MaxCellScore:setString(""..cellscore)
	end
end

----庄家显示
--function GameViewLayer:SetBanker(viewid)
--	if not viewid or viewid == yl.INVALID_CHAIR then
--		self.m_BankerFlag:setVisible(false)
--		return
--	end
--	local x
--	local y
--	if viewid < 3 then
--		x = ptPlayer[viewid].x + 54 
--		y = ptPlayer[viewid].y + 86
--	elseif viewid > 3 then
--		x = ptPlayer[viewid].x - 54
--		y = ptPlayer[viewid].y + 86
--	else
--		x = ptPlayer[viewid].x -148
--		y = ptPlayer[viewid].y + 54
--	end

--	self.m_BankerFlag:setPosition(x, y)
--	self.m_BankerFlag:setVisible(true)
--end

--下注总额
function GameViewLayer:SetAllTableScore(score)
	if not score or score == 0 then
		self.m_txtAllScore:setString("")
	else
		self.m_txtAllScore:setString(score)
--		self.m_AllScoreBG:setVisible(true)
        if self.nodeChipPool:getChildrenCount() == 0 then 
            local newChipList = {}

            for i = 1, score/self.m_lCellScore do 
                local chip = display.newSprite("#zhajinhua_icon_gold_normal.png")
                table.insert(newChipList, 1, chip)
			    chip:move(cc.p(400+ math.random(534), 340 + math.random(210)))
            end
            for _,v in pairs(newChipList) do
		        v:addTo(self.nodeChipPool)
            end
        end
	end
	
end

--玩家下注
function GameViewLayer:SetUserTableScore(viewid, score)
	--增加桌上下注金币
	if not score or score == 0 then
        self.m_ScoreView[viewid].frame:setVisible(false)
	else
		self.m_ScoreView[viewid].frame:setVisible(true)
        self.m_ScoreView[viewid].score:setVisible(true)
        local strScore = ""..score
	    if score < 0 then
		    strScore = "/"..(-score)
	    end
		self.m_ScoreView[viewid].score:setString(strScore)
	end
end

--发牌
function GameViewLayer:SendCard(viewid,index,fDelay)
	if not viewid or viewid == yl.INVALID_CHAIR then
		return
	end
	local fInterval = 0.1

	local this = self
	local nodeCard = self.userCard[viewid]
	nodeCard.area:setVisible(true)

	local spriteCard = nodeCard.card[index]
	spriteCard:stopAllActions()
	spriteCard:setScale(1.0)
	spriteCard:setVisible(true)
	spriteCard:setSpriteFrame("zhajinhua_card_back.png")
	spriteCard:move(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2 + 170)
	spriteCard:runAction(
		cc.Sequence:create(
		    cc.DelayTime:create(fDelay),
		    cc.CallFunc:create(function () ExternalFun.playSoundEffect("zhajinhua_send_card.mp3") end),
            cc.Spawn:create(
                cc.ScaleTo:create(0.25,viewid==cmd.MY_VIEWID and 1.0 or 0.9),
                cc.MoveTo:create(0.25, cc.p(ptCard[viewid].x + (viewid==cmd.MY_VIEWID and 60 or 45)*(index- 1),ptCard[viewid].y))
            )
        )
    )
end

function GameViewLayer:SetStateKuang(viewid ,bLook ,stateType)
    local strFile
    local spriteFrame
    if stateType ~= nil then           	      
        if stateType == 0 then 
            strFile = "zhajinhua_bg_gezhu_kuang.png"
        elseif stateType == 1 then 
            strFile = "zhajinhua_bg_jiazhu_kuang.png"
        end  
        self.m_StateK[viewid]:setVisible(true)
    else
        strFile = "zhajinhua_bg_kanpai_kuang.png"       
        if bLook == true then 
            StateFlag[viewid] = 1
        elseif bLook == false then 
            StateFlag[viewid] = 0
        end
        if StateFlag[viewid] == 0 then     
            self.m_StateK[viewid]:setVisible(false)
        else
            self.m_StateK[viewid]:setVisible(true)
        end
    end
    spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(strFile)  
    self.m_StateK[viewid]:setSpriteFrame(spriteFrame)
    if viewid == 3 then
        self.m_StateK[viewid]:setContentSize(cc.size(246, 164))
    else
        self.m_StateK[viewid]:setContentSize(cc.size(208, 148))
    end
end
--看牌状态
function GameViewLayer:SetLookCard(viewid , bLook)
	if viewid == cmd.MY_VIEWID then
		return
	end

	self.m_LookCard[viewid]:setVisible(bLook)    
    self:SetStateKuang(viewid,bLook,nil)
end

--弃牌状态
function GameViewLayer:SetUserGiveUp(viewid ,bGiveup)
	local nodeCard = self.userCard[viewid]
    for i = 1, 3 do
        nodeCard.card[i]:setSpriteFrame("zhajinhua_card_break.png")
        nodeCard.card[i]:setVisible(true)
    end
    self.m_GiveUp[viewid]:setVisible(bGiveup)
    if bGiveup == true then
    	self:SetLookCard(viewid, false)
    end
end

--清理牌
function GameViewLayer:clearCard(viewid)
	local nodeCard = self.userCard[viewid]
	for i = 1, 3 do
		nodeCard.card[i]:setSpriteFrame("zhajinhua_card_break.png")
		nodeCard.card[i]:setVisible(false)
	end
	self.m_GiveUp[viewid]:setVisible(false)
end

--显示牌值
function GameViewLayer:SetUserCard(viewid, cardData)
	if not viewid or viewid == yl.INVALID_CHAIR then
		return
	end
	for i = 1, 3 do
		self.userCard[viewid].card[i]:stopAllActions()
		if viewid ~= cmd.MY_VIEWID then
			self.userCard[viewid].card[i]:setScale(0.9)
		end
		self.userCard[viewid].card[i]:move(ptCard[viewid].x +  (viewid==cmd.MY_VIEWID and 60 or 50)*(i- 1),ptCard[viewid].y)
	end
	--纹理
	if not cardData then
		for i = 1, 3 do
			self.userCard[viewid].card[i]:setSpriteFrame("zhajinhua_card_back.png")
			self.userCard[viewid].card[i]:setVisible(false)
		end
	else
		for i = 1, 3 do
			local spCard = self.userCard[viewid].card[i]
			if not cardData[i] or cardData[i] == 0 or cardData[i] == 0xff  then
				spCard:setSpriteFrame("zhajinhua_card_back.png")
			else
				local strCard = string.format("zhajinhua_card_player_%02d.png",cardData[i])
				spCard:setSpriteFrame(strCard)
			end
			self.userCard[viewid].card[i]:setVisible(true)
		end
	end
end

GameViewLayer.RES_CARD_TYPE = {"zhajinhua_icon_cardtype_0.png","zhajinhua_icon_cardtype_1.png","zhajinhua_icon_cardtype_2.png","zhajinhua_icon_cardtype_3.png","zhajinhua_icon_cardtype_4.png","zhajinhua_icon_cardtype_5.png"}
--显示牌类型
function GameViewLayer:SetUserCardType(viewid,cardtype)
	local spriteCardType = self.userCard[viewid].cardType
	if cardtype and cardtype >= 1 and cardtype <= 6 then
		spriteCardType:setSpriteFrame(GameViewLayer.RES_CARD_TYPE[cardtype])
		spriteCardType:setVisible(true)
	else
		spriteCardType:setVisible(false)
	end
end

--赢得筹码
function GameViewLayer:WinTheChip(wWinner)
	--筹码动作
	local children = self.nodeChipPool:getChildren()
	for k, v in pairs(children) do
		v:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*(#children - k)),
			cc.MoveTo:create(0.4, cc.p(ptPlayer[wWinner].x, ptPlayer[wWinner].y )),
			cc.CallFunc:create(function(node)
				node:removeFromParent()
			end)))
	end
end

--清理筹码
function GameViewLayer:CleanAllJettons()
	self.nodeChipPool:removeAllChildren()
end

--取消比牌选择
function GameViewLayer:SetCompareCard(bchoose,status)
	self.bCompareChoose = bchoose
    for i = 1, cmd.GAME_PLAYER do
    	if bchoose and status and status[i] then
    	 	self.m_flagArrow[i]:setVisible(true)
    	 	self.m_flagArrow[i]:runAction(cc.RepeatForever:create(cc.Sequence:create(
    	 		cc.ScaleTo:create(0.3,1.5),
    	 		cc.ScaleTo:create(0.3,1.0)
    	 		)))
    	else
    		self.m_flagArrow[i]:stopAllActions()
    	 	self.m_flagArrow[i]:setVisible(false)
    	end 
        
    end
end
function GameViewLayer:onBtnStart()
    self.btReady:setVisible(false)
    if self._scene._gameFrame.bEnterAntiCheatRoom == true and GlobalUserItem.isForfendGameRule() then 
        self.gAntiCheatWait:setVisible(true)
    end
	self._scene:onStartGame(true)
end
--按键响应
function GameViewLayer:OnButtonClickedEvent(tag,ref)
    if tag == GameViewLayer.BT_EXIT then
        self:OnDownMenuSwitchAnimate()
	    self._scene:onQueryExitGame()
    elseif tag == GameViewLayer.BT_READY then
        self:onBtnStart()
    elseif tag == GameViewLayer.BT_GIVEUP then
	    self._scene:onGiveUp()
    elseif tag == GameViewLayer.BT_LOOKCARD then
	    self._scene:onLookCard()
    elseif tag == GameViewLayer.BT_ADDSCORE then
	    self.nodeButtomButton:setVisible(false)
        self:SetChipScore(tonumber(self.txt_CellScore:getString()))
	    self.m_ChipBG:setVisible(true)
        
        self.btChip[1]:setEnabled(self._scene.m_lCurrentTimes + 1 <= 10)
        self.btChip[2]:setEnabled(self._scene.m_lCurrentTimes + 2 <= 10)
        self.btChip[3]:setEnabled(self._scene.m_lCurrentTimes + 5 <= 10)

    elseif tag == GameViewLayer.BT_COMPARE then
	    self._scene:onCompareCard()
    --	elseif tag == GameViewLayer.BT_CARDTYPE then
    --		self:OnShowIntroduce(true)
    elseif tag == GameViewLayer.BT_FOLLOW then
	    self._scene:addScore(0)
    elseif tag == GameViewLayer.BT_CHIP_1 then
	    self._scene:addScore(1)
    elseif tag == GameViewLayer.BT_CHIP_2 then
	    self._scene:addScore(2)
    elseif tag == GameViewLayer.BT_CHIP_3 then
	    self._scene:addScore(5)
    elseif tag == GameViewLayer.BT_CHAT then
        print("聊天按钮被点击")
        local item = self:getChildByTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
        if item ~= nil then
            print("item ~= nil")
            item:resetData()
        else
            print("item new")
            local gameSystemMessage = GameSystemMessage:create()
            gameSystemMessage:setLocalZOrder(100)
            gameSystemMessage:setTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
            self:addChild(gameSystemMessage)
        end
    --		self.m_GameChat:showGameChat(true)
    --		self:ShowMenu()
    elseif tag == GameViewLayer.BT_MENU then
	    self:ShowMenu()
    elseif tag == GameViewLayer.BT_EXPLAIN then
	    self:ShowExplain()
    elseif tag == GameViewLayer.BT_HELP then
	    --self._scene._scene:popHelpLayer2(cmd.KIND_ID, 0)
        self:OnDownMenuSwitchAnimate()
        if nil == self.layerHelp then
            self.layerHelp = HelpLayer:create(self, cmd.KIND_ID, 0)
            self:addChild(self.layerHelp)
            self.layerHelp:setLocalZOrder(GameViewLayer.ORDER_HELP)
        else
            self.layerHelp:onShow()
        end
    elseif tag == GameViewLayer.BT_SET then
	    self:OnDownMenuSwitchAnimate()
        if nil == self.layerSet then
	        local mgr = self._scene._scene:getApp():getVersionMgr()
	        local nVersion = mgr:getResVersion(cmd.KIND_ID) or "0"
	        self.layerSet = SettingLayer:create(nVersion)
            self:addChild(self.layerSet)
            self.layerSet:setLocalZOrder(GameViewLayer.ORDER_SET)	
        else
            self.layerSet:onShow()
        end
    elseif tag == GameViewLayer.BT_CHANGE then
        --防作弊判断
        if self._scene._gameFrame.bEnterAntiCheatRoom == true and GlobalUserItem.isForfendGameRule() then
            showToast(cc.Director:getInstance():getRunningScene(), "游戏进行中无法换桌...", 2)
        elseif self._scene.m_cbGameStatus == cmd.GAME_STATUS_PLAY and self._scene:GetMeUserItem().cbUserStatus == yl.US_PLAYING then
            showToast(cc.Director:getInstance():getRunningScene(), "游戏进行中无法换桌...", 2)
        else
            if self.m_bShowMenu then
		        self:ShowMenu()
	        end
            if self.m_bShowExplain then
		        self:ShowExplain()
	        end

            self._scene:onChangeDesk()
	        self:OnResetView() 								--重置    
        end
    elseif tag == GameViewLayer.BT_BANK then
	    showToast(cc.Director:getInstance():getRunningScene(), "该功能尚未开放，敬请期待...", 1)
    end
end

function GameViewLayer:OnDownMenuSwitchAnimate()
    if self.m_AreaMenu:getScaleX() == 1 then
        self.m_AreaMenu:runAction(cc.ScaleTo:create(0.2, 0))
    elseif self.m_AreaMenu:getScaleX() == 0 then
        self.m_AreaMenu:runAction(cc.ScaleTo:create(0.2, 1))
    end
end

function GameViewLayer:ShowExplain()
    local fSpeed = 0.2
	local fScale = 0

    if self.m_bShowExplain then
        fScale = 0      		
	else
		fScale = 1
        if self.m_bShowMenu then 
             self:ShowMenu()
        end
	end

    --背景图移动
    self.m_bShowExplain = not self.m_bShowExplain
    self.m_AreaExplain:runAction(cc.ScaleTo:create(fSpeed, fScale, fScale, 1))
end
function GameViewLayer:ShowMenu()
    local fSpeed = 0.2
	local fScale = 0

    if self.m_bShowMenu then
		fScale = 0
	else
		fScale = 1
        if self.m_bShowExplain then 
             self:ShowExplain()
        end     
	end

    --背景图移动
    self.m_bShowMenu = not self.m_bShowMenu
    self.m_AreaMenu:runAction(cc.ScaleTo:create(fSpeed, fScale, fScale, 1))   
end

function GameViewLayer:setMenuBtnEnabled(bAble)
	self.m_AreaMenu:getChildByTag(GameViewLayer.BT_SET):setEnabled(bAble)
	self.m_AreaMenu:getChildByTag(GameViewLayer.BT_HELP):setEnabled(bAble)
	self.m_AreaMenu:getChildByTag(GameViewLayer.BT_CHAT):setEnabled(bAble)
	self.m_AreaMenu:getChildByTag(GameViewLayer.BT_EXIT):setEnabled(bAble)
end

function GameViewLayer:runAddTimesAnimate(viewid)
    self:SetStateKuang(viewid,nil,1)
	--display.newSprite("#game_flag_addscore.png")
    display.newSprite("#zhajinhua_icon_jiazhu.png")
		:move(ptStateFlag[viewid])
        :setLocalZOrder(GameViewLayer.ORDER_3)
		--:setScale(viewid == cmd.MY_VIEWID and 1.3 or 1.1)
		:addTo(self)
		:runAction(cc.Sequence:create(
						cc.DelayTime:create(2),
						cc.CallFunc:create(function(ref)
							ref:removeFromParent()
                            self:SetStateKuang(viewid,nil,nil)
						end)
						))
end
function GameViewLayer:runFollowTimesAnimate(viewid)
    self:SetStateKuang(viewid,nil,0)
    display.newSprite("#zhajinhua_icon_genzhu.png")
		:move(ptStateFlag[viewid])
        :setLocalZOrder(GameViewLayer.ORDER_3)
		--:setScale(viewid == cmd.MY_VIEWID and 1.3 or 1.1)
		:addTo(self)
		:runAction(cc.Sequence:create(
						cc.DelayTime:create(2),
						cc.CallFunc:create(function(ref)
							ref:removeFromParent()
                            self:SetStateKuang(viewid,nil,nil)
						end)
						))
end

--显示聊天
function GameViewLayer:ShowUserChat(viewid ,message)
	if message and #message > 0 then
		self.m_GameChat:showGameChat(false) --设置聊天不可见，要显示私有房的邀请按钮（如果是房卡模式）
		--取消上次
		if self.m_UserChat[viewid] then
			self.m_UserChat[viewid]:stopAllActions()
			self.m_UserChat[viewid]:removeFromParent()
			self.m_UserChat[viewid] = nil
		end

		--创建label
		local limWidth = 20*12
		local labCountLength = cc.Label:createWithSystemFont(message,"fonts/round_body.ttf", 20)  
		if labCountLength:getContentSize().width > limWidth then
			self.m_UserChat[viewid] = cc.Label:createWithSystemFont(message,"fonts/round_body.ttf", 20, cc.size(limWidth, 0))
		else
			self.m_UserChat[viewid] = cc.Label:createWithSystemFont(message,"fonts/round_body.ttf", 20)
		end
		self.m_UserChat[viewid]:addTo(self)
		if viewid <= 3 then
			self.m_UserChat[viewid]:move(ptChat[viewid].x + 14 , ptChat[viewid].y + 5)
				:setAnchorPoint( cc.p(0, 0.5) )
		else
			self.m_UserChat[viewid]:move(ptChat[viewid].x - 14 , ptChat[viewid].y + 5)
				:setAnchorPoint(cc.p(1, 0.5))
		end
--		--改变气泡大小
--		self.m_UserChatView[viewid]:setContentSize(self.m_UserChat[viewid]:getContentSize().width+28, self.m_UserChat[viewid]:getContentSize().height + 27)
--			:setVisible(true)
--		--动作
--		self.m_UserChat[viewid]:runAction(cc.Sequence:create(
--						cc.DelayTime:create(3),
--						cc.CallFunc:create(function()
--							self.m_UserChatView[viewid]:setVisible(false)
--							self.m_UserChat[viewid]:removeFromParent()
--							self.m_UserChat[viewid]=nil
--						end)
--				))
	end
end

--显示表情
function GameViewLayer:ShowUserExpression(viewid,index)
	self.m_GameChat:showGameChat(false)
	--取消上次
	if self.m_UserChat[viewid] then
		self.m_UserChat[viewid]:stopAllActions()
		self.m_UserChat[viewid]:removeFromParent()
		self.m_UserChat[viewid] = nil
	end
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame( string.format("e(%d).png", index))
	if frame then
		self.m_UserChat[viewid] = cc.Sprite:createWithSpriteFrame(frame)
			:addTo(self)
		if viewid <= 3 then
			self.m_UserChat[viewid]:move(ptChat[viewid].x + 45 , ptChat[viewid].y + 5)
		else
			self.m_UserChat[viewid]:move(ptChat[viewid].x - 45 , ptChat[viewid].y + 5)
		end
--		self.m_UserChatView[viewid]:setVisible(true)
--			:setContentSize(90,65)
--		self.m_UserChat[viewid]:runAction(cc.Sequence:create(
--						cc.DelayTime:create(3),
--						cc.CallFunc:create(function()
--							self.m_UserChatView[viewid]:setVisible(false)
--							self.m_UserChat[viewid]:removeFromParent()
--							self.m_UserChat[viewid]=nil
--						end)
--				))
	end
end

--显示语音
function GameViewLayer:ShowUserVoice(viewid, isPlay)
--	--取消文字，表情
--	if self.m_UserChat[viewid] then
--		self.m_UserChat[viewid]:stopAllActions()
--		self.m_UserChat[viewid]:removeFromParent()
--		self.m_UserChat[viewid] = nil
--	end
--	self.m_UserChatView[viewid]:stopAllActions()
--	self.m_UserChatView[viewid]:removeAllChildren()
--	self.m_UserChatView[viewid]:setVisible(isPlay)
--	if isPlay == false then

--	else
--		--创建帧动画
--	    -- 聊天表情
--	    local sp = display.newSprite(yl.PNG_PUBLIC_BLANK)
--	    sp:setAnchorPoint(cc.p(0.5, 0.5))
--		sp:runAction(self.m_actVoiceAni)
--		sp:addTo(self.m_UserChatView[viewid])
--		sp:setPosition(cc.p(45, 33))
--		-- 转向
--		if viewid <= 3 then
--			sp:setRotation(180)
--		end
--	end
end

function GameViewLayer:showPopWait( )
	self._scene:showPopWait()
end

function GameViewLayer:dismissPopWait( )
	self._scene:dismissPopWait()
end

return GameViewLayer