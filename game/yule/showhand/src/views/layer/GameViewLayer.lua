local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)

local module_pre = "game.yule.showhand.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local GameChatLayer = appdf.req(appdf.PUB_GAME_VIEW_SRC.."GameChatLayer")
local cmd = import("...models.CMD_Game")
local SettingLayer = import(".SettingLayer")
local PopWaitLayer = import(".PopWaitLayer")
local CardSprite = import(".CardSprite")
local PopupInfoHead = appdf.req("client.src.external.PopupInfoHead")
local AnimationMgr = appdf.req(appdf.EXTERNAL_SRC .. "AnimationMgr")
local HelpLayer = appdf.req(module_pre .. ".views.layer.HelpLayer")
local GameSystemMessage = require(appdf.EXTERNAL_SRC .. "GameSystemMessage")
GameViewLayer.TAG_GAMESYSTEMMESSAGE = 6751

GameViewLayer.BT_START 				= 1
GameViewLayer.BT_MENU 				= 2
GameViewLayer.BT_EXIT				= 3
GameViewLayer.BT_CHANGETABLE		= 4		--换桌

GameViewLayer.BT_FOLLOWGOLD			= 5
GameViewLayer.BT_ADDGOLD			= 6
GameViewLayer.BT_DONOTADDGOLD		= 7
GameViewLayer.BT_SUOHA				= 8
GameViewLayer.BT_GIVEUP 			= 9
GameViewLayer.BT_CHIP_1				= 10
GameViewLayer.BT_CHIP_2				= 11
GameViewLayer.BT_CHIP_3				= 12
GameViewLayer.BT_CHIP_4				= 13
GameViewLayer.BT_SLIDE				= 14
GameViewLayer.BT_CHAT				= 15
GameViewLayer.BT_SET				= 16
GameViewLayer.BT_SOUND				= 17
GameViewLayer.BT_MUSIC				= 18
GameViewLayer.BT_CLOSE				= 19
GameViewLayer.BT_BANK 				= 20
GameViewLayer.BT_HELP               = 21
GameViewLayer.BT_EXPLAIN            = 22
GameViewLayer.BT_ADDSCORE           = 23
GameViewLayer.SLIDER				= 31

GameViewLayer.SP_ALLINHEADBG        = 98
GameViewLayer.SP_ALLIN              = 99
GameViewLayer.SP_ALLINHEAD          = 100

local ptCoin = {cc.p(917, 589), cc.p(444, 260), cc.p(180, 250), cc.p(1024, 250), cc.p(1024, 490)}     --金币
local ptCard = {cc.p(580, 632), cc.p(565, 185), cc.p(210, 310), cc.p(950, 310), cc.p(950, 550)}       -- 牌
local ptChat = {cc.p(1040, 695), cc.p(328, 264), cc.p(175, 395), cc.p(1150, 395), cc.p(1150, 635)}     -- 聊天
local ptScore = {cc.p(870, 510), cc.p(470, 302), cc.p(210, 310), cc.p(950, 310), cc.p(950, 550)}     -- 分数
local ptPlayNode = {cc.p(930,622),cc.p(436,207),cc.p(152,60),cc.p(1254,268),cc.p(1254,504)}
local ptPlayNodeMove = {cc.p(1350,622),cc.p(436,-92),cc.p(152,-120),cc.p(1434,268),cc.p(1434,504)}
local ptPlayAddScoreRun = {cc.p(0,-100),cc.p(246,80)}

