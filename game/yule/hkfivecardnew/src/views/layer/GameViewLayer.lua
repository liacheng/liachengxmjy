local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)

local module_pre = "game.yule.hkfivecardnew.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local GameChatLayer = appdf.req(appdf.PUB_GAME_VIEW_SRC.."GameChatLayer")
local cmd = import("...models.CMD_Game")
local SettingLayer = import(".SettingLayer")
local PopWaitLayer = import(".PopWaitLayer")
local CardSprite = import(".CardSprite")
local PopupInfoHead = appdf.req(appdf.EXTERNAL_SRC .. "PopupInfoHead")
local AnimationMgr = appdf.req(appdf.EXTERNAL_SRC .. "AnimationMgr")
local HelpLayer = appdf.req(module_pre .. ".views.layer.HelpLayer")
local GameSystemMessage = require(appdf.EXTERNAL_SRC .. "GameSystemMessage")
GameViewLayer.TAG_GAMESYSTEMMESSAGE = 6751

GameViewLayer.RES_PATH 				= "game/yule/hkfivecardnew/res/"

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
GameViewLayer.BT_SELECTADDSCORE     = 23

GameViewLayer.SLIDER				= 31

local ptCoin            = {cc.p(180, 490), cc.p(180, 250), cc.p(637, 137), cc.p(1024, 250), cc.p(1024, 490)}
local ptCard            = {cc.p(214, 504), cc.p(214, 268), cc.p(619, 170), cc.p(960, 268), cc.p(960, 504)}
local ptChat            = {cc.p(175, 635), cc.p(175, 395), cc.p(160, 140), cc.p(1150, 395), cc.p(1150, 635)}
local ptScore           = {cc.p(145, 620), cc.p(145, 380), cc.p(510, 280), cc.p(900, 380), cc.p(900, 620)}     -- 分数
local ptPlayNode        = {cc.p(84,504),   cc.p(84,268),   cc.p(478,170),  cc.p(1250,268), cc.p(1250,504)}
local ptPlayNodeMove    = {cc.p(-250,504), cc.p(-250,268), cc.p(478,-164), cc.p(1584,268), cc.p(1584,504)}
local ptTips            = {cc.p(0, 110),  cc.p(0, 110),  cc.p(0, 110),  cc.p(0, 110), cc.p(0, 110)}
local ptPlayAddScoreRun = {cc.p(210, 110), cc.p(210, 110), cc.p(210, 110), cc.p(-210, 110), cc.p(-210, 110)}

local cardGapPlayer = 50
local cardGapOther = 40

function GameViewLayer:onExit()
	--移除缓存
	cc.Director:getInstance():getTextureCache():removeTextureForKey("cards_s.png")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game/hkfivecardnew_tab_font.png")
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
 	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
 	--播放大厅背景音乐
    ExternalFun.playPlazzBackgroudAudio()
end
--初始化数据
function GameViewLayer:initData()
 	self.m_lCellScore = 0 	--底分
    self.m_lMaxCellScore = 0    --最大下注分
 	self.m_LookCard = false
    self.m_lTableScore={}
    self.m_Score = 0
    self.bShowEndGame = false
end