function GameViewLayer:onExit()

	--移除缓存	
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("set/showhand_setlayer.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("cards_s.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("game/showhand_tab_font.png")
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
 	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()

 	--播放大厅背景音乐
    ExternalFun.playPlazzBackgroudAudio()
end
--初始化数据
function GameViewLayer:initData()
 	self.m_lCellScore = 0 		--底分
    self.m_lMaxCellScore = 0    --最大下注分
 	self.m_LookCard = false		--是否看牌
 	self.m_lChipCount = 0       --筹码数量
    self.m_lTableScore={}
    self.m_Score = 0
    self.bMenuInOutside = false
    self.bExplainInOutside = false
    self.bShowEndGame = false
    self.m_wait = nil
end

function GameViewLayer:preloadUI()
    	
	cc.SpriteFrameCache:getInstance():addSpriteFrames("set/showhand_setlayer.plist")
	cc.Director:getInstance():getTextureCache():addImage("cards_s.png");    	
    cc.Director:getInstance():getTextureCache():addImage("game/showhand_tab_font.png");

    --播放背景音乐
    ExternalFun.setBackgroundAudio("sound_res/showhand_bgm.mp3")

end

function GameViewLayer:ctor(scene)
	self._scene = scene
    self.m_UserChat = {}
  
  	self:preloadUI()
	self:initData()

    --点击事件
    self:setTouchEnabled(true)
	self:registerScriptTouchHandler(function(eventType, x, y)
		return self:onTouch(eventType, x, y)
	end)

	--节点事件
	ExternalFun.registerNodeEvent(self) -- bind node event

	--按钮回调
	local btnCallback = function(ref, eventType)
        ExternalFun.btnEffect(ref, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:OnButtonClickedEvent(ref:getTag(), ref)
		end
	end

	rootLayer, self._csbNode = ExternalFun.loadRootCSB("game/GameScene.csb", self)
    -- 聊天
    local btnChat = self._csbNode:getChildByName("Button_chat")
    btnChat:setTag(GameViewLayer.BT_CHAT)
	btnChat:addTouchEventListener(btnCallback)
	btnChat:setLocalZOrder(8)
	--开始
	self.btnStart = self._csbNode:getChildByName("Button_start")
	self.btnStart:setTag(GameViewLayer.BT_START)
	self.btnStart:addTouchEventListener(btnCallback)
	self.btnStart:setLocalZOrder(8)

	--弃牌按钮
	self.btnGiveUp = self._csbNode:getChildByName("Button_giveup")
	self.btnGiveUp:setTag(GameViewLayer.BT_GIVEUP)
	self.btnGiveUp:setVisible(false)
	self.btnGiveUp:addTouchEventListener(btnCallback)

	--梭哈按钮
	self.btnShowHand = self._csbNode:getChildByName("Button_showhand")
	self.btnShowHand:setTag(GameViewLayer.BT_SUOHA)
	self.btnShowHand:setVisible(false)
	self.btnShowHand:addTouchEventListener(btnCallback)

	--不加按钮
	self.btnNoAdd = self._csbNode:getChildByName("Button_rangpai")
	self.btnNoAdd:setTag(GameViewLayer.BT_DONOTADDGOLD)
	self.btnNoAdd:setVisible(false)
	self.btnNoAdd:addTouchEventListener(btnCallback)

    --加注按钮
	self.btnAdd = self._csbNode:getChildByName("Button_addchip")
    self.btnAddImg = self.btnAdd:getChildByName("score_all")
	self.btnAdd:setTag(GameViewLayer.BT_ADDGOLD)
	self.btnAdd:setVisible(false)
	self.btnAdd:addTouchEventListener(btnCallback)

    --滑块加注
    self.btnAddScore = self._csbNode:getChildByName("Button_addScore")
	self.btnAddScore:setTag(GameViewLayer.BT_ADDSCORE)
	self.btnAddScore:setVisible(false)
	self.btnAddScore:addTouchEventListener(btnCallback)

	--跟注按钮
	self.btnFollow = self._csbNode:getChildByName("Button_follow")
	self.btnFollow:setTag(GameViewLayer.BT_FOLLOWGOLD)
	self.btnFollow:setVisible(false)
	self.btnFollow:addTouchEventListener(btnCallback)

	--游戏状态下显示总的筹码
	self.m_AllScoreBG = self._csbNode:getChildByName("allChipBg")
	self.m_AllScoreBG:setVisible(false)
	self.m_AllScoreBG:setLocalZOrder(5)
	self.m_txtAllScore = self.m_AllScoreBG:getChildByName("chip_num")
    self.m_txtAllScore:setFontName(appdf.FONT_FILE)
    --每局底注
	self.m_EveryBottomScore = self._csbNode:getChildByName("text_bottomChip")
    self.m_EveryBottomScore:setString("")
    self.m_EveryBottomScore:setFontName(appdf.FONT_FILE)

    --说明按钮
    self.btnExplain = self._csbNode:getChildByName("Button_explain")
	self.btnExplain:setTag(GameViewLayer.BT_EXPLAIN)
	self.btnExplain:addTouchEventListener(btnCallback)

    --说明框图
    self.spExplainBg = self._csbNode:getChildByName("explainBg")
	    :setScale(0)
        :setLocalZOrder(9)

    --长条提示框
    local strNode = self._csbNode:getChildByName("iconLongTitle")    
    strNode:setVisible(false)

    --菜单按钮
	self.btnMenu = self._csbNode:getChildByName("Button_down")
	self.btnMenu:setTag(GameViewLayer.BT_MENU)
	self.btnMenu:addTouchEventListener(btnCallback)

	--菜单背景 
    self.m_AreaMenu = self._csbNode:getChildByName("menu")
	    :setScale(0)
        :setLocalZOrder(5)

    --返回按钮
	self.btnLeave = self.m_AreaMenu:getChildByName("Button_leave")
	self.btnLeave:setTag(GameViewLayer.BT_EXIT)
	self.btnLeave:addTouchEventListener(btnCallback)

    --换桌按钮
	self.btnChangetable = self.m_AreaMenu:getChildByName("Button_changetable")
	self.btnChangetable:setTag(GameViewLayer.BT_CHANGETABLE)
	self.btnChangetable:addTouchEventListener(btnCallback)

    --帮助按钮
	self.btnHelp = self.m_AreaMenu:getChildByName("Button_help")
	self.btnHelp:setTag(GameViewLayer.BT_HELP)
	self.btnHelp:addTouchEventListener(btnCallback)

    --设置按钮
	self.btnSetting = self.m_AreaMenu:getChildByName("Button_set")
	self.btnSetting:setTag(GameViewLayer.BT_SET)
	self.btnSetting:addTouchEventListener(btnCallback)

	--筹码缓存
	self.nodeChipPool = cc.Node:create():addTo(self._csbNode)

	--玩家
	self.nodePlayer = {}
	self.readySp = {} 				--准备的精灵
	self.m_UserHead = {}
	self.m_bOpenUserInfo = true  	--能都点击显示用户详情
	self.m_AddChipNode = {}
   -- self.m_AllInBg = {}
	--时钟
    self.m_clock = {}

	 for i = 1, cmd.GAME_PLAYER do
	 		--玩家总节点
	 	local strNode = string.format("FileNode_%d",i)
	 	self.nodePlayer[i] = self._csbNode:getChildByName(strNode)
	 	self.nodePlayer[i]:setVisible(false)
	 	self.nodePlayer[i]:setLocalZOrder(3)
        self.nodePlayer[i]:setPosition(ptPlayNodeMove[i])

	 	--准备
	 	local strNode = string.format("IconReady_%d",i)        
	 	self.readySp[i] = self._csbNode:getChildByName(strNode)
	 	self.readySp[i]:setVisible(false)
		self.readySp[i]:setLocalZOrder(3)

	 	--玩家背景
	 	self.m_UserHead[i] = {}
	 	--玩家背景
	 	self.m_UserHead[i].bg = self.nodePlayer[i]:getChildByName("m_headBg")   
	 	--昵称
	 	self.m_UserHead[i].name = self.nodePlayer[i]:getChildByName("m_txtName")
	 	self.m_UserHead[i].name:setLocalZOrder(2)
	 	--金币
	 	self.m_UserHead[i].score = self.nodePlayer[i]:getChildByName("m_txtScore")
	 	self.m_UserHead[i].score:setLocalZOrder(2)     
                
        self.m_UserHead[i].name:setFontName(appdf.FONT_FILE)
        self.m_UserHead[i].score:setFontName(appdf.FONT_FILE)
	end
    	
	--手牌显示
	self.userCard = {} --card area
	--下注显示
	self.m_ScoreView = {}
	--准备显示
	self.m_flagReady = {}
	--弃牌标示
	self.m_GiveUp = {}
    --加注
    self.m_addScoreSp ={}

	for i=1,cmd.GAME_PLAYER do
		self.userCard[i] = {}
		self.userCard[i].card = {0,0,0,0,0}

		--牌区域
		self.userCard[i].area = cc.Node:create()
			:setVisible(false)
			:addTo(self._csbNode)
		self.userCard[i].area:setLocalZOrder(2)

		self.m_ScoreView[i] = {}
        self.m_addScoreSp[i] = cc.LabelAtlas:create(txtCellScoreStr,"game/game_add_num.png",27,36,string.byte("*"))
            :move(ptPlayAddScoreRun[i].x,ptPlayAddScoreRun[i].y)
            :setAnchorPoint(cc.p(0.5,0.5))
            :addTo(self.nodePlayer[i],200)  
            :setVisible(false)

	end

	--加注出现的4个按钮父节点
	self.btChip = {}
	self.m_addChipNode = self._csbNode:getChildByName("addScoreNode")
	self.m_addChipNode:setVisible(false)
	--BT_OPENADDGOLD 4个子节点的按钮  
	for i=1,4 do
		local strName = string.format("m_addScore%d",i)     
		self.btChip[i] = self.m_addChipNode:getChildByName(strName)
		self.btChip[i]:setTag(GameViewLayer.BT_CHIP_1 + i - 1)
		self.btChip[i]:addTouchEventListener(btnCallback)
		self.btChip[i]:setTitleText("")
        self.btChip[i]:getChildByName("m_textChipNum"):setString("0")
        self.btChip[i]:getChildByName("m_textChipNum"):setFontName("fonts/round_body.ttf")
        self.btChip[i]:getChildByName("m_textChipNum"):setTextColor(cc.c4b(13, 93, 26, 255))
        self.btChip[i]:getChildByName("m_textChipNum"):enableOutline(cc.c4b(178, 255, 88, 255), 2)
	end

	--顶部信息
	self.scoreInfo = self._csbNode:getChildByName("Bottom_bg")

    --等待游戏开始消息
    self.waitInfo = self._csbNode:getChildByName("iconWaitStart")
    self.waitInfo:setVisible(false)

	--牌型显示
	self.m_cardType = cc.Node:create()
	self.m_cardType:setPosition(0,0)
	self.m_cardType:addTo(self._csbNode)
	self.m_cardType:setLocalZOrder(3)

    --牌盒显示
    self.m_cardBox = self._csbNode:getChildByName("cardBoxBg")
    self.m_spriteCard = {}
    self.m_boxCardCount = 0

	--缓存聊天
	self.m_UserChatView = {}    
	--聊天泡泡
	for i = 1 , cmd.GAME_PLAYER do
		self.m_UserChatView[i] = {}
		--node
		self.m_UserChatView[i].node = cc.Node:create()
		self.m_UserChatView[i].node:setPosition(ptChat[i])
		self.m_UserChatView[i].node:addTo(self._csbNode)
		self.m_UserChatView[i].node:setVisible(false)	
		self.m_UserChatView[i].node:setLocalZOrder(3)
	end

	--聊天窗口
    self.m_chatLayer = GameChatLayer:create(self._scene._gameFrame)
    	:setLocalZOrder(9)
    	:addTo(self._csbNode)
    	:setVisible(false)
  
    self.addScoreBg = self._csbNode:getChildByName("bg_addChipBg")
        :setVisible(false)
        :setLocalZOrder(2)     
    self.addChipFire = self._csbNode:getChildByName("bg_addChipFire")
        :setOpacity(0)
        :setVisible(false)
        :setLocalZOrder(5)
    self.addChipJB = self._csbNode:getChildByName("bg_addChipJB")    
        :setVisible(false)
        :setLocalZOrder(6)
    self.m_iconAllin = self._csbNode:getChildByName("icon_Allin")
        :setVisible(false)
        :setLocalZOrder(5)
    self.addScoreJBNode = self._csbNode:getChildByName("addScoreJBNode")
        :setVisible(false)
        :setLocalZOrder(6)        
    self.addChipChat = self._csbNode:getChildByName("addChipChat")
        :setVisible(false)
        :setLocalZOrder(6)        
    self.addChipChatScore = self.addChipChat:getChildByName("score")
        :setString("")
        :setFontName("fonts/round_body.ttf")

    local function onTouchBegan( touch, event )
	    local touchPoint = touch:getLocation()
        self:ShowAddScoreJB(touchPoint.x, touchPoint.y, 1)
        return true
    end

    local function onTouchMoved(touch, event)
	    local pos = touch:getLocation()
        self:ShowAddScoreJB(pos.x, pos.y, 2)
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)   
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function GameViewLayer:ShowAddScoreJB(x, y, index) 
    if self.addScoreBg ~= nil and self.addScoreBg:isVisible() then
        local worldPos = self._csbNode:convertToWorldSpace(cc.p(self.addScoreBg:getPositionX(), self.addScoreBg:getPositionY()))
	    local silderBox = self.addScoreBg:getBoundingBox()
        silderBox.x = worldPos.x - self.addScoreBg:getContentSize().width/2
        silderBox.y = worldPos.y - self.addScoreBg:getContentSize().height/2
	    if  cc.rectContainsPoint(silderBox, cc.p(x, y)) == true then
            if y < 122 or y > 570 then
                return 
            end

            self:HideAddScoreJB()
            local tmp = (y-122) - ((y-122) % 16)
            local chipCount = tmp/16 
            local num = (y-122)%16
            if num >0 then
                chipCount = chipCount +1
            end

            if chipCount >= 28 then
                chipCount = 28
            end

            for i=1,chipCount do
                local strName = string.format("icon_jinbi_%d",i)     
                local chipJb = self.addScoreJBNode:getChildByName(strName)
                chipJb:setVisible(true)                             
            end
                        
            local MyChair = self._scene:GetMeChairID()
            local score = 0
            if self._scene.m_wAddUser == yl.INVALID_CHAIR then
	            score = self._scene.m_lTotalScore[MyChair+1]
            else
	            score = self._scene.m_lTotalScore[self._scene.m_wAddUser+1]
            end 
            local maxCellScore = self.m_lMaxCellScore - score

            if chipCount == 28 then
                self.m_iconAllin:setScale(0.4)
                self.m_iconAllin:setVisible(true)  
                self.m_iconAllin:runAction(cc.Sequence:create(cc.FadeIn:create(0.2),cc.ScaleTo:create(0.25,1.2),cc.CallFunc:create(
                    function()
                        self.m_iconAllin:setScale(1)
                    end
                )))

                self.addChipFire:setOpacity(255)               
                self:SetAddChipChat(maxCellScore,1111,515)
                self.btnAddScore:setVisible(false)
                self.btnShowHand:setVisible(true)
            else
                self.btnAddScore:setVisible(true)
                self.btnShowHand:setVisible(false)
                self.addChipFire:setOpacity((255/28)*chipCount)
                local score = maxCellScore - (maxCellScore % 28)  --金币柱包含28个金币
                score = score/28 * chipCount

                local jbChip0 = self.addScoreJBNode:getChildByName("icon_jinbi_1")
                local jbChipX, jbChipY = jbChip0:getPosition()
                local jbChipNow = self.addScoreJBNode:getChildByName(string.format("icon_jinbi_%d",chipCount))
                local jbChipNowX, jbChipNowY = jbChipNow:getPosition()
                self:SetAddChipChat(score,1111,118+(jbChipNowY-jbChipY))
            end       
        else 
        
            local worldPos1 = self._csbNode:convertToWorldSpace(cc.p(self.btnAddScore:getPositionX(), self.btnAddScore:getPositionY()))
            local btnAddS = self.btnAddScore:getBoundingBox()
            btnAddS.x = worldPos1.x - self.btnAddScore:getContentSize().width/2
            btnAddS.y = worldPos1.y - self.btnAddScore:getContentSize().height/2

            if  cc.rectContainsPoint(btnAddS, cc.p(x, y)) ~= true and index == 1 then 
                 self:showAddSlider(false)
                 self.btnShowHand:setVisible(false)
                 self:showOperateButton(true)   
            end    
        end
    else
        if self.m_addChipNode:isVisible() and index == 1 then
            self.btnShowHand:setVisible(false)
            self.m_addChipNode:setVisible(false)
            self:showOperateButton(true)
        end 
    end
end

--重置游戏界面
function GameViewLayer:OnResetView() 
	self:stopAllActions()
    self.m_LookCard = false
    self:setTouchEnabled(true)
	self:showOperateButton(false)
	for i = 1 ,cmd.GAME_PLAYER do
		self.readySp[i]:setVisible(false)
		self:OnUpdateUser(i,nil)
		self:setCardType(i)
		self:SetUserTableScore(i)
		self:SetUserEndScore(i)
		self:SetUserGiveUp(i,false)
		self:clearCard(i)						--清除牌
	end
	self:SetAllTableScore(0)
	self:SetCellScore(0)

	self:CleanAllJettons()
	self:SetMaxCellScore(0)    
    self.m_lTableScore = {}
end

function GameViewLayer:setHeadClock(viewid,time)
    if self.m_UserHead[viewid] ~= nil and self.nodePlayer[viewid] ~= nil then 
        local csbHeadX, csbHeadY = self.m_UserHead[viewid].bg:getPosition()         
        self.m_clockBg = display.newSprite("#showhand_bg_time.png")    
        self.m_clock = ExternalFun.HeadCountDown(self.m_clockBg,time,"game/showhand_time.plist")
                :setPosition(cc.p(csbHeadX,csbHeadY))
                :addTo(self.nodePlayer[viewid])
    end 
end

function GameViewLayer:stopHeadClock()
    if self.m_clockBg ~= nil and self.m_clock ~= nil then
        self.m_clockBg:removeFromParent()
        self.m_clock:removeFromParent()
    end 
end

function GameViewLayer:UpdataCardBox(spriteCard)
    for i=1,28 do       
        spriteCard[i] = {}          
        spriteCard[i].area= cc.Node:create()
        :setVisible(true)
        :addTo(self.m_cardBox)    
        spriteCard[i].area:setLocalZOrder(2)

        local spCard = CardSprite:createCard(1)
        spCard:setTag(i)
        spCard:addTo(spriteCard[i].area)        
        spCard:stopAllActions()
        spCard:setScale(0.6)
        spCard:setVisible(true)
        spCard:setPosition((i-1)*5+39,49)
        spCard:showCardBack(true)
    end   
    self.m_boxCardCount = 28
end

function GameViewLayer:MoveHead()
   for i = 1 ,cmd.GAME_PLAYER do     
      if self.nodePlayer[i]:isVisible() then 
          --self.nodePlayer[i]:moveTo(ptPlayNodeMove[i])  
          self.nodePlayer[i]:stopAllActions()
          self.nodePlayer[i]:setPosition(ptPlayNodeMove[i])  
         -- self.nodePlayer[i]:setOpacity(0)       
          self.nodePlayer[i]:runAction(cc.MoveTo:create(0.3,ptPlayNode[i]))                    
      end
   end 
end

--更新用户显示
function GameViewLayer:OnUpdateUser(viewid, userItem, isFree)
	if not viewid or viewid == yl.INVALID_CHAIR then
		--print("OnUpdateUser viewid is nil")
		return
	end

	self.nodePlayer[viewid]:setVisible(userItem ~= nil)
	if not userItem then
        if isFree ~= nil and isFree == true then
		    if self.m_UserHead[viewid].head then
			    self.m_UserHead[viewid].head:setVisible(false)    
                self.m_UserHead[viewid].head:removeAllChildren() 
                self.m_UserHead[viewid].head = nil
                self.nodePlayer[viewid]:stopAllActions()
                self.nodePlayer[viewid]:setPosition(ptPlayNodeMove[viewid]) 
		    end
		    self.m_UserHead[viewid].name:setString("")
		    self.m_UserHead[viewid].score:setString("")
		    self.readySp[viewid]:setVisible(false)   
        end   
	else
		self.nodePlayer[viewid]:setVisible(true)
		--昵称                             
		self.m_UserHead[viewid].name:setString(ExternalFun.GetShortName(userItem.szNickName,10,8))
		--金币
		self:setUserScore(viewid, userItem.lScore)
		--准备
		self.readySp[viewid]:setVisible(yl.US_READY == userItem.cbUserStatus)   

		local isReady = yl.US_READY == userItem.cbUserStatus
        if  isReady == true  then
            local tempType = self.m_cardType:getChildByTag(viewid)  --卡牌类型
            if tempType ~= nil then
                self.m_cardType:removeChildByTag(viewid)
                self.m_cardType:removeAllChildren()     
            end
        end
		--头像
		if not self.m_UserHead[viewid].head then          
            local csbHead = self.nodePlayer[viewid]:getChildByName("m_pIconHead")     -- 头像处理
            local csbHeadX, csbHeadY = csbHead:getPosition()
            local headBg = display.newSprite("#userinfo_head_frame.png")
            headBg:setPosition(cc.p(csbHeadX, csbHeadY))
            headBg:setScale(0.55,0.55)
            self.m_UserHead[viewid].head = PopupInfoHead:createNormal(userItem, 90)
            self.m_UserHead[viewid].head:setPosition(cc.p(csbHeadX, csbHeadY))      
            self.m_UserHead[viewid].head:enableHeadFrame(false)
            self.nodePlayer[viewid]:addChild(headBg)
            self.nodePlayer[viewid]:addChild(self.m_UserHead[viewid].head,100)    
            self.nodePlayer[viewid]:runAction(cc.MoveTo:create(0.3,ptPlayNode[viewid]))  
		else
			self.m_UserHead[viewid].head:updateHead(userItem)
		end
		self.m_UserHead[viewid].head:setVisible(true)        
        --掉线头像变灰
        if self.m_UserHead[viewid].head then
		    if userItem.cbUserStatus == yl.US_OFFLINE then		           
		        convertToGraySprite(self.m_UserHead[viewid].head.m_head.m_spRender)		            
		    else	
			    convertToNormalSprite(self.m_UserHead[viewid].head.m_head.m_spRender)
		    end  
        end	            
	end
end

--设置玩家金币
function GameViewLayer:setUserScore(viewId, lScore)
	self.m_UserHead[viewId].score:setString(self:ScoreChange(lScore))
	--限宽
	local limitWidth = 92
	local scoreWidth = self.m_UserHead[viewId].score:getContentSize().width
	if scoreWidth > limitWidth then
		self.m_UserHead[viewId].score:setScaleX(limitWidth/scoreWidth)
	elseif self.m_UserHead[viewId].score:getScaleX() ~= 1 then
		self.m_UserHead[viewId].score:setScaleX(1)
	end
end

--按键响应
function GameViewLayer:OnButtonClickedEvent(tag,ref)
	if tag == GameViewLayer.BT_EXIT then 				--退出 完成
        self:onButtonSwitchAnimate()
		self._scene:onQueryExitGame()
	elseif tag == GameViewLayer.BT_START then 			--开始 完成
        if self.bMenuInOutside then
		    self:onButtonSwitchAnimate()
	    end
        if self.bExplainInOutside then
		   self:onButtonExplainAnimate()
	    end
		self._scene:onStartGame(true)
	elseif tag == GameViewLayer.BT_GIVEUP then 			--弃牌  
		self._scene:onGiveUp()
	elseif tag == GameViewLayer.BT_FOLLOWGOLD then 		--跟牌
		self._scene:onFollowScore(true)
	elseif tag == GameViewLayer.BT_ADDGOLD then 		--加注
		self._scene:onAddScoreButton() --
	elseif tag == GameViewLayer.BT_DONOTADDGOLD then 	--不加	
		self._scene:onDoNotAddScore()
		self.btnNoAdd:setVisible(false)
	elseif tag == GameViewLayer.BT_SUOHA then 			--梭哈
		self._scene:onShowHand()
	elseif tag == GameViewLayer.BT_CHIP_1 then 
		self._scene:onAddScore(1)
	elseif tag == GameViewLayer.BT_CHIP_2 then
		self._scene:onAddScore(2)
	elseif tag == GameViewLayer.BT_CHIP_3 then
		self._scene:onAddScore(3)
	elseif tag == GameViewLayer.BT_CHIP_4 then
		self._scene:onAddScore(4)
	elseif tag == GameViewLayer.BT_ADDSCORE then
		self._scene:onSlideAddScore()        
	elseif tag == GameViewLayer.BT_SLIDE then
		self._scene:onSlideAddScore()
	elseif tag == GameViewLayer.BT_CHAT then 			--聊天 
        --print("聊天按钮被点击")
        local item = self:getChildByTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
        if item ~= nil then
            --print("item ~= nil")
            item:resetData()
        else
            --print("item new")
            local gameSystemMessage = GameSystemMessage:create()
            gameSystemMessage:setLocalZOrder(100)
            gameSystemMessage:setTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
            self:addChild(gameSystemMessage)
        end
	elseif tag == GameViewLayer.BT_MENU then 			--菜单 完成
        self:onButtonSwitchAnimate()
	elseif tag == GameViewLayer.BT_SET then 			--设置 
        if nil == self.layerSet then 
	        local mgr = self._scene._scene:getApp():getVersionMgr()
	        local nVersion = mgr:getResVersion(cmd.KIND_ID) or "0"
		    self.layerSet = SettingLayer:create(nVersion)
            self.layerSet:addTo(self)
            self.layerSet:setLocalZOrder(100)
        else
            self.layerSet:onShow()
        end
		self:onButtonSwitchAnimate()
	elseif tag == GameViewLayer.BT_CHANGETABLE then 	--换桌 
        --防作弊判断
        if self._scene._gameFrame.bEnterAntiCheatRoom == true and GlobalUserItem.isForfendGameRule() then
            showToast(cc.Director:getInstance():getRunningScene(), "游戏进行中无法换桌...", 2)
            return
        end

        if self._scene.m_bIsGameBegin == false then
    	    for i = 1 ,cmd.GAME_PLAYER do	
		        self:OnUpdateUser(i,nil,true)		
	        end
        end
        self:changeDesk()       
    elseif tag == GameViewLayer.BT_EXPLAIN then
        self:onButtonExplainAnimate()
	elseif tag == GameViewLayer.BT_BANK then 			--银行
		showToast(cc.Director:getInstance():getRunningScene(), "该功能尚未开放，敬请期待...", 1)
    elseif tag == GameViewLayer.BT_HELP then
        self:onButtonSwitchAnimate()
        if nil == self.layerHelp then
            self.layerHelp = HelpLayer:create(self, cmd.KIND_ID, 0)
            self.layerHelp:addTo(self)
            self.layerHelp:setLocalZOrder(100)
        else
            self.layerHelp:onShow()
        end
    else
        showToast(cc.Director:getInstance():getRunningScene(), "该功能尚未开放，敬请期待...", 1)
	end
end

function GameViewLayer:onButtonExplainAnimate()
	local fSpeed = 0.2
	local fScale = 0

    if self.bExplainInOutside then
		fScale = 0
	else
		fScale = 1
        if self.bMenuInOutside then 
             self:onButtonSwitchAnimate()
        end
	end

    --背景图移动
    self.bExplainInOutside = not self.bExplainInOutside
    self.spExplainBg:runAction(cc.ScaleTo:create(fSpeed, fScale, fScale, 1))
end

function GameViewLayer:onButtonSwitchAnimate()
	local fSpeed = 0.2
	local fScale = 0

	if self.bMenuInOutside then
		fScale = 0
	else
		fScale = 1
        if self.bExplainInOutside then 
            self:onButtonExplainAnimate()
        end
	end   
	--背景图移动
    self.bMenuInOutside = not self.bMenuInOutside   
    self.m_AreaMenu:runAction(cc.ScaleTo:create(fSpeed, fScale, fScale, 1))
end

--滑块回调方法
function GameViewLayer:SlideEvent(event)
	if event.name == "ON_PERCENTAGE_CHANGED" then
		local percent = event.target:getPercent()
		self.m_slideProBar:setPercent(percent)
		--判断相应的分数
		if self._scene.m_lTurnLessScore and self._scene.m_lTurnMaxScore then

			local MyChair = self._scene:GetMeChairID()
			local myTotal = 0
			if self._scene.m_wAddUser == yl.INVALID_CHAIR then
				myTotal = self._scene.m_lTotalScore[MyChair+1]
			else
				myTotal = self._scene.m_lTotalScore[self._scene.m_wAddUser+1]
			end
		
			local minScore = self._scene.m_lTurnLessScore - myTotal
			if self._scene.m_llLastScore == 0 then
				minScore = self.m_lCellScore
			end
			local maxScore = self._scene.m_lTurnMaxScore - myTotal 
			local goldNum = math.ceil(minScore + ((maxScore - minScore)/100*percent))
			local goldStr = tostring(goldNum)
			self.m_slideBtn:setTitleText(goldStr)
		end
	end
end

--控制按钮显示
function GameViewLayer:showOperateButton(isShow)
	if isShow == true then       
        if  self.m_lTableScore[cmd.MY_VIEWID] >= self.m_lMaxCellScore then           
            self.btnShowHand:setVisible(isShow)
            self.btnGiveUp:setVisible(isShow)            
            return
        end         
	   	if self._scene.m_llLastScore ~= 0 then --跟注按钮
	        self.btnFollow:setVisible(true)
	        self.btnNoAdd:setVisible(false)
	    elseif self._scene.m_llLastScore == 0 then --不加按钮
	        self.btnFollow:setVisible(false)
	        self.btnNoAdd:setVisible(true)
	    end
	else
 		self.btnFollow:setVisible(false)
        self.btnNoAdd:setVisible(false)
        self.btnShowHand:setVisible(false)
	end

	--弃牌按钮
	self.btnGiveUp:setVisible(isShow)
    --self.btnShowHand:setVisible(isShow)
    --self.m_addChipNode:setVisible(isShow) 
    self.btnAdd:setVisible(isShow) 
end

--屏幕点击
function GameViewLayer:onTouch(eventType, x, y)      
	if eventType == "began" then
		--点击底牌 
		local  securiteCard = self.userCard[cmd.MY_VIEWID].area:getChildByTag(1)
		if securiteCard ~= nil then
            local worldPos = self.userCard[cmd.MY_VIEWID].area:convertToWorldSpace(cc.p(securiteCard:getPositionX(), securiteCard:getPositionY()))
			local cardBox = securiteCard:getBoundingBox()
            cardBox.x = worldPos.x - securiteCard:getContentSize().width/2
            cardBox.y = worldPos.y - securiteCard:getContentSize().height/2

			if cc.rectContainsPoint(cardBox, cc.p(x, y)) == true then                
				
					--动作
					securiteCard:stopAllActions()
					securiteCard:showCardBack(self.m_LookCard)
					self.m_LookCard = not self.m_LookCard
					--延迟一秒后  显示背面
--					securiteCard:runAction(cc.Sequence:create(
--						cc.DelayTime:create(1),
--						cc.CallFunc:create(function ()
--							securiteCard:showCardBack(self.m_LookCard)
--							self.m_LookCard = not self.m_LookCard
--						end)
--						))
			end
		end
		--按钮滚回
	    if self.bMenuInOutside then
		    self:onButtonSwitchAnimate()
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
       
        --self:ShowAddScoreJB(x, y)
		return false
	elseif eventType == "ended" then
      
    else
        --print(eventType)
	end
end

function GameViewLayer:HideAddScoreJB()
    self.m_iconAllin:setVisible(false)
    for i=1,28 do
        local strName = string.format("icon_jinbi_%d",i)     
        local chipJb = self.addScoreJBNode:getChildByName(strName)
        chipJb:setVisible(false)   
    end
end

function GameViewLayer:ScoreChange(score)
	local strScore 
    local base = 0
    local base1 = 0
    local base2 = 0
    local chip1 = 0
    local chip2 = 0
    local chip3 = 0

	--筹码数值显示
	if score >= 100000000  then			
        base  = 100000000
        base1 = 10000000
        base2 = 1000000
		chip1 = score - (score % base) 
        chip2 = (score % base)-(score % base1)
        chip3 = (score % base1)-(score % base2)
        strScore = math.ceil(chip1/base).."."..math.ceil(chip2/base1)..math.ceil(chip3/base2).."亿"
	elseif score >= 10000  then	
        base  = 10000
        base1 = 1000
        base2 = 100	
	    chip1 = score - (score % base) 
        chip2 = (score % base)-(score % base1)
        chip3 = (score % base1)-(score % base2)
		strScore = math.ceil(chip1/base).."."..math.ceil(chip2/base1)..math.ceil(chip3/base2).."万"
	else		
		base = 1
		chip1 = score - (score % base)
		score = score % base
		strScore = math.ceil(chip1/base)..""
	end
    return strScore    
end

--筹码移动
function GameViewLayer:PlayerJetton(wViewChairId, num,notani)
	if not num or num < 1 or not self.m_lCellScore or self.m_lCellScore < 1 then
		--print("GameViewLayer:PlayerJetton return")
		return
	end
    local newChipList = {}
	local chipscore = num
	while chipscore > 0 do
		self.m_lChipCount = self.m_lChipCount + 1
		local strChip
		local strScore 
		--筹码数值显示
		if chipscore >= 100000000  then
			strChip = "#showhand_icon_jbm.png"
			local base = 100000000
			local chip = chipscore - (chipscore % base)
			chipscore = chipscore % base
			strScore = math.ceil(chip/base).."亿"
		elseif chipscore >= 10000  then
			strChip = "#showhand_icon_jbm.png"
			local base = 10000
			local chip = chipscore - (chipscore % base)
			chipscore = chipscore % base
			strScore = math.ceil(chip/base).."万"
		else
			strChip = "#showhand_icon_jbm.png"
			local base = 1
			local chip = chipscore - (chipscore % base)
			chipscore = chipscore % base
			strScore = math.ceil(chip/base)..""
		end
		--筹码创建
		local chip = display.newSprite(strChip)
			:setScale(0.8)
        table.insert(newChipList, 1, chip)  --大的筹码中上面

		cc.Label:createWithTTF("",appdf.FONT_FILE, 20)
			:move(42, 50)
			:setColor(cc.c3b(0, 0, 0))
			:addTo(chip)
		--是否有动画
		if notani == true then
		    chip:move(cc.p(445+ math.random(451), 320 + math.random(161)))
		else
            chip:move(ptCoin[wViewChairId].x,  ptCoin[wViewChairId].y)
            --print("wViewChairId:"..wViewChairId.."  posx:"..ptCoin[wViewChairId].x.."   posy:"..ptCoin[wViewChairId].y)
            chip:runAction(cc.MoveTo:create(0.2, cc.p(445+ math.random(451), 320 + math.random(161))))
		end
	end
    for _,v in pairs(newChipList) do
		v:addTo(self.nodeChipPool)
    end
end

--底注显示
function GameViewLayer:SetCellScore(cellscore)
	self.m_lCellScore = cellscore
	if not cellscore then
		self.m_txtAllScore:setString("0")
		for i = 1, 4 do
			 self.btChip[i]:getChildByName("m_textChipNum"):setString("")
		end
	else
		self.m_txtAllScore:setString(self:ScoreChange(cellscore))
		for i = 1, 4 do
			local str = string.format("%d",cellscore*i)
	        --self.btChip[i]:getChildByName("m_textChipNum"):setString(self:ScoreChange(cellscore*i))
            self.btChip[i]:getChildByName("m_textChipNum"):setString(str)
		end
        --self.
	end
end

--封顶分数
function GameViewLayer:SetMaxCellScore(cellscore)
    self.m_lMaxCellScore = cellscore
	if not cellscore  then
--		self.txtMaxCellScore:setString("")
	else
--		self.txtMaxCellScore:setString(""..cellscore)
	end
end

--下注总额
function GameViewLayer:SetAllTableScore(score)
	if not score or score == 0 then
		self.m_AllScoreBG:setVisible(false)
	else
		self.m_txtAllScore:setString(self:ScoreChange(score))
		self.m_AllScoreBG:setVisible(true)
	end
end

--玩家结算
function GameViewLayer:SetUserEndScore(viewid, score)
	--增加桌上下注金币
	if not score or score == 0 then
		if self.m_ScoreView[viewid].score2 ~= nil  then
			self.m_ScoreView[viewid].score2:removeFromParent()
			self.m_ScoreView[viewid].score2 = nil
		end
--        if self.m_ScoreView[viewid].gold~=nil then
--            self.m_ScoreView[viewid].gold:removeFromParent()
--			self.m_ScoreView[viewid].gold = nil
--        end
	else
		if self.m_ScoreView[viewid].score2 == nil then
			local endScoreStr = score > 0 and "showhand_num_winB.png" or "showhand_num_loseB.png"   
            local xPos =  ptScore[viewid].x
            local yPos =  ptScore[viewid].y    

            self.m_ScoreView[viewid].score2 = cc.LabelAtlas:create(txtCellScoreStr,cmd.RES_PATH.."game/" .. endScoreStr,45,54,string.byte("/"))
                :move(xPos,yPos-30)
                :setAnchorPoint(cc.p(0.5,0.5))
                :addTo(self._csbNode)
			self.m_ScoreView[viewid].score2:setVisible(true)
            self.m_ScoreView[viewid].score2:setLocalZOrder(4)
            self.m_ScoreView[viewid].score2:setAnchorPoint(cc.p(0,0.5))
            self.m_ScoreView[viewid].gold = display.newSprite("#showhand_icon_jb.png")
            self.m_ScoreView[viewid].gold:setPosition(-30,23)
            self.m_ScoreView[viewid].gold:addTo(self.m_ScoreView[viewid].score2) 
            self.m_ScoreView[viewid].gold:setLocalZOrder(4)        

            if score > 0 then
                self.m_ScoreView[viewid].score2:setString("/" .. math.abs(score))  
                self:runUserEndScore(viewid)       
            else
                self.m_ScoreView[viewid].score2:setString("/" .. math.abs(score))  
            end		        
            
            local nTime = 1.5 
            self.m_ScoreView[viewid].score2:runAction(cc.Sequence:create(
		        cc.Spawn:create(
			        cc.MoveBy:create(nTime, cc.p(0, 30)), 
			        cc.FadeIn:create(nTime))))   
		end
	end
    self.m_lTableScore[viewid] = nil
end

--玩家下注
function GameViewLayer:SetUserTableScore(viewid, score)
	--增加桌上下注金币
	if not score or score == 0 then
		if viewid ~= cmd.MY_VIEWID then
--			self.m_ScoreView[viewid].frame:setVisible(false)
		end
--		self.m_ScoreView[viewid].score:setVisible(false)
	else
		if viewid ~= cmd.MY_VIEWID then
--			self.m_ScoreView[viewid].frame:setVisible(true)
		end
--		self.m_ScoreView[viewid].frame:setVisible(true)
--		self.m_ScoreView[viewid].score:setString(score)
--		self.m_ScoreView[viewid].score:setVisible(true)
	end
    self.m_lTableScore[viewid] = score 
end

function GameViewLayer:clearAddScoreSp()
    for i=1,cmd.GAME_PLAYER do
        self.m_addScoreSp[i]:setVisible(false)
        self.m_addScoreSp[i]:setString("")     
    end
end

--发牌
function GameViewLayer:SendCard(viewid,value,cardIndex,fDelay,bDoNotMove,bPlayEffect)
	if not viewid or viewid == yl.INVALID_CHAIR then
		return
	end

    local startX,startY = 295,590
	local fInterval = 0.1
    local time = 0.3
	local spriteCard = CardSprite:createCard(value)
	spriteCard:setTag(cardIndex)
	spriteCard:addTo(self.userCard[viewid].area)
	self.userCard[viewid].area:setVisible(true)
	spriteCard:stopAllActions()	
	spriteCard:setVisible(true)
	--是否有动画
	if bDoNotMove == false then
		spriteCard:setScale(viewid==cmd.MY_VIEWID and 1.0 or 0.8)
		spriteCard:setPosition(cc.p(
						ptCard[viewid].x + (viewid==cmd.MY_VIEWID and 70 or 50)*(cardIndex-1),ptCard[viewid].y))
	else
        spriteCard:setScale(0.4)
        spriteCard:showCardBack(true)
		spriteCard:move(startX,startY)       
        spriteCard:setRotation(51)

		spriteCard:runAction(
			cc.Sequence:create(
				cc.DelayTime:create(0.5),
				cc.CallFunc:create(
					function ()					
						ExternalFun.playSoundEffect("showhand_send_card.wav")
						self:clearAddScoreSp()
					end
					),             
				cc.Spawn:create(
					cc.ScaleTo:create(time,viewid==cmd.MY_VIEWID and 1.0 or 0.8),
                    cc.RotateTo:create(time,720),
					cc.JumpTo:create(time, cc.p(ptCard[viewid].x + (viewid==cmd.MY_VIEWID and 70 or 50)*(cardIndex-1),ptCard[viewid].y),100,1)    
				), 
                cc.CallFunc:create(
                    function ()	
                        if cardIndex > 1 then 
                            spriteCard:setVisible(false)
                            local sprite = display.newSprite()
                                    :setPosition(cc.p(ptCard[viewid].x +(viewid == cmd.MY_VIEWID and 70 or 50) *(cardIndex - 1), ptCard[viewid].y))
                                    :addTo(self)
                                    :setLocalZOrder(5)
                            local animation = cc.Animation:create()
                            for i = 1, 3 do
                                local frameName = string.format("showhand_icon_sendCard%d.png", i)
                                local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
                                animation:addSpriteFrame(spriteFrame)
                            end  
                            animation:setDelayPerUnit(0.1)          -- 设置两个帧播放时间                   
                            animation:setRestoreOriginalFrame(true)    -- 动画执行后还原初始状态   
                            local action = cc.Animate:create(animation)
                            sprite:runAction(cc.Sequence:create(action, cc.CallFunc:create( function()
                                sprite:removeFromParent()
                                spriteCard:showCardBack(false)
                                spriteCard:setVisible(true)
                            end )
                            )) 
                        end
                    end        
                 )
			)
		)		
	end
        
	if cardIndex == 1 then
		spriteCard:showCardBack(true)
	end
end

--弃牌状态
function GameViewLayer:SetUserGiveUp(viewid ,bGiveup)
	local nodeCard = self.userCard[viewid]
	local cardTable = nodeCard.area:getChildren()
	for k,v in pairs(cardTable) do
		v:showCardBack(true)
        v:setVisible(true)
	end
end

--清理牌
function GameViewLayer:clearCard(viewid)
	local nodeCard = self.userCard[viewid]
	for i = 1, #nodeCard.card do
		nodeCard.area:removeAllChildren()
		nodeCard.card = {0,0,0,0,0}
	end
end

--減少牌盒中的牌數
function GameViewLayer:deleteCardOfBox(cardIndex)
   self.m_spriteCard[cardIndex].area:removeAllChildren()  	
end

--清理牌盒
function GameViewLayer:clearCardBox()
	for i = 1,self.m_boxCardCount do
		self:deleteCardOfBox(i)
	end    
end

--赢得筹码
function GameViewLayer:WinTheChip(wWinner)
	--加注界面消失  
    self.m_addChipNode:setVisible(false)
    
	--筹码动作
	local children = self.nodeChipPool:getChildren()
    --local tempTime = 1.0/#children
        --cc.DelayTime:create(tempTime*(#children - k)),
	for k, v in pairs(children) do
		v:runAction(cc.Sequence:create(
		cc.MoveTo:create(0.8, cc.p(self.nodePlayer[wWinner]:getPositionX(),self.nodePlayer[wWinner]:getPositionY())),
		cc.CallFunc:create(function(node)
			node:removeFromParent()
		end)))
	end	
end

--牌值类型
function GameViewLayer:setCardType(viewid,cardType)
	if cardType and cardType >= 1 and cardType <= 9 then
        local frameName  = string.format("#showhand_icon_cardType_%d.png",cardType)   
		local cardTypeSp = display.newSprite(frameName)
        if viewid == 2 then 
            cardTypeSp:setPosition(ptCard[viewid].x + 125,ptCard[viewid].y)
        else
            cardTypeSp:setPosition(ptCard[viewid].x + 90,ptCard[viewid].y)
        end		
		cardTypeSp:addTo(self.m_cardType)
		cardTypeSp:setTag(viewid)
        cardTypeSp:setLocalZOrder(2)
    elseif cardType == 10 then
        local cardTypeSp = display.newSprite("#showhand_icon_qipai.png")		
        if viewid == 2 then 
            cardTypeSp:setPosition(ptCard[viewid].x + 125,ptCard[viewid].y)
        else
            cardTypeSp:setPosition(ptCard[viewid].x + 90,ptCard[viewid].y)
        end	       
        cardTypeSp:addTo(self.m_cardType)
        cardTypeSp:setTag(viewid)
        cardTypeSp:setLocalZOrder(2)
	else 
	    self.m_cardType:removeAllChildren()       
	end
end

--清理筹码
function GameViewLayer:CleanAllJettons()
	self.nodeChipPool:removeAllChildren()
	self.m_lChipCount = 0
end

--翻牌动画
function GameViewLayer:runOpenCard(sprinteCard) 
    spriteCard:setVisible(false)
    local sprite = display.newSprite()
            :setPosition(cc.p(ptCard[viewid].x + (viewid==cmd.MY_VIEWID and 70 or 50)*(cardIndex-1),ptCard[viewid].y))  
            :addTo(self.userCard[viewid].area)      
    local animation =cc.Animation:create()
    for i=1,3 do  
	    local frameName =string.format("showhand_icon_sendCard%d.png",i)    
	    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)               
	    animation:addSpriteFrame(spriteFrame)                                                             
    end  
    animation:setDelayPerUnit(0.1)          --设置两个帧播放时间                   
    animation:setRestoreOriginalFrame(true)    --动画执行后还原初始状态   
    local action =cc.Animate:create(animation)                                                         
    sprite:runAction(cc.Sequence:create(action,cc.CallFunc:create(function ()        
   	    sprite:removeFromParent()                                      
        spriteCard:showCardBack(false)   
        spriteCard:setVisible(true) 
    end)
    )) 
end

--梭哈动画
function GameViewLayer:runShowHandAnimate(viewid)
    if viewid == nil then 
       return
    end 
    self.bShowEndGame = false
    local allinBg = ccui.ImageView:create("showhand_bg_allin.png",ccui.TextureResType.plistType)
            :setScale9Enabled(true)
            :setCapInsets(cc.rect(56, 20, 15, 15))
            :setAnchorPoint(cc.p(0.5,0.5))
            :setContentSize(yl.WIDTH,yl.HEIGHT)           
            :setVisible(true)
            :setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))
    self._csbNode:addChild(allinBg,100)
    allinBg:runAction(cc.Sequence:create(
    cc.FadeIn:create(0.2), 
    cc.DelayTime:create(0.1),
    cc.FadeOut:create(0.2),
    cc.DelayTime:create(0.1),
    cc.FadeIn:create(0.2),
    cc.DelayTime:create(0.1),
    cc.FadeOut:create(0.2),
    cc.DelayTime:create(0.1),
    cc.FadeIn:create(0.2),
    cc.DelayTime:create(0.1),
    cc.FadeOut:create(0.2),
    cc.CallFunc:create(function ()
       allinBg:removeFromParent()
       self:IsShowGameEnd()   
    end)
    ))

    local csbHeadX, csbHeadY = self.m_UserHead[viewid].bg:getPosition()
    local allinHeadBg =  display.newSprite("#showhand_bg_allin_head.png")
         :setPosition(cc.p(csbHeadX,csbHeadY))
         :setVisible(true)
         :setTag(GameViewLayer.SP_ALLINHEADBG)
    self.nodePlayer[viewid]:addChild(allinHeadBg,GameViewLayer.SP_ALLINHEADBG) 
       
    local allinHead = display.newSprite("#showhand_icon_allinHead.png")
             :setPosition(0,62)
             :setVisible(true)
             :setTag(GameViewLayer.SP_ALLINHEAD)
    self.nodePlayer[viewid]:addChild(allinHead,GameViewLayer.SP_ALLINHEAD) 

	local sprite = display.newSprite()
	sprite:setPosition(4,28)
    sprite:setTag(GameViewLayer.SP_ALLIN)
	self.nodePlayer[viewid]:addChild(sprite,GameViewLayer.SP_ALLIN)   
	local animation =cc.Animation:create()
	for i=1,8 do  
	    local frameName =string.format("showhand_allin%d.png",i)                                            
	    --print("frameName =%s",frameName)  
	    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)               
	    animation:addSpriteFrame(spriteFrame)                                                             
	end  
   	animation:setDelayPerUnit(0.1)          --设置两个帧播放时间                   
   	animation:setRestoreOriginalFrame(true)    --动画执行后还原初始状态    

   	local action =cc.Animate:create(animation)                                                         
   	sprite:runAction(cc.RepeatForever:create(action))
end

function GameViewLayer:removeShowHandRun()
    for i =1,2 do
        self:removeSprite(i,GameViewLayer.SP_ALLINHEADBG)
        self:removeSprite(i,GameViewLayer.SP_ALLIN)
        self:removeSprite(i,GameViewLayer.SP_ALLINHEAD)
    end 
end

function GameViewLayer:IsShowGameEnd()
    if self._scene.m_tEndcmdTable == nil then
       self.bShowEndGame = true   
    else
       self._scene:ShowGameEnd()
    end         
end

function GameViewLayer:runUserEndScore(viewid)
    local csbHeadX, csbHeadY = self.m_UserHead[viewid].bg:getPosition()
    local allinHeadBg =  display.newSprite("#showhand_bg_win_head.png")
         :setPosition(cc.p(csbHeadX,csbHeadY))
         :setVisible(true)
    self.nodePlayer[viewid]:addChild(allinHeadBg,97) 
    allinHeadBg:runAction(cc.Sequence:create(cc.DelayTime:create(1.6), cc.Hide:create()))

	local sprite = display.newSprite()
	sprite:setPosition(0,5)
	self.nodePlayer[viewid]:addChild(sprite,99)   
	local animation =cc.Animation:create()
	for i=1,8 do  
	    local frameName =string.format("showhand_bg_win_head_%d.png",i)                                            
	    --print("frameName =%s",frameName)  
	    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)               
	    animation:addSpriteFrame(spriteFrame)                                                             
	end  
   	animation:setDelayPerUnit(0.2)          --设置两个帧播放时间                   
   	animation:setRestoreOriginalFrame(true)    --动画执行后还原初始状态    

   	local action =cc.Animate:create(animation)                                                         
   	sprite:runAction(cc.Sequence:create(action,cc.CallFunc:create(function ()        
   		sprite:removeFromParent()          
   	end)
   	)) 