function GameViewLayer:preloadUI()
	cc.Director:getInstance():getTextureCache():addImage("cards_s.png");
	cc.Director:getInstance():getTextureCache():addImage("game/hkfivecardnew_tab_font.png");

    --播放背景音乐
    ExternalFun.setBackgroundAudio("sound_res/hkfivecardnew_game_bgm.mp3")
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

	rootLayer, self._csbNode = ExternalFun.loadRootCSB("game/GameScene.csb", self);

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
	self.m_addChipNode = self._csbNode:getChildByName("addScoreNode")
    self.m_addChipNode:setLocalZOrder(4)
    
    self.m_pNodeSelect = self.m_addChipNode:getChildByName("m_pNodeSelect")
    self.m_pNodeAddScore = self.m_addChipNode:getChildByName("m_pNodeAddScore")

	self.btnGiveUp = self.m_pNodeSelect:getChildByName("Button_giveup")
	self.btnGiveUp:setTag(GameViewLayer.BT_GIVEUP)
	self.btnGiveUp:setVisible(false)
	self.btnGiveUp:addTouchEventListener(btnCallback)

	--跟注按钮   
	self.btnFollow = self.m_pNodeSelect:getChildByName("Button_follow")
	self.btnFollow:setTag(GameViewLayer.BT_FOLLOWGOLD)
	self.btnFollow:setVisible(false)
	self.btnFollow:addTouchEventListener(btnCallback)

    --让牌按钮
    self.btnNoAdd = self.m_pNodeSelect:getChildByName("Button_rangpai")
	self.btnNoAdd:setTag(GameViewLayer.BT_DONOTADDGOLD)
	self.btnNoAdd:setVisible(false)
	self.btnNoAdd:addTouchEventListener(btnCallback)

    --让牌按钮
    self.btnSelectAdd = self.m_pNodeSelect:getChildByName("Button_selectaddscore")
	self.btnSelectAdd:setTag(GameViewLayer.BT_SELECTADDSCORE)
	self.btnSelectAdd:setVisible(false)
	self.btnSelectAdd:addTouchEventListener(btnCallback)

    --加注变灰
    self.imgSelectAdd = self.btnSelectAdd:getChildByName("str")
    
    --加注出现的3个按钮父节点
	self.btChip = {}
	--BT_OPENADDGOLD 3个子节点的按钮
	for i = 1, 4 do
		local strName = string.format("m_addScore%d",i)     
		self.btChip[i] = self.m_pNodeAddScore:getChildByName(strName)
		self.btChip[i]:setTag(GameViewLayer.BT_CHIP_1 + i - 1)
		self.btChip[i]:addTouchEventListener(btnCallback)
		self.btChip[i]:setTitleText("")
        self.btChip[i]:getChildByName("m_textChipNum"):setFontName("fonts/round_body.ttf")
        self.btChip[i]:getChildByName("m_textChipNum"):setString("0")
        self.btChip[i]:getChildByName("m_textChipNum"):setFontSize(30)
        self.btChip[i]:getChildByName("m_textChipNum"):setTextColor(cc.c3b(13, 93, 26))
        self.btChip[i]:getChildByName("m_textChipNum"):enableOutline(cc.c4b(178, 255, 88, 255), 2)
	end

    self.m_addScoreSp ={}

	--游戏状态下显示总的筹码
	self.m_AllScoreBG = self._csbNode:getChildByName("allChipBg")
	self.m_AllScoreBG:setVisible(false)
	self.m_AllScoreBG:setLocalZOrder(5)
	self.m_txtAllScore = self.m_AllScoreBG:getChildByName("chip_num")
    self.m_txtAllScore:setFontName(appdf.FONT_FILE)
    --每局底注
	self.m_EveryBottomScore = self._csbNode:getChildByName("chip_num")
    self.m_EveryBottomScore:setString("底注:0")
    self.m_EveryBottomScore:setFontName(appdf.FONT_FILE)

    --说明按钮
    self.btnExplain = self._csbNode:getChildByName("Button_explain")
	self.btnExplain:setTag(GameViewLayer.BT_EXPLAIN)
	self.btnExplain:addTouchEventListener(btnCallback)
    
    --说明框图
    self.spExplainBg = self._csbNode:getChildByName("explainBg")
	    :setScale(0)
        :setLocalZOrder(8)
    
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
        :setLocalZOrder(8)

    --返回按钮
	local btnLeave = self.m_AreaMenu:getChildByName("Button_leave")
	btnLeave:setTag(GameViewLayer.BT_EXIT)
	btnLeave:addTouchEventListener(btnCallback)

    --帮助按钮
	local btnHelp = self.m_AreaMenu:getChildByName("Button_help")
	btnHelp:setTag(GameViewLayer.BT_HELP)
	btnHelp:addTouchEventListener(btnCallback)

    --换桌按钮
	self.btnChangetable = self.m_AreaMenu:getChildByName("Button_changetable")
	self.btnChangetable:setTag(GameViewLayer.BT_CHANGETABLE)
	self.btnChangetable:addTouchEventListener(btnCallback)

    --设置按钮
	local btnSetting = self.m_AreaMenu:getChildByName("Button_set")
	btnSetting:setTag(GameViewLayer.BT_SET)
	btnSetting:addTouchEventListener(btnCallback)

	--筹码缓存
	self.nodeChipPool = cc.Node:create():addTo(self._csbNode)

	--玩家
	self.nodePlayer = {}
	self.readySp = {} 				--准备的精灵
	self.playerAllin = {}

	self.m_UserHead = {}
	self.m_bOpenUserInfo = true  	--能都点击显示用户详情
    
	--时钟
    self.m_TimeProgress = {}
    self.m_ScoreView = {}
	 for i = 1, cmd.GAME_PLAYER do
        self.m_ScoreView[i] = {}
	 	--玩家总节点
	 	local strNode = string.format("FileNode_%d",i)
	 	self.nodePlayer[i] = self._csbNode:getChildByName(strNode)
	 	self.nodePlayer[i]:setVisible(false)
	 	self.nodePlayer[i]:setLocalZOrder(3)
        self.nodePlayer[i]:move(ptPlayNodeMove[i])

        self.playerAllin[i] = self.nodePlayer[i]:getChildByName("m_pIconAllIn")
        self.playerAllin[i]:setLocalZOrder(100)
	 	--准备
	 	local strNode = string.format("IconReady_%d",i)        
	 	self.readySp[i] = self._csbNode:getChildByName(strNode)
	 	self.readySp[i]:setVisible(false)
		self.readySp[i]:setLocalZOrder(3)

	 	--玩家背景
	 	self.m_UserHead[i] = {}
	 	--玩家背景
	 	self.m_UserHead[i].bg = self.nodePlayer[i]:getChildByName("m_headBg")
	 	self.m_UserHead[i].bg1 = self.nodePlayer[i]:getChildByName("m_headBg1")
	 	self.m_UserHead[i].bg2 = self.nodePlayer[i]:getChildByName("m_headBg2")
	 	--昵称
	 	self.m_UserHead[i].name = self.nodePlayer[i]:getChildByName("m_txtName")
	 	self.m_UserHead[i].name:setLocalZOrder(2)
        self.m_UserHead[i].name:setFontName(appdf.FONT_FILE)
	 	--金币
	 	self.m_UserHead[i].score = self.nodePlayer[i]:getChildByName("m_txtScore")
	 	self.m_UserHead[i].score:setLocalZOrder(2)
        self.m_UserHead[i].score:setFontName(appdf.FONT_FILE)

        self.m_addScoreSp[i] = cc.LabelAtlas:create(txtCellScoreStr,"game/hkfivecardnew_num_win.png",27, 36, string.byte("*"))
            :move(ptPlayAddScoreRun[i].x,ptPlayAddScoreRun[i].y)
            :setAnchorPoint(cc.p(0.5,0.5))
            :addTo(self.nodePlayer[i],200)  
            :setVisible(false)
	end
	--手牌显示
	self.userCard = {} --card area
	--准备显示
	self.m_flagReady = {}
	--弃牌标示
	self.m_GiveUp = {}

	for i=1,cmd.GAME_PLAYER do
		self.userCard[i] = {}
		self.userCard[i].card = {0,0,0,0,0}

		--牌区域
		self.userCard[i].area = cc.Node:create()
			:setVisible(false)
			:addTo(self._csbNode)
		self.userCard[i].area:setLocalZOrder(2)
        
		self.userCard[i].area1 = cc.Node:create()
			:addTo(self._csbNode)
		self.userCard[i].area1:setLocalZOrder(2)
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

    self.m_pWindowFire = self._csbNode:getChildByName("m_pWindowFire")
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

    
    self.m_pNodeGold = self.m_pNodeAddScore:getChildByName("m_pNodeGold")
    self.m_pIconFire = self.m_pNodeGold:getChildByName("m_pIconFire")
    self.m_pIconAllIn = self.m_pNodeGold:getChildByName("m_pIconAllIn")
    
    self.addChipChat = self.m_pNodeGold:getChildByName("addChipChat")
        :setVisible(false)
        :setLocalZOrder(6)        
    self.addChipChatScore = self.addChipChat:getChildByName("score")
    self.addChipChatScore:setString("")
    self.addChipChatScore:setFontName(appdf.FONT_FILE)
    self.addChipChatScore:enableOutline(cc.c4b(92, 45, 110, 255), 2)
    --全压按钮
	self.btnAddScoreAll = self.m_pNodeGold:getChildByName("m_addScoreAll")
	self.btnAddScoreAll:setTag(GameViewLayer.BT_SUOHA)
	self.btnAddScoreAll:addTouchEventListener(btnCallback)
    
    self.btnAddScoreAll.addScore = self.btnAddScoreAll:getChildByName("str1")
    self.btnAddScoreAll.addAll = self.btnAddScoreAll:getChildByName("str2")

    self.touchPoint = cc.p(-1, -1)
    local function onTouchBegan(touch, event)
	    self.touchPoint = touch:getLocation()
        self:ShowAddScoreJB(self.touchPoint.x, self.touchPoint.y, 1)
        return true
    end

    local function onTouchMoved(touch, event)
	    local pos = touch:getLocation()
        self:ShowAddScoreJB(pos.x, pos.y, 2)
    end

    local function onTouchEnded(touch, event)
	    local pos = touch:getLocation()
        
    end
	local listener = cc.EventListenerTouchOneByOne:create()
    --listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function GameViewLayer:SetAddChipChat(score, y)
    if not score or score == 0 then
        self.addChipChat:setVisible(false)
        self.addChipChatScore:setString("")
    else
        self.addChipChat:setVisible(true)
        self.addChipChat:setPosition(cc.p(1150,y))
        self.addChipChatScore:setString(score)
    end