end

function GameViewLayer:runUserAddScore(viewid,score) 
    --print("runUserAddScore viewid = %d",viewid)
    self.m_addScoreSp[viewid]:setVisible(true)
    self.m_addScoreSp[viewid]:setString("." .. math.abs(score))   
                 
    local sprite = display.newSprite()
	sprite:setPosition(ptPlayAddScoreRun[viewid])  
	self.nodePlayer[viewid]:addChild(sprite,199)   
	local animation =cc.Animation:create()
	for i=1,5 do  
	    local frameName =string.format("showhand_bg_chip_%d.png",i)                                            
	    --print("frameName =%s",frameName)  
	    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)               
	    animation:addSpriteFrame(spriteFrame)                                                             
	end  
   	animation:setDelayPerUnit(0.1)          --设置两个帧播放时间                   
   	animation:setRestoreOriginalFrame(true)    --动画执行后还原初始状态    

   	local action =cc.Animate:create(animation)                                                         
   	sprite:runAction(cc.Sequence:create(action,cc.CallFunc:create(function ()        
   		sprite:removeFromParent()          
   	end)
    ))  
end

function GameViewLayer:removeSprite(viewid,tagNum) 
    local sprite  
    if self.nodePlayer[viewid] ~= nil then 
        sprite = self.nodePlayer[viewid]:getChildByTag(tagNum)
        if sprite ~= nil then 
            sprite:removeFromParent()
        end
    end
    
end

--点击按钮出现的操作提示
function GameViewLayer:showTip(viewid,index)
    self.m_UserChatView[viewid].node:setVisible(true)
	--self.m_UserChatView[viewid].bg:setVisible(false)
	--取消上次
	if self.m_UserChat[viewid] then
		self.m_UserChat[viewid]:stopAllActions()
		self.m_UserChat[viewid]:removeFromParent()
		self.m_UserChat[viewid] = nil
	end
	if self.m_UserChatView[viewid].text then
		self.m_UserChatView[viewid].text:stopAllActions()
		self.m_UserChatView[viewid].text:removeFromParent()
		self.m_UserChatView[viewid].text = nil
	end
	local m_strCardFile = "game/showhand_tab_font.png"	
	local tex = cc.Director:getInstance():getTextureCache():getTextureForKey(m_strCardFile);
	local rect = cc.rect((index-1)*88,0,88,47)
	--创建精灵
	self.m_UserChatView[viewid].text = cc.Sprite:create()
	self.m_UserChatView[viewid].text:initWithTexture(tex,tex:getContentSize())
	self.m_UserChatView[viewid].text:setPosition(0,5)
	self.m_UserChatView[viewid].text:addTo(self.m_UserChatView[viewid].node)
	self.m_UserChatView[viewid].text:setTextureRect(rect);
	--精灵动作
	self.m_UserChatView[viewid].node:runAction(cc.Sequence:create(
		cc.DelayTime:create(1),
		cc.CallFunc:create(function ()
			if self.m_UserChatView[viewid].text ~= nil then
				self.m_UserChatView[viewid].node:setVisible(false)
				self.m_UserChatView[viewid].text:removeFromParent()
				self.m_UserChatView[viewid].text = nil
			end
		end)
		))