end

function GameViewLayer:HideAddScoreJB()
    for i = 1, 34 do
        local strName = string.format("gold%d",i)     
        local chipJb = self.m_pNodeGold:getChildByName(strName)
        chipJb:setVisible(i == 1)
    end
    self.m_pIconFire:setOpacity(math.floor(255/34))
    self.addChipChat:setVisible(true)
    local posY = self.m_pNodeGold:getChildByName("gold1"):getPositionY()
    
    local MyChair = self._scene:GetMeChairID()
	local score = 0
	if self._scene.m_wAddUser == yl.INVALID_CHAIR then
		score = self._scene.m_lTotalScore[MyChair+1]
	else
		score = self._scene.m_lTotalScore[self._scene.m_wAddUser+1]
	end
    local maxCellScore = self.m_lMaxCellScore - score

    score = maxCellScore - (maxCellScore % 34)
    score = score/34
    self:SetAddChipChat(score,posY)
end

function GameViewLayer:resetAddScoreJB()
    self.m_pIconAllIn:setVisible(false)
    self:HideAddScoreJB()
end

function GameViewLayer:ShowAddScoreJB(x, y, index) 
    if self.m_pNodeGold ~= nil and self.m_pNodeGold:isVisible() then
        
        local worldPos = self.m_pNodeGold:convertToWorldSpace(cc.p(self.m_pIconFire:getPositionX(), self.m_pIconFire:getPositionY()))
	    local silderBox = self.m_pIconFire:getBoundingBox()
        silderBox.x = worldPos.x - self.m_pIconFire:getContentSize().width/2
        silderBox.y = worldPos.y - self.m_pIconFire:getContentSize().height/2
         
	    if  cc.rectContainsPoint(silderBox, cc.p(x, y)) == true then
            self:HideAddScoreJB()
            local maxCount = 0
            local posY = self.m_pNodeGold:getChildByName("gold1"):getPositionY()
            for i = 1, 34 do
                local strName = string.format("gold%d",i)     
                local chipJb = self.m_pNodeGold:getChildByName(strName)
                if y >= chipJb:getPositionY() then
                    chipJb:setVisible(true)
                    maxCount = i
                    posY = chipJb:getPositionY()
                end
            end

            if maxCount == 0 then
                maxCount = 1
            end
                       
            local MyChair = self._scene:GetMeChairID()
            local score = 0
            if self._scene.m_wAddUser == yl.INVALID_CHAIR then
	            score = self._scene.m_lTotalScore[MyChair+1]
            else
	            score = self._scene.m_lTotalScore[self._scene.m_wAddUser+1]
            end 
            local maxCellScore = self.m_lMaxCellScore - score
            if maxCount == 34 then
                if self.m_pIconAllIn:getNumberOfRunningActions() == 0 and self.m_pIconAllIn:isVisible() == false then
                    self.m_pIconAllIn:setScale(0)
                    self.m_pIconAllIn:setOpacity(255)
                    self.m_pIconAllIn:stopAllActions()
                    self.m_pIconAllIn:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,1.2),cc.ScaleTo:create(0.05, 1)))
                end                  
                self:SetAddChipChat(maxCellScore,posY)
            else
                local score = maxCellScore - (maxCellScore % 34)       
                score = score/34 * maxCount
                self:SetAddChipChat(score, posY)
            end
            self.m_pIconFire:setOpacity(math.floor((255/34)*maxCount))
            self.m_pIconAllIn:setVisible(maxCount == 34)
            self.btnAddScoreAll.addScore:setVisible(maxCount ~= 34)
            self.btnAddScoreAll.addAll:setVisible(maxCount == 34)
        else
            if self.m_pNodeAddScore:isVisible() and index == 1 then
                self:showOperateButton(true)
            end 
        end
    else
        if self.m_pNodeAddScore:isVisible() and index == 1 then
            self:showOperateButton(true)
        end 
    end