end

--显示聊天
function GameViewLayer:ShowUserChat(viewid ,message)
	if message and #message > 0 then
		self.m_chatLayer:showGameChat(false)
		--取消上次
		if self.m_UserChat[viewid] then
			self.m_UserChat[viewid]:stopAllActions()
			self.m_UserChat[viewid]:removeFromParent()
			self.m_UserChat[viewid] = nil
		end
		--重置聊天框大小
		--self.m_UserChatView[viewid].bg:setContentSize(72,52)

		--创建label
		local limWidth = 20*12
		local labCountLength = cc.Label:createWithTTF(message,appdf.FONT_FILE, 20)  
		if labCountLength:getContentSize().width > limWidth then
			self.m_UserChat[viewid] = cc.Label:createWithTTF(message,appdf.FONT_FILE, 20, cc.size(limWidth, 0))
		else
			self.m_UserChat[viewid] = cc.Label:createWithTTF(message,appdf.FONT_FILE, 20)
		end
		self.m_UserChat[viewid]:addTo(self._csbNode)
		self.m_UserChat[viewid]:setLocalZOrder(3)

		if viewid <= cmd.MY_VIEWID then
			self.m_UserChat[viewid]:move(ptChat[viewid].x  , ptChat[viewid].y+5)
				:setAnchorPoint( cc.p(0.5, 0.5) )
		else
			self.m_UserChat[viewid]:move(ptChat[viewid].x  , ptChat[viewid].y)
				:setAnchorPoint(cc.p(0.5, 0.5))
		end
		--改变气泡大小
		self.m_UserChatView[viewid].node:setVisible(true)
		self.m_UserChatView[viewid].bg:setContentSize(self.m_UserChat[viewid]:getContentSize().width+28, self.m_UserChat[viewid]:getContentSize().height + 27)
			:setVisible(true)
		self.m_UserChat[viewid]:setTextColor(cc.c3b(255,255,255))
		--动作
		self.m_UserChat[viewid]:runAction(cc.Sequence:create(
						cc.DelayTime:create(2),
						cc.CallFunc:create(function()
							self.m_UserChatView[viewid].node:setVisible(false)
							--self.m_UserChatView[viewid].bg:setVisible(false)
							--self.m_UserChatView[viewid].bg:setContentSize(cc.size(72,52))
							self.m_UserChat[viewid]:removeFromParent()
							self.m_UserChat[viewid]=nil
						end)
				))
	end