end

--重置游戏界面
function GameViewLayer:OnResetView()
    self.m_LookCard = false
	self:stopAllActions()
	self:showOperateButton(false)
	for i = 1 ,cmd.GAME_PLAYER do
		self.readySp[i]:setVisible(false)
		self:OnUpdateUser(i,nil)       
		self:setCardType(i)
		self:SetUserTableScore(i)
		self:SetUserEndScore(i)
		self:SetUserGiveUp(i,false)
		self:clearCard(i)						--清除牌
        self.nodePlayer[i]:setVisible(false)
        self:clearAddScoreSp()
	end
	self:SetAllTableScore(0)
	self:SetCellScore(0)
    self.m_EveryBottomScore:setString("底注:0")
	self:CleanAllJettons()
	self:SetMaxCellScore(0)
    self.m_lTableScore={}
end

function GameViewLayer:setHeadClock(viewid,time)
    if self.m_UserHead[viewid] ~= nil and self.nodePlayer[viewid] ~= nil then 
        local csbHeadX, csbHeadY = self.m_UserHead[viewid].bg:getPosition()         
        local m_clockBg = display.newSprite("#hkfivecardnew_bg_time.png")    
        self.m_clock = ExternalFun.HeadCountDown(m_clockBg, time, "game/hkfivecardnew_bg_time.plist")
                :setPosition(cc.p(csbHeadX,csbHeadY))
                :setLocalZOrder(101)
                :addTo(self.nodePlayer[viewid])
    end 
end

function GameViewLayer:stopHeadClock()
    if self.m_clock ~= nil then
        self.m_clock:removeFromParent()
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

function GameViewLayer:clearAddScoreSp()
    for i=1,cmd.GAME_PLAYER do
        self.m_addScoreSp[i]:setVisible(false)
        self.m_addScoreSp[i]:setString("")     
    end
end

function GameViewLayer:runUserAddScore(viewid,score) 
    self.m_addScoreSp[viewid]:setVisible(true)
    self.m_addScoreSp[viewid]:setString("." .. math.abs(score))

    local sprite = display.newSprite()
	sprite:setPosition(ptPlayAddScoreRun[viewid])  
	self.nodePlayer[viewid]:addChild(sprite,199)   
	local animation =cc.Animation:create()
	for i = 1, 5 do  
	    local frameName =string.format("hkfivecardnew_bg_chip_%d.png",i)
	    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)               
	    animation:addSpriteFrame(spriteFrame)                                                             
	end  
   	animation:setDelayPerUnit(0.1)          --设置两个帧播放时间                   
   	animation:setRestoreOriginalFrame(true)    --动画执行后还原初始状态    

   	local action =cc.Animate:create(animation)                                                         
   	sprite:runAction(cc.Sequence:create(action, cc.RemoveSelf:create()))
end

--设置玩家金币
function GameViewLayer:setUserScore(viewId, lScore)
	local strName = string.format("FileNode_%d", viewId)
	local textScore = self._csbNode:getChildByName(strName):getChildByName("m_txtScore")
	textScore:setString(self:ScoreChange(lScore))
	--限宽
	local limitWidth = 92
	local scoreWidth = textScore:getContentSize().width
	if scoreWidth > limitWidth then
		textScore:setScaleX(limitWidth/scoreWidth)
	elseif textScore:getScaleX() ~= 1 then
		textScore:setScaleX(1)
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
    elseif tag == GameViewLayer.BT_SELECTADDSCORE then
        self:resetAddScoreJB()
        self.m_pNodeAddScore:setVisible(true)
        self.m_pNodeSelect:setVisible(false)
	elseif tag == GameViewLayer.BT_SUOHA then 			--梭哈
		if self.btnAddScoreAll.addScore:isVisible() then
            self._scene:onAddScoreByNum()
		else
            self._scene:onShowHand()
		end
	elseif tag == GameViewLayer.BT_CHIP_1 then 
		self._scene:onAddScore(1)
	elseif tag == GameViewLayer.BT_CHIP_2 then
		self._scene:onAddScore(2)
	elseif tag == GameViewLayer.BT_CHIP_3 then
		self._scene:onAddScore(3)
	elseif tag == GameViewLayer.BT_CHIP_4 then
		self._scene:onAddScore(4)
	elseif tag == GameViewLayer.BT_SLIDE then
		self._scene:onSlideAddScore()
	elseif tag == GameViewLayer.BT_CHAT then 			--聊天 
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
	elseif tag == GameViewLayer.BT_MENU then 			--菜单 完成
        self:onButtonSwitchAnimate()
	elseif tag == GameViewLayer.BT_SET then 			--设置 
        if nil == self.layerSet then
	        local mgr = self._scene._scene:getApp():getVersionMgr()
	        local nVersion = mgr:getResVersion(cmd.KIND_ID) or "0"
		    self.layerSet = SettingLayer:create(nVersion)
            self._csbNode:addChild(self.layerSet)
            self.layerSet:setLocalZOrder(9)
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
    elseif tag == GameViewLayer.BT_HELP then
        if nil == self.layerHelp then
            self.layerHelp = HelpLayer:create(self, cmd.KIND_ID, 0)
            self.layerHelp:addTo(self)
        else
            self.layerHelp:onShow()
        end
        self:onButtonSwitchAnimate()
        --showToast(self,"该功能尚未实现",1)
    elseif tag == GameViewLayer.BT_EXPLAIN then
        self:onButtonExplainAnimate()
	elseif tag == GameViewLayer.BT_BANK then 			--银行
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
		end
	end
end
--控制按钮显示
function GameViewLayer:showOperateButton(isShow)
	--弃牌按钮
	self.btnGiveUp:setVisible(isShow)
    self.btnSelectAdd:setVisible(isShow)
    self.m_pNodeSelect:setVisible(isShow)
    self.m_pNodeAddScore:setVisible(false)
    self.btnAddScoreAll.addAll:setVisible(false)
    self.btnAddScoreAll.addScore:setVisible(true)
    self.btnSelectAdd:setEnabled(isShow)
    self.imgSelectAdd:loadTexture("hkfivecardnew_btntab_jiazhu.png",1)
	if isShow == true then
        if self.m_lTableScore[cmd.MY_VIEWID] >= self.m_lMaxCellScore then           
            self.btnAddScoreAll:setVisible(isShow)
            self.btnSelectAdd:setEnabled(true)
            self.imgSelectAdd:loadTexture("hkfivecardnew_btntab_jiazhu1.png",1)
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
	end
	--梭哈按钮
	if  self._scene.m_sendCardCount <3  then
        self.m_pNodeGold:setVisible(false)
	else
        self.m_pNodeGold:setVisible(true)
	end
end

--屏幕点击
function GameViewLayer:onTouch(eventType, x, y)
	if eventType == "began" then
		--点击底牌
		local  securiteCard = self.userCard[3].area:getChildByTag(1)
		if securiteCard ~= nil then
            local worldPos = self.userCard[3].area:convertToWorldSpace(cc.p(securiteCard:getPositionX(), securiteCard:getPositionY()))
			local cardBox = securiteCard:getBoundingBox()
            cardBox.x = worldPos.x - securiteCard:getContentSize().width/2
            cardBox.y = worldPos.y - securiteCard:getContentSize().height/2



			if  cc.rectContainsPoint(cardBox, cc.p(x, y)) == true then
				--动作
				securiteCard:stopAllActions()
				securiteCard:showCardBack(self.m_LookCard)
				self.m_LookCard = not self.m_LookCard
				--延迟一秒后  显示背面
--				securiteCard:runAction(cc.Sequence:create(
--					cc.DelayTime:create(1),
--					cc.CallFunc:create(function ()
--						securiteCard:showCardBack(self.m_LookCard)
--						self.m_LookCard = not self.m_LookCard
--					end)
--					))
			end
		end
        --按钮滚回
	    if self.bMenuInOutside then
            if  cc.rectContainsPoint(self.m_AreaMenu:getBoundingBox(), cc.p(x, y)) == false then
		        self:onButtonSwitchAnimate()
            end
	    end
        if self.bExplainInOutside then
            if  cc.rectContainsPoint(self.spExplainBg:getBoundingBox(), cc.p(x, y)) == false then
		        self:onButtonExplainAnimate()
            end
	    end
		return false
	elseif eventType == "ended" then

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
		print("GameViewLayer:PlayerJetton return")
		return
	end
    local newChipList = {}
	local chipscore = num
	while chipscore > 0 do
		local strChip
		local strScore 
		if chipscore >= 100000000  then
			strChip = "#hkfivecardnew_icon_jbm.png"
			local base = 100000000
			local chip = chipscore - (chipscore % base)
			chipscore = chipscore % base
			strScore = math.ceil(chip/base).."亿"
		elseif chipscore >= 10000  then
			strChip = "#hkfivecardnew_icon_jbm.png"
			local base = 10000
			local chip = chipscore - (chipscore % base)
			chipscore = chipscore % base
			strScore = math.ceil(chip/base).."万"
		else
			strChip = "#hkfivecardnew_icon_jbm.png"
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
				chip:move(cc.p(540+ math.random(252), 260 + math.random(150)))
    	else
			chip:move(ptCoin[wViewChairId].x,  ptCoin[wViewChairId].y)
            chip:runAction(cc.MoveTo:create(0.2, cc.p(540+ math.random(252), 260 + math.random(150))))
		end
	end
    for _,v in pairs(newChipList) do
		v:addTo(self.nodeChipPool)
    end