end

--显示表情
function GameViewLayer:ShowUserExpression(viewid,index)
	self.m_chatLayer:showGameChat(false)
	--取消上次
	if self.m_UserChat[viewid] then
		self.m_UserChat[viewid]:stopAllActions()
		self.m_UserChat[viewid]:removeFromParent()
		self.m_UserChat[viewid] = nil
	end
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame( string.format("e(%d).png", index))
	if frame then
		self.m_UserChat[viewid] = cc.Sprite:createWithSpriteFrame(frame)
			:addTo(self._csbNode)
		self.m_UserChat[viewid]:setLocalZOrder(3)
		if viewid <= cmd.MY_VIEWID then
			self.m_UserChat[viewid]:move(ptChat[viewid].x,ptChat[viewid].y+5)
		else
			self.m_UserChat[viewid]:move(ptChat[viewid].x,ptChat[viewid].y+5)
			--self.m_UserChat[viewid]:move(ptChat[viewid].x - 45 , ptChat[viewid].y + 5)
		end
		self.m_UserChatView[viewid].node:setVisible(true)
		--self.m_UserChatView[viewid].bg:setVisible(true)
			:setContentSize(90,80)
		self.m_UserChat[viewid]:runAction(cc.Sequence:create(
						cc.DelayTime:create(3),
						cc.CallFunc:create(function()
							self.m_UserChatView[viewid].node:setVisible(false)
							--self.m_UserChatView[viewid].bg:setVisible(false)
							self.m_UserChat[viewid]:removeFromParent()
							self.m_UserChat[viewid]=nil
						end)
				))
	end