end

--底注显示
function GameViewLayer:SetCellScore(cellscore)
    self.m_EveryBottomScore:setString("底注:"..cellscore)
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
	        self.btChip[i]:getChildByName("m_textChipNum"):setString(str)
		end
	end
end

--封顶分数
function GameViewLayer:SetMaxCellScore(cellscore)
    self.m_lMaxCellScore = cellscore
	if not cellscore  then
		--self.txtMaxCellScore:setString("")
	else
		--self.txtMaxCellScore:setString(""..cellscore)
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
			local endScoreStr = score > 0 and "hkfivecardnew_num_2.png" or "hkfivecardnew_num_1.png"   
            local xPos =  ptScore[viewid].x
            local yPos =  ptScore[viewid].y   

            self.m_ScoreView[viewid].score2 = cc.LabelAtlas:create(txtCellScoreStr,cmd.RES_PATH.."game/" .. endScoreStr,45,54,string.byte("/"))
                :move(xPos,yPos-30)
                :setAnchorPoint(cc.p(0.5,0.5))
                :addTo(self._csbNode)
			self.m_ScoreView[viewid].score2:setVisible(true)
            self.m_ScoreView[viewid].score2:setLocalZOrder(4)
            self.m_ScoreView[viewid].score2:setAnchorPoint(cc.p(0,0.5))
            self.m_ScoreView[viewid].gold = display.newSprite("#hkfivecardnew_icon_jb.png")
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

function GameViewLayer:runUserEndScore(viewid)
    self.m_UserHead[viewid].bg2:setVisible(true)
    self.m_UserHead[viewid].bg2:runAction(cc.Sequence:create(cc.DelayTime:create(1.6), cc.Hide:create()))

	local sprite = display.newSprite()
	sprite:setPosition(0,5)
	self.nodePlayer[viewid]:addChild(sprite,99)   
	local animation =cc.Animation:create()
	for i=1,8 do  
	    local frameName =string.format("hkfivecardnew_bg_win_head_%d.png",i)                                            
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

--玩家下注
function GameViewLayer:SetUserTableScore(viewid, score)
	--增加桌上下注金币
    self.m_lTableScore[viewid] = score
end

--发牌
function GameViewLayer:SendCard(viewid,value,cardIndex,fDelay,bDoNotMove,bPlayEffect)
	if not viewid or viewid == yl.INVALID_CHAIR then
		return
	end
	local fInterval = 0.1
    local time = 0.3
	local spriteCard = CardSprite:createCard(value)
	spriteCard:setTag(cardIndex)
	spriteCard:addTo(self.userCard[viewid].area)
	self.userCard[viewid].area:setVisible(true)
	spriteCard:stopAllActions()
	spriteCard:setScale(0.6)
	spriteCard:setVisible(true)
	--是否有动画
	if bDoNotMove == false then
		spriteCard:setScale(viewid==cmd.MY_VIEWID and 1.0 or 0.8)
		spriteCard:setPosition(cc.p(ptCard[viewid].x + (viewid==cmd.MY_VIEWID and cardGapPlayer or cardGapOther)*(cardIndex- 1),ptCard[viewid].y))
	else
	    spriteCard:setScale(0.4)
		spriteCard:showCardBack(true)
        spriteCard:setRotation(76)
		spriteCard:move(375, 613)
        spriteCard:setVisible(false)
		spriteCard:runAction(
			cc.Sequence:create(
				cc.DelayTime:create(0.5),
                cc.Show:create(),
				cc.CallFunc:create(function ()						
                    ExternalFun.playSoundEffect("hkfivecardnew_send_card.mp3")
                    self:clearAddScoreSp()
                end),
				cc.Spawn:create(
                    cc.RotateTo:create(time, 720),
					cc.ScaleTo:create(time, viewid==cmd.MY_VIEWID and 1.0 or 0.8),
					cc.JumpTo:create(time, cc.p(ptCard[viewid].x + (viewid==cmd.MY_VIEWID and cardGapPlayer or cardGapOther)*(cardIndex- 1),ptCard[viewid].y), 100, 1)
                ),
                cc.CallFunc:create(function ()	
                    if cardIndex > 1 then 
                        spriteCard:setVisible(false)
                        local sprite = display.newSprite()
                                :setPosition(cc.p(ptCard[viewid].x +(viewid == cmd.MY_VIEWID and cardGapPlayer or cardGapOther) *(cardIndex - 1), ptCard[viewid].y))
                                :addTo(self.userCard[viewid].area1)
                                :setLocalZOrder(5)
					            :setScale(viewid==cmd.MY_VIEWID and 1.0 or 0.8)
                        local animation = cc.Animation:create()
                        for i = 1, 3 do
                            local frameName = string.format("hkfivecardnew_icon_sendCard%d.png", i)
                            local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
                            animation:addSpriteFrame(spriteFrame)
                        end  
                        animation:setDelayPerUnit(0.1)          -- 设置两个帧播放时间                   
                        animation:setRestoreOriginalFrame(true)    -- 动画执行后还原初始状态   
                        local action = cc.Animate:create(animation)
                        sprite:runAction(
                            cc.Sequence:create(
                                action, 
                                cc.RemoveSelf:create()
                            )
                        )
                    end
                end),
                cc.DelayTime:create(0.3),
                cc.CallFunc:create(function()
                    if cardIndex > 1 then 
                        spriteCard:showCardBack(false)
                        spriteCard:setVisible(true)
                    end
                end)
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

--赢得筹码
function GameViewLayer:WinTheChip(wWinner)
    self.m_pNodeSelect:setVisible(false)
    self.m_pNodeAddScore:setVisible(false)
	--筹码动作
	local children = self.nodeChipPool:getChildren()
	for k, v in pairs(children) do
		local tempTime = 1.5/#children 
		v:runAction(cc.Sequence:create(cc.DelayTime:create(tempTime*(#children - k)),
		cc.MoveTo:create(tempTime, cc.p(self.nodePlayer[wWinner]:getPositionX(),self.nodePlayer[wWinner]:getPositionY())),
		cc.CallFunc:create(function(node)
			node:removeFromParent()
		end)))
	end
end

--牌值类型
function GameViewLayer:setCardType(viewid,cardType)
    local gap = cardGapOther * 2
    
    if viewid==cmd.MY_VIEWID then
        gap = cardGapPlayer * 2
    end
	if cardType and cardType >= 1 and cardType <= 9 then
        local frameName  = string.format("#hkfivecardnew_icon_cardType_%d.png",cardType)   
		local cardTypeSp = display.newSprite(frameName)
		cardTypeSp:setPosition(ptCard[viewid].x + gap,ptCard[viewid].y-15)
		cardTypeSp:addTo(self.m_cardType)
		cardTypeSp:setTag(viewid)
        cardTypeSp:setLocalZOrder(2)
    elseif cardType == 10 then
        local cardTypeSp = display.newSprite("#hkfivecardnew_icon_qipai.png")		
        cardTypeSp:setPosition(ptCard[viewid].x + gap,ptCard[viewid].y-15)	
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
end

--菜单按钮回调方法
function GameViewLayer:ShowMenu(bShow)
	if self.m_bShowMenu ~= bShow then
		self.m_bShowMenu = bShow
		self.m_AreaMenu:stopAllActions()
		self.m_AreaMenu:setVisible(self.m_bShowMenu)
	end
end

function GameViewLayer:resetShowHandAnimate()
    local item = nil
    for i = 1, cmd.GAME_PLAYER do
        item = self.nodePlayer[i]:getChildByTag(977)
        if item ~= nil then
            item:stopAllActions()
            item:removeFromParent()
        end
        self.playerAllin[i]:setVisible(false)
        self.m_UserHead[i].bg:setVisible(true)
        self.m_UserHead[i].bg1:setVisible(false)
        self.m_UserHead[i].bg2:setVisible(false)
    end

--    self.m_pWindowFire:stopAllActions()
--    self.m_pWindowFire:setOpacity(0)
end

function GameViewLayer:IsShowGameEnd()
    if self._scene.m_tEndcmdTable == nil then
       self.bShowEndGame = true   
    else
       self._scene:ShowGameEnd()
    end         
end

--梭哈动画
function GameViewLayer:runShowHandAnimate(viewid)
    if viewid == nil then 
       return
    end 
    self.bShowEndGame = false

	local sprite = display.newSprite()
	sprite:setPosition(2,30)
    sprite:setTag(977)
	self.nodePlayer[viewid]:addChild(sprite,99) 
	local animation =cc.Animation:create()
	for i=1,8 do  
	    local frameName =string.format("hkfivecardnew_allin%d.png",i)                                            
	    --print("frameName =%s",frameName)  
	    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)               
	   animation:addSpriteFrame(spriteFrame)                                                             
	end  
   	animation:setDelayPerUnit(0.1)          --设置两个帧播放时间                   
   	animation:setRestoreOriginalFrame(true)    --动画执行后还原初始状态    

   	local action =cc.Animate:create(animation)                                                         
   	sprite:runAction(cc.RepeatForever:create(action))
    
    self.playerAllin[viewid]:setVisible(true)

    local allinBg = ccui.ImageView:create("hkfivecardnew_bg_allin.png",ccui.TextureResType.plistType)
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
   -- self.m_pWindowFire:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(1), cc.FadeOut:create(1))))
    self.m_UserHead[viewid].bg:setVisible(false)
    self.m_UserHead[viewid].bg1:setVisible(true)
    self.m_UserHead[viewid].bg2:setVisible(false)
end