end

--运行输赢动画
function GameViewLayer:runWinLoseAnimate(score)
	--胜利失败动画
    local WinLose = display.newSprite("#showhand_bg_fail.png")
        :setPosition(yl.DESIGN_WIDTH /2, yl.DESIGN_HEIGHT/2+50)
        :setScale(0)
        :setLocalZOrder(5)
        :addTo(self)
    local WinLoseTitle = display.newSprite("#showhand_icon_lose.png")
        :setPosition(WinLose:getContentSize().width/2,WinLose:getContentSize().height/2+15)
        :setScale(0.3)
        :addTo(WinLose)
--    local WinLoseTab = display.newSprite("#showhand_bg_failbottom.png")
--        :setZOrder(-1)
--        :setPosition(WinLose:getContentSize().width/2,WinLose:getContentSize().height/2-20)
--        :addTo(WinLose)
    local WinLoseGold = display.newSprite("#showhand_icon_jb.png")
         :setPosition(WinLose:getContentSize().width/4-10,WinLose:getContentSize().height/8-50)
         :addTo(WinLose)

    local bgFram
    local lightFrame
    local TitleFrame
    local TabFrame
    local WinLoseText
    if score > 0 then
        bgFram = cc.SpriteFrameCache:getInstance():getSpriteFrame("showhand_bg_victory.png")
        --lightFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("showhand_icon_victory.png")
        TitleFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("showhand_icon_win.png")
        --TabFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("showhand_bg_victorybottom.png")
        WinLoseText = cc.LabelAtlas:_create(".0000000", "game/showhand_num_winB.png", 45, 54, string.byte("/"))
            :setPosition(WinLose:getContentSize().width/4+40,WinLose:getContentSize().height/8-50)
            :setAnchorPoint(cc.p(0, 0.5))
            :addTo(WinLose)
        WinLoseText:setString("/"..score)
    else
        bgFram = cc.SpriteFrameCache:getInstance():getSpriteFrame("showhand_bg_fail.png")
        --lightFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("showhand_icon_fail.png")
        TitleFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("showhand_icon_lose.png")
        --TabFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("showhand_bg_failbottom.png")
        WinLoseText = cc.LabelAtlas:_create("/0000000", "game/showhand_num_loseB.png", 45, 54, string.byte("/"))
            :setPosition(WinLose:getContentSize().width/4+40,WinLose:getContentSize().height/8-50)
            :setAnchorPoint(cc.p(0, 0.5))
            :addTo(WinLose)
        WinLoseText:setString("/"..math.abs(score))
    end
    local length = (WinLoseGold:getContentSize().width + WinLoseText:getContentSize().width)/2
    --WinLoseGold:setPosition(WinLose:getContentSize().width/2 - length ,WinLose:getContentSize().height/2)
    --WinLoseText:setPosition(WinLoseGold:getPositionX() + WinLoseGold:getContentSize().width,WinLose:getContentSize().height/2)
    WinLose:setSpriteFrame(bgFram) 
   -- WinLoseLight:setSpriteFrame(lightFrame) 
    WinLoseTitle:setSpriteFrame(TitleFrame) 
--  WinLoseTab:setSpriteFrame(TabFrame) 
    WinLose:runAction(cc.Sequence:create(
                            cc.ScaleTo:create(0.2, 1, 1, 1),
                            cc.DelayTime:create(2.3),
		                    cc.CallFunc:create(function(ref)
			                    WinLose:setVisible(false)  
		                    end)
                 ))
    if score > 0 then
        local WinLoseLight = display.newSprite("#showhand_icon_victory.png")
            :setLocalZOrder(-2)
            :setPosition(WinLose:getContentSize().width/2,WinLose:getContentSize().height/2)
            :addTo(WinLose)
        WinLoseLight:runAction(cc.RotateBy:create(2.5, 360))
    end
    WinLoseTitle:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.2),
                    cc.ScaleTo:create(0.3, 1, 1, 1),
                    cc.DelayTime:create(2.1),
                    cc.CallFunc:create(function()
			           self.btnStart:setVisible(true) 
		               end)
                    ))
--    WinLoseTab:runAction(cc.Sequence:create(
--                    cc.DelayTime:create(0.5),
--                    cc.MoveBy:create(0.5, cc.p(0,10-WinLose:getContentSize().height/2)),
--                    cc.CallFunc:create(function()
--			           self.btnStart:setVisible(true) 
--		               end)
--                    ))                      
end

function GameViewLayer:setBtnEnabled(btn, isEnabled)
    btn:setEnabled(isEnabled)
end

function GameViewLayer:changeDesk()
    --2017.7.16 坐下状态以上才能换桌，防止分数不够被剔除后点换桌提示网络断开        
    local MeUserItem = self._scene._gameFrame:GetMeUserItem()
    if MeUserItem.cbUserStatus >= yl.US_SIT then
        if self._scene.m_cbGameStatus == cmd.GAME_SCENE_PLAY then
            showToast(cc.Director:getInstance():getRunningScene(), "游戏进行中无法换桌...", 2)
        else
            if self.bMenuInOutside then
		        self:onButtonSwitchAnimate()
	        end
            if self.bExplainInOutside then
		        self:onButtonExplainAnimate()
	        end
		    self._scene:onChangeDesk()
		    self:OnResetView() 								--重置
            self.waitInfo:setVisible(false)
        end
    else
        self._scene:onExitTable()
    end 								
end

function GameViewLayer:ShowMyPopWait(szTips, callfun)
    self.m_wait = PopWaitLayer:create(szTips, callfun)		
    self._csbNode:addChild(self.m_wait)
    self.m_wait:setLocalZOrder(9)
end

function GameViewLayer:CloseMyPopWait()
    if self.m_wait ~= nil then
        self.m_wait:removeFromParent()
		self.m_wait = nil        
    end
end

function GameViewLayer:showPopWait( )
	self._scene:showPopWait()
end

function GameViewLayer:dismissPopWait( )
	self._scene:dismissPopWait()
end

function GameViewLayer:HideAddSlider()
    self.addScoreBg:setVisible(false)  
    self.addChipFire:setVisible(false)
    self.btnAddScore:setVisible(false)    
    self.addScoreJBNode:setVisible(false)
    self.addChipChat:setVisible(false)  
    self.addChipJB:setVisible(false)
    self.addChipJB:stopAllActions()
end

function GameViewLayer:showAddSlider(isShow)    
    self.m_addChipNode:setVisible(isShow)
    self:HideAddScoreJB()
    if self._scene.m_sendCardCount <3  then
         self:HideAddSlider()
	else
         self.addScoreBg:setVisible(isShow)  
         self.addChipFire:setVisible(isShow)
         self.addChipFire:setOpacity(0)
         self.btnAddScore:setVisible(isShow)    
         self.addScoreJBNode:setVisible(isShow)
         self.addChipChat:setVisible(isShow)        
         self.addChipJB:setVisible(isShow)  
         if isShow then
              local actRepeatForever = cc.Sequence:create(cc.FadeOut:create(1), cc.FadeIn:create(1))
              self.addChipJB:runAction(cc.RepeatForever:create(actRepeatForever))
              local chipJb = self.addScoreJBNode:getChildByName("icon_jinbi_1")
                    :setVisible(true)

              local MyChair = self._scene:GetMeChairID()
              local score = 0
              if self._scene.m_wAddUser == yl.INVALID_CHAIR then
	            score = self._scene.m_lTotalScore[MyChair+1]
              else
	            score = self._scene.m_lTotalScore[self._scene.m_wAddUser+1]
              end 
              local maxCellScore = self.m_lMaxCellScore - score             
              local score = maxCellScore - (maxCellScore % 28)  --金币柱包含28个金币
              if score >= 28 then 
                 self:SetAddChipChat(score/28,1111,118) 
              else
                 self:HideAddSlider()
              end
         end
	end
end

function GameViewLayer:SetAddChipChat(score,x,y)
    if not score then
        self.addChipChat:setVisible(false)
        self.addChipChatScore:setString("")
    else
        self.addChipChat:setPosition(cc.p(x,y))
        self.addChipChatScore:setString(score)
    end
end



return GameViewLayer