--点击按钮出现的操作提示
function GameViewLayer:showTip(viewid,index)
    local tempTips = self.nodePlayer[viewid]:getChildByTag(245)
	if tempTips then
		tempTips:stopAllActions()
		tempTips:removeFromParent()
		tempTips = nil
	end

	local m_strCardFile = "game/hkfivecardnew_tab_font.png"	
	local tex = cc.Director:getInstance():getTextureCache():getTextureForKey(m_strCardFile);
	local rect = cc.rect((index-1)*88,0,88,47)
	--创建精灵
	local tips = cc.Sprite:create()
	tips:initWithTexture(tex,tex:getContentSize())
	tips:setTextureRect(rect);
	tips:setPosition(ptTips[viewid])
	tips:addTo(self.nodePlayer[viewid])
    tips:setTag(245)
    tips:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(1),
	    	cc.RemoveSelf:create()
        )
    )
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

		if viewid <= 3 then
			self.m_UserChat[viewid]:move(ptChat[viewid].x  , ptChat[viewid].y+5)
				:setAnchorPoint( cc.p(0.5, 0.5) )
		else
			self.m_UserChat[viewid]:move(ptChat[viewid].x  , ptChat[viewid].y)
				:setAnchorPoint(cc.p(0.5, 0.5))
		end
		--改变气泡大小
		self.m_UserChatView[viewid].node:setVisible(true)
		--self.m_UserChatView[viewid].bg:setContentSize(self.m_UserChat[viewid]:getContentSize().width+28, self.m_UserChat[viewid]:getContentSize().height + 27)
			:setVisible(false)
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
		if viewid <= 3 then
			self.m_UserChat[viewid]:move(ptChat[viewid].x,ptChat[viewid].y+5)
		else
			self.m_UserChat[viewid]:move(ptChat[viewid].x,ptChat[viewid].y+5)
		end
		self.m_UserChatView[viewid].node:setVisible(true)
			:setContentSize(90,80)
		self.m_UserChat[viewid]:runAction(cc.Sequence:create(
						cc.DelayTime:create(3),
						cc.CallFunc:create(function()
							self.m_UserChatView[viewid].node:setVisible(false)
							self.m_UserChat[viewid]:removeFromParent()
							self.m_UserChat[viewid]=nil
						end)
				))
	end
end

--运行输赢动画
function GameViewLayer:runWinLoseAnimate(score)
	--胜利失败动画
    local WinLose = nil
    local WinLoseTitle = nil
    local WinLoseText = nil
    local WinLoseGold = display.newSprite("#hkfivecardnew_icon_jb.png")
    if score > 0 then
        WinLose = display.newSprite("#hkfivecardnew_bg_victory.png")
        WinLoseTitle = display.newSprite("#hkfivecardnew_icon_win.png")
        WinLoseText = cc.LabelAtlas:_create(".0000000", "game/hkfivecardnew_num_2.png", 45, 54, string.byte("/"))

        local WinLoseLight = display.newSprite("#hkfivecardnew_icon_victory.png")
            :setLocalZOrder(-2)
            :setPosition(WinLose:getContentSize().width/2,WinLose:getContentSize().height/2)
            :addTo(WinLose)
        WinLoseLight:runAction(cc.RotateBy:create(2.5, 360))
    else
        WinLose = display.newSprite("#hkfivecardnew_bg_fail.png")
        WinLoseTitle = display.newSprite("#hkfivecardnew_icon_lose.png")
        WinLoseText = cc.LabelAtlas:_create("/0000000", "game/hkfivecardnew_num_1.png", 45, 54, string.byte("/"))
    end
    
    WinLose:setPosition(yl.DESIGN_WIDTH /2, yl.DESIGN_HEIGHT/2+50)
    WinLose:setScale(0)
    WinLose:setLocalZOrder(5)
    self:addChild(WinLose)
    
    WinLoseTitle:setPosition(WinLose:getContentSize().width/2,WinLose:getContentSize().height/2+15)
    WinLoseTitle:setScale(0.3)
    WinLose:addChild(WinLoseTitle)

    WinLoseGold:setPosition(WinLose:getContentSize().width/4-10,WinLose:getContentSize().height/8-50)
    WinLose:addChild(WinLoseGold)

    WinLoseText:setPosition(WinLose:getContentSize().width/4+40,WinLose:getContentSize().height/8-50)
    WinLoseText:setAnchorPoint(cc.p(0, 0.5))
    WinLoseText:setString("/"..math.abs(score))
    WinLose:addChild(WinLoseText)

    local length = (WinLoseGold:getContentSize().width + WinLoseText:getContentSize().width)/2

    WinLose:runAction(cc.Sequence:create(
                            cc.ScaleTo:create(0.2, 1, 1, 1),
                            cc.DelayTime:create(2.3),
		                    cc.CallFunc:create(function(ref)
			                    WinLose:setVisible(false)  
		                    end)
                 ))

    WinLoseTitle:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.2),
                    cc.ScaleTo:create(0.3, 1, 1, 1),
                    cc.DelayTime:create(2.1),
                    cc.CallFunc:create(function()
			           self.btnStart:setVisible(true) 
		               end)
                    ))                  
end

--function GameViewLayer:setBtnEnabled(btn, isEnabled)
--        btn:setTouchEnabled(isEnabled)
--        if isEnabled then
--             btn:getVirtualRenderer():setState(0)
--        else
--             btn:getVirtualRenderer():setState(1)
--        end
--end

function GameViewLayer:changeDesk() 
    local MeUserItem = self._scene._gameFrame:GetMeUserItem()
    if self._scene.m_cbGameStatus == cmd.GAME_SCENE_PLAY and MeUserItem.cbUserStatus == yl.US_PLAYING then
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

return GameViewLayer