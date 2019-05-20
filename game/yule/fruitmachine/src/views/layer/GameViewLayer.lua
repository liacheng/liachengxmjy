local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
	return gameViewLayer
end)

local module_pre = "game.yule.fruitmachine.src"
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local ClipText = appdf.EXTERNAL_SRC .. "ClipText"

local cmd = appdf.req(module_pre .. ".models.CMD_Game")
local HelpLayer =appdf.req(module_pre .. ".views.layer.HelpLayer")
local ZhuanPanAni=appdf.req(module_pre .. ".views.ZhuanPanAni")
local GameSystemMessage = require(appdf.EXTERNAL_SRC .. "GameSystemMessage")
GameViewLayer.TAG_GAMESYSTEMMESSAGE = 6751

GameViewLayer.BT_APPLE	 			= 1		
GameViewLayer.BT_ORANGE	 			= 2
GameViewLayer.BT_MANGO	 			= 3	
GameViewLayer.BT_BING	 			= 4	
GameViewLayer.BT_WATERMELON	 		= 5	
GameViewLayer.BT_STAR	 			= 6	
GameViewLayer.BT_SEVEN	 			= 7		
GameViewLayer.BT_BAR	 			= 8	
GameViewLayer.BT_START	 			= 9
GameViewLayer.BT_BIG	 			= 10
GameViewLayer.BT_SMALL	 			= 11
GameViewLayer.BT_RIGHT	 			= 12
GameViewLayer.BT_LEFT	 			= 13	
GameViewLayer.BT_CLEAN	 			= 14
GameViewLayer.BT_BACK	 			= 15
GameViewLayer.BT_MUSIC	 			= 16	
GameViewLayer.BT_SOUND	 			= 17
GameViewLayer.BT_CHAT	 			= 18
GameViewLayer.BT_ADD_ALL	 		= 19
GameViewLayer.BT_ADD_SINGLE	 		= 20

GameViewLayer.ACTION_APPLE = 21
GameViewLayer.ACTION_ORANGE = 22
GameViewLayer.ACTION_MANGO = 23
GameViewLayer.ACTION_BELL = 24
GameViewLayer.ACTION_WATERMELON = 25
GameViewLayer.ACTION_STAR = 26
GameViewLayer.ACTION_SEVEN = 27
GameViewLayer.ACTION_BAR = 28

GameViewLayer.SP_ADD_ALL	 		= 31
GameViewLayer.SP_ADD_SINGLE	 		= 32

local PopupInfoHead = require(appdf.EXTERNAL_SRC .. "PopupInfoHead")
local scheduler = cc.Director:getInstance():getScheduler()

function GameViewLayer:getParentNode()
	return self._scene
end

function GameViewLayer:ctor(scene)

	--播放背景音乐
	ExternalFun.setBackgroundAudio("sound_res/fruitmachine_bg.mp3")
	--注册node事件
	ExternalFun.registerNodeEvent(self)
	self._scene = scene
    --加载纹理
    self:loadTextures()
	--初始化csb界面
	self:initCsbRes()

    self.app_num = 0
    self.org_num = 0
    self.man_num = 0
    self.bing_num = 0
    self.wat_num = 0
    self.star_num = 0
    self.sev_num = 0
    self.bar_num = 0

    self.tbMul = {1, 2, 5, 10, 20}
    self.byMulIdx = 1

	self.GameStatus=cmd.GAME_STATUS_FREE
    self.begin_index = 1
    self.test = 0
    --背景
--    local bg = display.newSprite(cmd.RES.."gui-fruit-bgxx.png")
--        :setPosition(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2)
--        :addTo(self,-1)
    if nil == self.shine1 then
	   self.shine1=display.newSprite(cmd.RES.."gui-fruit-run.png")
       self.shine1:setPosition(cmd.tabZhuanpanPos[1])
	   :addTo(self)
    end

    if nil == self.shine2 then
	   self.shine2=display.newSprite(cmd.RES.."gui-fruit-run.png")
       self.shine2:setPosition(cmd.tabZhuanpanPos[2])
	   :addTo(self)
    end

    if nil == self.shine3 then
	   self.shine3=display.newSprite(cmd.RES.."gui-fruit-run.png")
       self.shine3:setPosition(cmd.tabZhuanpanPos[7])
	   :addTo(self)
    end

    if nil == self.shine4 then
	   self.shine4=display.newSprite(cmd.RES.."gui-fruit-run.png")
       self.shine4:setPosition(cmd.tabZhuanpanPos[8])
	   :addTo(self)
    end

    if nil == self.shine5 then
	   self.shine5=display.newSprite(cmd.RES.."gui-fruit-run.png")
       self.shine5:setPosition(cmd.tabZhuanpanPos[13])
	   :addTo(self)
    end

    if nil == self.shine6 then
	   self.shine6=display.newSprite(cmd.RES.."gui-fruit-run.png")
       self.shine6:setPosition(cmd.tabZhuanpanPos[14])
	   :addTo(self)
    end

    if nil == self.shine7 then
	   self.shine7=display.newSprite(cmd.RES.."gui-fruit-run.png")
       self.shine7:setPosition(cmd.tabZhuanpanPos[19])
	   :addTo(self)
    end

    if nil == self.shine8 then
	   self.shine8=display.newSprite(cmd.RES.."gui-fruit-run.png")
       self.shine8:setPosition(cmd.tabZhuanpanPos[20])
	   :addTo(self)
    end

    self.m_winLuck = nil

    self.m_winScore = 0
    self:animationForFirstOpening(true)
    --GlobalUserItem.setMusicVolume(0)
    --AudioEngine.stopMusic()

    --开始按钮长按，单击，双击，三击 变量
    self.count = 0
    self.longPress = false
    self.isMoved = false
    self.isAutoStart = false
    self.isPreNextRun = false
    self.bIsSubGameEnd = false

    --缓存PLIST
	--display.loadSpriteFrames(cmd.RES.."shuiguoji_resouce.plist",cmd.RES.."shuiguoji_resouce.png")
end

--加载纹理
function GameViewLayer:loadTextures()

    local plists = {
        "shuiguoji_resouce.plist",
        "dajiangtexiao_shuiguoji0.plist",
        "jiemianshangdecaideng_shuiguoji0.plist",
        "gamerule.plist"
    }

    --加载PLIST
    for i=1,#plists do
        cc.SpriteFrameCache:getInstance():addSpriteFrames(cmd.RES..plists[i])
        local dict = cc.FileUtils:getInstance():getValueMapFromFile(cmd.RES..plists[i])
        local framesDict = dict["frames"]
		if nil ~= framesDict and type(framesDict) == "table" then
			for k,v in pairs(framesDict) do
				local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
				if nil ~= frame then
					frame:retain()
				end
			end
		end
    end
end

--卸载纹理
function GameViewLayer:unloadTextures()
    local plists = {
        "shuiguoji_resouce.plist",
        "dajiangtexiao_shuiguoji0.plist",
        "jiemianshangdecaideng_shuiguoji0.plist",
        "gamerule.plist"
    }

	for i=1,#plists do
		local dict = cc.FileUtils:getInstance():getValueMapFromFile(cmd.RES..plists[i])

		local framesDict = dict["frames"]
		if nil ~= framesDict and type(framesDict) == "table" then
			for k,v in pairs(framesDict) do
				local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
				if nil ~= frame then
					frame:release()
				end
			end
		end
		cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(cmd.RES..plists[i])
	end

	cc.Director:getInstance():getTextureCache():removeTextureForKey(cmd.RES.."shuiguoji_resouce.png")
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end
-----------------------------------------------------------------------------
function GameViewLayer:animationForFirstOpening(flag)
    if(flag == true) then
        self.shine1.m_index=1
        self.shine2.m_index=2
        self.shine3.m_index=7
        self.shine4.m_index=8
        self.shine5.m_index=13
        self.shine6.m_index=14
        self.shine7.m_index=19
        self.shine8.m_index=20
	    local function play()
		    --self.shine:setPosition(cmd.tabZhuanpanPos[math.random(24)])
            self:moveAStep(self.shine1)
            self:moveAStep(self.shine2)
            self:moveAStep(self.shine3)
            self:moveAStep(self.shine4)
            self:moveAStep(self.shine5)
            self:moveAStep(self.shine6)
            self:moveAStep(self.shine7)
            self:moveAStep(self.shine8)
	    end
	    if self.m_schedule == nil then
		    self.m_schedule = scheduler:scheduleScriptFunc(play, 0.6, false)
		    --print(" self.m_schedule",self.m_schedule)
	    end
    else
	    if nil ~= self.m_schedule then
		    scheduler:unscheduleScriptEntry(self.m_schedule)
		    self.m_schedule = nil
		    self.shine1:removeSelf()
            self.shine2:removeSelf()
		    self.shine3:removeSelf()
            self.shine4:removeSelf()
		    self.shine5:removeSelf()
            self.shine6:removeSelf()
		    self.shine7:removeSelf()
            self.shine8:removeSelf()
		    --print("-----------self.m_schedule:unscheduleUpdate()-------------------")
	    end
    end
end

function GameViewLayer:moveAStep(node)
    node.m_index=node.m_index+1
    if node.m_index>24 then
	    node.m_index=1
    end
    node:setPosition(cmd.tabZhuanpanPos[node.m_index])
end

--初始化界面
function GameViewLayer:initCsbRes(  )
    self.m_rootLayer,self._csbNode = ExternalFun.loadRootCSB("GameScene.csb", self);

    local timeline = ExternalFun.loadTimeLine("GameScene.csb" )
    self._panel = self._csbNode:getChildByName("Panel_1")
    local gameBg = self._panel:getChildByName("bg")
    local gameBg1 = self._panel:getChildByName("bg_bottom")
    
    gameBg:setAnchorPoint(cc.p(0.5, 0.5))
    gameBg1:setAnchorPoint(cc.p(0.5, 0.5))

    gameBg1:setRotation(90)
    
    gameBg:setPosition(cc.p(yl.DESIGN_HEIGHT/2, yl.DESIGN_WIDTH/2))
    gameBg1:setPosition(cc.p(yl.DESIGN_HEIGHT/2, yl.WIDTH/2))
    --gameBg:setVisible(false)
    self.beginHandle = nil
    --播放时间轴动画
    self._csbNode:runAction(timeline)
    timeline:gotoFrameAndPlay(0, true)
    --初始化下拉菜单按钮
    self:initMenu()
    --初始化按钮
    self:initUI(self._csbNode)
end

--下拉菜单按钮
function GameViewLayer:initMenu()
    local function btnCallback(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end

    self.menuBg = cc.Scale9Sprite:create("fruitmachine_icon_bg.png");
    self.menuBg:setAnchorPoint(cc.p(0,0.5));
    self.menuBg:setPosition(cc.p(100, 114));
    self.menuBg:setContentSize(cc.size(225, 203));--]]
    --[[self.menuBg = display.newSprite("fruitmachine_icon_bg.png")
    self.menuBg:setAnchorPoint(cc.p(0, 0.5))
    self.menuBg:setPosition(cc.p(110, 100))--]]
    self:addChild(self.menuBg, 10)
    self.menuBg:setScaleX(0)

    local btnBack = ccui.Button:create("fruitmachine_btn_back.png", "fruitmachine_btn_back.png", "fruitmachine_btn_back.png", ccui.TextureResType.localType)
    btnBack:setTag(GameViewLayer.BT_BACK)
    btnBack:setPosition(cc.p(39, 101))
    btnBack:addTouchEventListener(btnCallback)
    self.menuBg:addChild(btnBack)

    local btnMusic = ccui.Button:create("fruitmachine_btn_music.png", "fruitmachine_btn_music.png", "fruitmachine_btn_music.png", ccui.TextureResType.localType)
    btnMusic:setTag(GameViewLayer.BT_MUSIC)
    btnMusic:setPosition(cc.p(111, 101))
    btnMusic:addTouchEventListener(btnCallback)
    self.menuBg:addChild(btnMusic)

    local btnSound = ccui.Button:create("fruitmachine_btn_sound.png", "fruitmachine_btn_sound.png", "fruitmachine_btn_sound.png", ccui.TextureResType.localType)
    btnSound:setTag(GameViewLayer.BT_SOUND)
    btnSound:setPosition(cc.p(184, 101))
    btnSound:addTouchEventListener(btnCallback)
    self.menuBg:addChild(btnSound)

    self.forbidMusic = display.newSprite("fruitmachine_icon_x.png")
    self.forbidMusic:setPosition(cc.p(34, 47))
    self.forbidMusic:setVisible(bIsShowForbitMusic)
    btnMusic:addChild(self.forbidMusic)

    self.bIsShowForbitSound = false
    self.forbidSound = display.newSprite("fruitmachine_icon_x.png")
    self.forbidSound:setPosition(cc.p(34, 47))
    self.forbidSound:setVisible(bIsShowForbitSound)
    btnSound:addChild(self.forbidSound)
    
    
    self.bIsShowForbitMusic = false

    if self.bIsShowForbitMusic then
        self.bIsShowForbitMusic = false
        self.forbidMusic:setVisible(false)       
    else
        GlobalUserItem.setMusicVolume(0)
        self.bIsShowForbitMusic = true
        self.forbidMusic:setVisible(true)
    end
end

----初始化UI
function GameViewLayer:initUI(csbNode )
    local function btnCallback( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end

    local botton = self._panel:getChildByName("bottom_botton")
    local btnExit = botton:getChildByName("Button_exit")
                    --:setTag(GameViewLayer.BT_EXIT)
	                --:addTouchEventListener(btnCallback)
                    :setRotation(-90)
                    :addClickEventListener(function() 
                        if self.menuBg:getNumberOfRunningActions() > 0 then
                            return
                        end
                        
                        if self.menuBg:getScaleX() == 1 then
                            self.menuBg:runAction(cc.ScaleTo:create(0.2, 0, 1))
                        elseif self.menuBg:getScaleX() == 0 then
                            self.menuBg:runAction(cc.ScaleTo:create(0.2, 1, 1))
                        end
                     end)
    self.isPlayerSound = true
    --玩家游戏币
    self.m_textUserCoin = self._panel:getChildByName("num_player_score")
    --彩金
    self.m_textUserlCaiJin = self._panel:getChildByName("num_lottery")
    --玩家成绩
    self.m_textUserWin = self._panel:getChildByName("num_win_score")
    --猜大小
    self.m_textBigSmall = self._panel:getChildByName("num_times")
    --筹码比例提示
    self._Text_hint = self._panel:getChildByName("Text_hint")
    self._Text_hint:setFontName("fonts/round_body.ttf")
    self._Text_hint:setFontSize(30)
    self._Text_hint:setTextColor(cc.c4b(255,255,0,255))
    self._Text_hint:setPosition(cc.p(self._Text_hint:getPositionX(),self._Text_hint:getPositionY()+20))
    --苹果按钮
    local btnApple = botton:getChildByName("Button_apple")
                    :setTag(GameViewLayer.BT_APPLE)
	                :addTouchEventListener(btnCallback)

    self.num_apple = botton:getChildByName("num_apple")

    --桔子按钮
    local btnOrange = botton:getChildByName("Button_orange")
                    :setTag(GameViewLayer.BT_ORANGE)
	                :addTouchEventListener(btnCallback)
    self.num_orange = botton:getChildByName("num_orange")

    --芒果按钮
    local btnMango = botton:getChildByName("Button_mango")
                    :setTag(GameViewLayer.BT_MANGO)
	                :addTouchEventListener(btnCallback)
    self.num_mango = botton:getChildByName("num_mango")

    --铃铛按钮
    local btnBing = botton:getChildByName("Button_bing")
                    :setTag(GameViewLayer.BT_BING)
	                :addTouchEventListener(btnCallback)
    self.num_bing = botton:getChildByName("num_bing")

    --西瓜按钮
    local btnWatermelon = botton:getChildByName("Button_watermelon")
                    :setTag(GameViewLayer.BT_WATERMELON)
	                :addTouchEventListener(btnCallback)
    self.num_watermelon = botton:getChildByName("num_watermelon")

    --星星按钮
    local btnStar = botton:getChildByName("Button_star")
                    :setTag(GameViewLayer.BT_STAR)
	                :addTouchEventListener(btnCallback)
    self.num_star = botton:getChildByName("num_star")

    --七七按钮
    local btnSeven = botton:getChildByName("Button_seven")
                    :setTag(GameViewLayer.BT_SEVEN)
	                :addTouchEventListener(btnCallback)
    self.num_seven = botton:getChildByName("num_seven")

    --bar按钮
    local btnBar = botton:getChildByName("Button_bar")
                    :setTag(GameViewLayer.BT_BAR)
	                :addTouchEventListener(btnCallback)
    self.num_bar = botton:getChildByName("num_bar")

--    local btnChat = ccui.Button:create("fruitmachine_btn_chat.png", "fruitmachine_btn_chat.png", "fruitmachine_btn_chat.png", ccui.TextureResType.localType)
--    btnChat:setPosition(cc.p(770,207))
--    btnChat:setTag(GameViewLayer.BT_CHAT)
--    btnChat:addTouchEventListener(btnCallback)
--    csbNode:addChild(btnChat)
    ------------------------------------------------------------
    local function beginhandle(dt)
        self.count = self.count + 1
        if self.count >= 2 then
            self.longPress = true
            self.isAutoStart = false
            if self._sprAutoStart:isVisible() == false then
                self.isAutoStart = true
            end
            self._sprAutoStart:setVisible(self.isAutoStart)
            self:onBtnStart()
            if self.beginHandle ~= nil then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.beginHandle)
                self.beginHandle = nil
            end
        end
    end
   
    local function eventTouch(ref, type)
        if ref:getTag() == GameViewLayer.BT_START then
            ExternalFun.btnEffect(ref, type)
        end
        self.isPlayerSound = true
        if ref == self.btnStart then
            if type == ccui.TouchEventType.began then
                self.btnStart:setBrightStyle(ccui.BrightStyle.normal)
                self.count = 0
                self.longPress = false
                self.isMoved = false
                
	            if nil == self.beginHandle then
                    self.beginHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(beginhandle,1,false)
                end
            elseif type == ccui.TouchEventType.moved then
                self.btnStart:setBrightStyle(ccui.BrightStyle.normal)
                self.isMoved = true            
            elseif type == ccui.TouchEventType.ended then
                self.btnStart:setBrightStyle(ccui.BrightStyle.normal)
                if self.beginHandle ~= nil then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.beginHandle)
                    self.beginHandle = nil
                end
                
                if self.isMoved then
                    self.isMoved = false
                    --return false
                end

                if self.longPress == false then
                    self.isAutoStart = false
                    self._sprAutoStart:setVisible(false)
                    self:onBtnStart()
                end
            elseif type == ccui.TouchEventType.cancel then
                if self.beginHandle ~= nil then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.beginHandle)
                    self.beginHandle = nil
                end
            end
        end
    end
    ------------------------------------------------------------
    --开始按钮
    self.btnStart = botton:getChildByName("Button_start")
                    :setTag(GameViewLayer.BT_START)
 	--self.btnStart:addTouchEventListener(btnCallback)
    self.btnStart:addTouchEventListener(eventTouch)
	self.startType = ccui.BrightStyle.normal
	--长按显示标志精灵
	self._sprAutoStart = display.newSprite("#gui-fruit-button-begin-click.png")
		:move(self.btnStart:getPositionX(),self.btnStart:getPositionY())
		--:setRotation(-90)
		:setVisible(false)
		:addTo(self._panel)
	print("X:" .. self.btnStart:getPositionX().. " Y:" .. self.btnStart:getPositionY())

    --移除选大按钮
    if botton:getChildByName("Button_big") then
        botton:removeChildByName("Button_big")
    end                 

    --移除选小按钮
    if botton:getChildByName("Button_small") then
        botton:removeChildByName("Button_small")
    end
    
    --选大按钮
    self.btnBig = ccui.Button:create("gui-fruit-button-da.png", "gui-fruit-button-da-click.png", "gui-fruit-button-da.png", ccui.TextureResType.localType)
    self.btnBig:setRotation(-90)
    self.btnBig:setPosition(cc.p(770,542))
    self.btnBig:setTag(GameViewLayer.BT_BIG)
    self.btnBig:addTouchEventListener(btnCallback)
    csbNode:addChild(self.btnBig) 

    --选小按钮
    self.btnSmall = ccui.Button:create("gui-fruit-button-xiao.png", "gui-fruit-button-xiao-click.png", "gui-fruit-button-xiao.png", ccui.TextureResType.localType)
    self.btnSmall:setRotation(-90)
    self.btnSmall:setPosition(cc.p(770,207))
    self.btnSmall:setTag(GameViewLayer.BT_SMALL)
    self.btnSmall:addTouchEventListener(btnCallback)
    csbNode:addChild(self.btnSmall) 

    --清除按钮              
    local btnClean = botton:getChildByName("Button_clean")
                    :setScale9Enabled(true)
                    :setCapInsets(cc.rect(44, 44, 53, 53))
                    :setAnchorPoint(cc.p(0.5,0.5))
                    :setContentSize(cc.size(116, 88))
                    :setPosition(cc.p(526,332))
                    :setTag(GameViewLayer.BT_CLEAN)
	                :addTouchEventListener(btnCallback)

    --每个区域押注
    btnAll = ccui.Button:create("gui-fruit-button-all.png", "gui-fruit-button-all-click.png", "gui-fruit-button-all.png", ccui.TextureResType.localType)
    btnAll:setScale9Enabled(true)
    btnAll:setCapInsets(cc.rect(44, 44, 53, 53))
    btnAll:setAnchorPoint(cc.p(0.5,0.5))
    btnAll:setContentSize(cc.size(116, 88))
    btnAll:setPosition(cc.p(426,332))
    btnAll:setTag(GameViewLayer.BT_ADD_ALL)
    btnAll:addTouchEventListener(btnCallback)
    botton:addChild(btnAll)
    self.spAll = cc.Sprite:create("all1.png")
    self.spAll:setPosition(cc.p(58,32))
    self.spAll:setTag(GameViewLayer.SP_ADD_ALL)
    btnAll:addChild(self.spAll)

    --单次押注
    btnSingle = ccui.Button:create("gui-fruit-button-single.png", "gui-fruit-button-single-click.png", "gui-fruit-button-single.png", ccui.TextureResType.localType)
    btnSingle:setScale9Enabled(true)
    btnSingle:setCapInsets(cc.rect(44, 44, 53, 53))
    btnSingle:setAnchorPoint(cc.p(0.5,0.5))
    btnSingle:setContentSize(cc.size(116, 88))
    btnSingle:setPosition(cc.p(314,332))
    btnSingle:setTag(GameViewLayer.BT_ADD_SINGLE)
    btnSingle:addTouchEventListener(btnCallback)
    botton:addChild(btnSingle)
    self.spSingle = cc.Sprite:create("singnal1.png")
    self.spSingle:setPosition(cc.p(58,32))
    self.spSingle:setTag(GameViewLayer.SP_ADD_SINGLE)
    btnSingle:addChild(self.spSingle)

     --选右按钮
    local btnRight = botton:getChildByName("Button_right")
                    :setScale9Enabled(true)
                    :setCapInsets(cc.rect(44, 44, 53, 53))
                    :setAnchorPoint(cc.p(0.5,0.5))
                    :setContentSize(cc.size(116, 88))
                    :setPosition(cc.p(192,332))
                    :setTag(GameViewLayer.BT_RIGHT)
	                :addTouchEventListener(btnCallback)

    --选左按钮
    local btnLeft = botton:getChildByName("Button_left")
                    :setScale9Enabled(true)
                    :setCapInsets(cc.rect(44, 44, 53, 53))
                    :setAnchorPoint(cc.p(0.5,0.5))
                    :setContentSize(cc.size(116, 88))
                    :setPosition(cc.p(86,332))
                    :setTag(GameViewLayer.BT_LEFT)
	                :addTouchEventListener(btnCallback)

    --规则按钮
    local btnHelp = botton:getChildByName("Button_ask")
          btnHelp:addClickEventListener(function()  
            HelpLayer:create()
                :setLocalZOrder(1)
                :addTo(self)   
            end)

end

-- 显示筹码比例
function GameViewLayer:ShowChipRate(chipRate)
    if self._Text_hint ~= nil then
        local str = string.format("温馨提示：本场每押一注将消耗您 %d 游戏币",chipRate)
        self._Text_hint:setString(str)
    end
end

--清除筹码
function GameViewLayer:clearPlaceJetton(lChipRate)
    if nil == lChipRate then
        lChipRate = self:getChipRate()
    end

    local totalNum = self.app_num+self.org_num+self.man_num+self.bing_num+self.wat_num+self.star_num+self.sev_num+self.bar_num
    self.app_num = 0
    self.num_apple:setString("0"..self.app_num)
    self.org_num = 0
    self.num_orange:setString("0"..self.org_num)
    self.man_num = 0
    self.num_mango:setString("0"..self.man_num)
    self.bing_num = 0
    self.num_bing:setString("0"..self.bing_num)
    self.wat_num = 0
    self.num_watermelon:setString("0"..self.wat_num)
    self.star_num = 0
    self.num_star:setString("0"..self.star_num)
    self.sev_num = 0
    self.num_seven:setString("0"..self.sev_num)
    self.bar_num = 0
    self.num_bar:setString("0"..self.bar_num)
    return totalNum*lChipRate
end

--刷新筹码
function GameViewLayer:RefreshPlaceJetton(bIsSubGameEnd, lChipRate, tbJetton)
    if nil == lChipRate then
        lChipRate = self:getChipRate()
    end

    --主要是旁观用户
    local num = tbJetton[1][1]/lChipRate
    self.num_apple:setString("0"..num)

    num = tbJetton[1][2]/lChipRate
    self.num_orange:setString("0"..num)

    num = tbJetton[1][3]/lChipRate
    self.num_mango:setString("0"..num)

    num = tbJetton[1][4]/lChipRate
    self.num_bing:setString("0"..num)

    num = tbJetton[1][5]/lChipRate
    self.num_watermelon:setString("0"..num)

    num = tbJetton[1][6]/lChipRate
    self.num_star:setString("0"..num)

    num = tbJetton[1][7]/lChipRate
    self.num_seven:setString("0"..num)

    num = tbJetton[1][8]/lChipRate
    self.num_bar:setString("0"..num)
    self.bIsSubGameEnd = bIsSubGameEnd
end

-- 自动开始
function GameViewLayer:autoStart()
	if self.isAutoStart == true then
        if self.hitsound~=nil then
            AudioEngine.stopEffect(self.hitsound)
        end
		if self.GameStatus ~= nil and self.GameStatus ~= cmd.GAME_STATUS_FREE then
		    return
	    else
            local function callback()
                self:onBtnStart()
            end
            local delay = cc.DelayTime:create(2)
            local sequence = cc.Sequence:create(delay,cc.CallFunc:create(callback))
            self:runAction(sequence)
        end
    else
        --self:clearPlaceJetton()
	end
end

function GameViewLayer:onExit()
	print("GameViewLayer onExit")
	
    if nil ~= self.m_schedule_luck1 then
        scheduler:unscheduleScriptEntry(self.m_schedule_luck1)
        self.m_schedule_luck1 = nil
    end
	--卸载缓存PLIST
    self:unloadTextures()
    --播放大厅背景音乐
    if nil ~= self.m_schedule then
        scheduler:unscheduleScriptEntry(self.m_schedule)
        self.m_schedule = nil
        self.shine1 = nil
        self.shine2 = nil
        self.shine3 = nil
        self.shine4 = nil
        self.shine5 = nil
        self.shine6 = nil
        self.shine7 = nil
        self.shine8 = nil
    end

    if nil ~= self.m_winLuck then
		self.m_winLuck:stopAllActions()
		--self.m_winLuckAction:release()
	end

    AudioEngine.stopAllEffects()
    --GlobalUserItem.setMusicVolume(100)
    ExternalFun.playPlazzBackgroudAudio()

end

-- 是否达到最大下注数目
function GameViewLayer:getChipRate()
    local ChipRate = 1
    if self._scene._ChipRate ~= nil then
        ChipRate = self._scene._ChipRate
    else 
        ChipRate = 1000
    end

    return ChipRate
end

-- 是否达到最大下注数目
function GameViewLayer:bIsMaxBeted(ChipRate, byBetNum)
    if nil == ChipRate then
        ChipRate = self:getChipRate()
    end

    if 0 <= (self._lUserScore-ChipRate*byBetNum) then  
        return false
    else
        --提示游戏币不足
        showToast(self,"游戏币不足，不能下注",1) 
        return true
    end
end

--提示信息
function GameViewLayer:ShowTipMsg(string)
    showToast(self,string,2) 
end

--准备下一局开始动作（主要用于清0、点下注）
function GameViewLayer:PreNextRun()
    if self.GameStatus ~= nil and self.GameStatus ~= cmd.GAME_STATUS_FREE then
	    return
    end

    --分数
    --[[local str = self.m_textUserWin:getString()
    print("分数:" .. str)
    local winScore = tonumber(str)
    print("分数:" .. winScore)
    self._lUserScore = self._lUserScore + winScore--]]
    self._lUserScore = self._lUserScore + self.m_winScore
    --增加金币并更新
    local str = tostring(self._lUserScore)
    self.m_textUserCoin:setString(str)
    --清空赢的金币
    self.m_winScore = 0
    self.m_textUserWin:setString("0")
	
    if self.isPreNextRun == true then
        self:clearPlaceJetton()
        self.isPreNextRun = false
        self.bIsSubGameEnd = false
    end
	
    if  self.zhuanPanAni ~= nil and self.zhuanPanAni.brightFrame~=nil then
        self.zhuanPanAni:StopShineFrame()
    end

    --print("-------------------------self.longPress = ",self.longPress)
    if self.blick_apple~=nil then
        self.blick_apple:stopAction(self.blick_apple:getActionByTag(GameViewLayer.ACTION_APPLE))
        self.blick_apple:removeSelf()
        self.blick_apple=nil
    end
    if self.blick_orange~=nil then
        self.blick_orange:stopAction(self.blick_orange:getActionByTag(GameViewLayer.ACTION_ORANGE))
        self.blick_orange:removeSelf()
        self.blick_orange=nil
    end
    if self.blick_mango~=nil then
        self.blick_mango:stopAction(self.blick_mango:getActionByTag(GameViewLayer.ACTION_MANGO))
        self.blick_mango:removeSelf()
        self.blick_mango=nil
    end
    if self.blick_bell~=nil then
        self.blick_bell:stopAction(self.blick_bell:getActionByTag(GameViewLayer.ACTION_BELL))
        self.blick_bell:removeSelf()
        self.blick_bell=nil
    end
    if self.blick_watermelon~=nil then
        self.blick_watermelon:stopAction(self.blick_watermelon:getActionByTag(GameViewLayer.ACTION_WATERMELON))
        self.blick_watermelon:removeSelf()
        self.blick_watermelon=nil
    end
    if self.blick_star~=nil then
        self.blick_star:stopAction(self.blick_star:getActionByTag(GameViewLayer.ACTION_STAR))
        self.blick_star:removeSelf()
        self.blick_star=nil
    end
    if self.blick_seven~=nil then
        self.blick_seven:stopAction(self.blick_seven:getActionByTag(GameViewLayer.ACTION_SEVEN))
        self.blick_seven:removeSelf()
        self.blick_seven=nil
    end
    if self.blick_bar~=nil then
        self.blick_bar:stopAction(self.blick_bar:getActionByTag(GameViewLayer.ACTION_BAR))
        self.blick_bar:removeSelf()
        self.blick_bar=nil
    end
    if self.luckFrame1~=nil then
        self.luckFrame1:removeSelf()
        self.luckFrame1 =nil
    end

    if self.luckFrame2~=nil then
        self.luckFrame2:removeSelf()
        self.luckFrame2 =nil
    end

    if self.luckFrame3~=nil then
        self.luckFrame3:removeSelf()
        self.luckFrame3 =nil
    end

    if self.luckFrame4~=nil then
        self.luckFrame4:removeSelf()
        self.luckFrame4 =nil
    end

    if self.luckFrame5~=nil then
        self.luckFrame5:removeSelf()
        self.luckFrame5 =nil
    end

    if self.luckFrame6~=nil then
        self.luckFrame6:removeSelf()
        self.luckFrame6 =nil
    end

    if (self.hitsound ~= nil) then
        AudioEngine.stopEffect(self.hitsound)
    end

    self.m_textBigSmall:setString("00") 
end

function GameViewLayer:SetBetNum(numBar, byBetNum)
    if byBetNum < 10 then 
        numBar:setString("0"..byBetNum)
    else 
        numBar:setString(""..byBetNum)
    end
end

function GameViewLayer:GetSingleBetNum(byCurBet)
    local bySingleAddNum = self.tbMul[self.byMulIdx]
    local byNowBet = bySingleAddNum+byCurBet
    if(byNowBet > cmd.GAME_MAX_PLACE_JETTON) then
        return cmd.GAME_MAX_PLACE_JETTON-byCurBet
    else
        return bySingleAddNum
    end
end

function GameViewLayer:GetAllBetNum()
    local tbBetNum = {self.app_num, self.org_num, self.man_num, self.bing_num, self.wat_num, self.star_num, self.sev_num, self.bar_num}
    local bySingleAddNum = self.tbMul[self.byMulIdx]

    local tbBetNumResult = {}
    local nBetNum = 0
    local byNowBet = 0
    for i=1,#tbBetNum do
        byNowBet = tbBetNum[i]+bySingleAddNum
        if byNowBet > cmd.GAME_MAX_PLACE_JETTON then
            tbBetNumResult[i] = cmd.GAME_MAX_PLACE_JETTON - tbBetNum[i]
            nBetNum = nBetNum + tbBetNumResult[i]
        else 
            tbBetNumResult[i] = bySingleAddNum
            nBetNum = nBetNum + bySingleAddNum
        end
    end

    return nBetNum,tbBetNumResult
end

function GameViewLayer:onButtonClickedEvent(tag, ref)
    --[[knight      单独定义退出按钮响应事件
	if tag == GameViewLayer.BT_EXIT then
		self._scene:onQueryExitGame()
    end]]
    if tag == GameViewLayer.BT_APPLE then
		self:PreNextRun()

        local byBetNum = self:GetSingleBetNum(self.app_num)
        if byBetNum <= 0 then
            return
        end
        local lChipRate = self:getChipRate()
	    if self:bIsMaxBeted(lChipRate, byBetNum) then
		    return
	    end
		
        self:animationForFirstOpening(false)
        if self.GameStatus ~= nil and self.GameStatus ~= cmd.GAME_STATUS_FREE then
		    return
	    end
		
        --播放音效
        ExternalFun.playSoundEffect("fruitmachine_bt_1.mp3")
        self.app_num = self.app_num + byBetNum
        self:SetBetNum(self.num_apple, self.app_num)

        self._lUserScore = self._lUserScore-lChipRate*byBetNum
	    self.m_textUserCoin:setString(tostring(self._lUserScore))
    elseif tag == GameViewLayer.BT_ORANGE then
		self:PreNextRun()
        
        local byBetNum = self:GetSingleBetNum(self.org_num)
        if byBetNum <= 0 then
            return
        end
	    local lChipRate = self:getChipRate()
	    if self:bIsMaxBeted(lChipRate, byBetNum) then
		    return
	    end
		
        self:animationForFirstOpening(false)
        if self.GameStatus ~= nil and self.GameStatus ~= cmd.GAME_STATUS_FREE then
		    return
	    end

        ExternalFun.playSoundEffect("fruitmachine_bt_2.mp3")
        self.org_num = self.org_num + byBetNum
        self:SetBetNum(self.num_orange, self.org_num)
        self._lUserScore = self._lUserScore-lChipRate*byBetNum
	    self.m_textUserCoin:setString(tostring(self._lUserScore))
    elseif tag == GameViewLayer.BT_MANGO then
		self:PreNextRun()
        
        local byBetNum = self:GetSingleBetNum(self.man_num)
        if byBetNum <= 0 then
            return
        end
	    local lChipRate = self:getChipRate()
	    if self:bIsMaxBeted(lChipRate, byBetNum) then
		    return
	    end
		
        self:animationForFirstOpening(false)
        if self.GameStatus ~= nil and self.GameStatus ~= cmd.GAME_STATUS_FREE then
		    return
	    end

        ExternalFun.playSoundEffect("fruitmachine_bt_3.mp3")
        self.man_num = self.man_num + byBetNum
        self:SetBetNum(self.num_mango, self.man_num)
        self._lUserScore = self._lUserScore-lChipRate*byBetNum
	    self.m_textUserCoin:setString(tostring(self._lUserScore))
    elseif tag == GameViewLayer.BT_BING then
		self:PreNextRun()

        local byBetNum = self:GetSingleBetNum(self.bing_num)
        if byBetNum <= 0 then
            return
        end
	    local lChipRate = self:getChipRate()
	    if self:bIsMaxBeted(lChipRate, byBetNum) then
		    return
	    end
		
        self:animationForFirstOpening(false)
        if self.GameStatus ~= nil and self.GameStatus ~= cmd.GAME_STATUS_FREE then
		    return
	    end

        ExternalFun.playSoundEffect("fruitmachine_bt_4.mp3")
        self.bing_num = self.bing_num + byBetNum
        self:SetBetNum(self.num_bing, self.bing_num)
        self._lUserScore = self._lUserScore-lChipRate*byBetNum
	    self.m_textUserCoin:setString(tostring(self._lUserScore))
    elseif tag == GameViewLayer.BT_WATERMELON then
        self:PreNextRun()

        local byBetNum = self:GetSingleBetNum(self.wat_num)
        if byBetNum <= 0 then
            return
        end
        local lChipRate = self:getChipRate()
        if self:bIsMaxBeted(lChipRate, byBetNum) then
	        return
        end
		
        self:animationForFirstOpening(false)
        if self.GameStatus ~= nil and self.GameStatus ~= cmd.GAME_STATUS_FREE then
		    return
	    end

        ExternalFun.playSoundEffect("fruitmachine_bt_5.mp3")
        self.wat_num = self.wat_num + byBetNum
        self:SetBetNum(self.num_watermelon, self.wat_num)
        self._lUserScore = self._lUserScore-lChipRate*byBetNum
	    self.m_textUserCoin:setString(tostring(self._lUserScore))
    elseif tag == GameViewLayer.BT_STAR then
	    self:PreNextRun()

        local byBetNum = self:GetSingleBetNum(self.star_num)
        if byBetNum <= 0 then
            return
        end
	    local lChipRate = self:getChipRate()
	    if self:bIsMaxBeted(lChipRate, byBetNum) then
		    return
	    end
		
        self:animationForFirstOpening(false)
        if self.GameStatus ~= nil and self.GameStatus ~= cmd.GAME_STATUS_FREE then
		    return
	    end

        ExternalFun.playSoundEffect("fruitmachine_bt_6.mp3")
        self.star_num = self.star_num + byBetNum
        self:SetBetNum(self.num_star, self.star_num)
        self._lUserScore = self._lUserScore-lChipRate*byBetNum
	    self.m_textUserCoin:setString(tostring(self._lUserScore))
    elseif tag == GameViewLayer.BT_SEVEN then
	    self:PreNextRun()

        local byBetNum = self:GetSingleBetNum(self.sev_num)
        if byBetNum <= 0 then
            return
        end
	    local lChipRate = self:getChipRate()
	    if self:bIsMaxBeted(lChipRate, byBetNum) then
		    return
	    end
		
        self:animationForFirstOpening(false)
        if self.GameStatus ~= nil and self.GameStatus ~= cmd.GAME_STATUS_FREE then
		    return
	    end       

        ExternalFun.playSoundEffect("fruitmachine_bt_7.mp3")
        self.sev_num = self.sev_num + byBetNum
        self:SetBetNum(self.num_seven, self.sev_num )
        self._lUserScore = self._lUserScore-lChipRate*byBetNum
	    self.m_textUserCoin:setString(tostring(self._lUserScore))
    elseif tag == GameViewLayer.BT_BAR then
	    self:PreNextRun()

        local byBetNum = self:GetSingleBetNum(self.bar_num)
        if byBetNum <= 0 then
            return
        end
	    local lChipRate = self:getChipRate()
	    if self:bIsMaxBeted(lChipRate, byBetNum) then
		    return
	    end
		
        self:animationForFirstOpening(false)
        if self.GameStatus ~= nil and self.GameStatus ~= cmd.GAME_STATUS_FREE then
		    return
	    end
        
        ExternalFun.playSoundEffect("fruitmachine_bt_8.mp3")
        self.bar_num = self.bar_num + byBetNum
        self:SetBetNum(self.num_bar, self.bar_num )
        self._lUserScore = self._lUserScore-lChipRate*byBetNum
	    self.m_textUserCoin:setString(tostring(self._lUserScore))
    elseif tag == GameViewLayer.BT_START then
--        if self.GameStatus ~= nil and self.GameStatus ~= cmd.GAME_STATUS_FREE then
--		    return
--	      else
--            self:onBtnStart()
--       end
    elseif tag == GameViewLayer.BT_CHAT then
        print("聊天按钮被点击")
        local item = self:getChildByTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
        if item ~= nil then
            item:resetData()
        else
            local gameSystemMessage = GameSystemMessage:create(1)
            gameSystemMessage:setLocalZOrder(100)
            gameSystemMessage:setTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
            self:addChild(gameSystemMessage)
        end
    elseif tag == GameViewLayer.BT_BIG then
        ExternalFun.playSoundEffect("fruitmachine_randombet.mp3")
	    if (self.hitsound ~= nil) then
             AudioEngine.stopEffect(self.hitsound)
        end
        self._smallBig=true
        if self.m_winScore > 0 then
            self:StartBigSmall()
            self.btnBig:setBrightStyle(ccui.BrightStyle.highlight)
        end
    elseif tag == GameViewLayer.BT_SMALL then
        ExternalFun.playSoundEffect("fruitmachine_randombet.mp3")
	    if (self.hitsound ~= nil) then
             AudioEngine.stopEffect(self.hitsound)
        end
        self._smallBig=false
        if self.m_winScore > 0 then
            self:StartBigSmall()
            self.btnSmall:setBrightStyle(ccui.BrightStyle.highlight)
        end
    --加倍按钮
    elseif tag == GameViewLayer.BT_LEFT then
        ExternalFun.playSoundEffect("fruitmachine_randombet.mp3")
	    if (self.hitsound ~= nil) then
             AudioEngine.stopEffect(self.hitsound)
        end
        if self.m_winScore > 0 then
            self._scene:LeftOrRight(0)
        end
    --减倍按钮
    elseif tag == GameViewLayer.BT_RIGHT then
        ExternalFun.playSoundEffect("fruitmachine_randombet.mp3")
	    if (self.hitsound ~= nil) then
             AudioEngine.stopEffect(self.hitsound)
        end
       
       if self.m_winScore > 0 then
             self._scene:LeftOrRight(1)
        end
    elseif tag == GameViewLayer.BT_CLEAN then
        self:animationForFirstOpening(false)
        ExternalFun.playSoundEffect("fruitmachine_randombet.mp3")
        local lChipRate = self:getChipRate()
        local lClearScore = self:clearPlaceJetton(lChipRate)
        if self.isPreNextRun ~= true then
            self._lUserScore = self._lUserScore+lClearScore
        end
        
	    self.m_textUserCoin:setString(tostring(self._lUserScore))
    elseif tag == GameViewLayer.BT_BACK then
        self._scene:onKeyBackLandSpace()
    elseif tag == GameViewLayer.BT_MUSIC then
        if self.bIsShowForbitMusic then
            self.bIsShowForbitMusic = false
            self.forbidMusic:setVisible(false)   
            GlobalUserItem.setMusicVolume(100) 
        else
            self.bIsShowForbitMusic = true
            self.forbidMusic:setVisible(true)
            GlobalUserItem.setMusicVolume(0)
        end
    elseif tag == GameViewLayer.BT_SOUND then
        --音效开关
        if self.bIsShowForbitSound then
            self.bIsShowForbitSound = false
            self.forbidSound:setVisible(false)
            GlobalUserItem.setSoundVolume(100)
        else
            self.bIsShowForbitSound = true
            self.forbidSound:setVisible(true)    
            GlobalUserItem.setSoundVolume(0)    
        end
    elseif tag == GameViewLayer.BT_ADD_ALL then
        self:PreNextRun()

        local byBetNum,tbBetResult = self:GetAllBetNum()
        if byBetNum <= 0 then
            return
        end
	    local lChipRate = self:getChipRate()
	    if self:bIsMaxBeted(lChipRate, byBetNum) then
		    return
	    end
		
        self:animationForFirstOpening(false)
        if self.GameStatus ~= nil and self.GameStatus ~= cmd.GAME_STATUS_FREE then
		    return
	    end
        
        self.app_num = self.app_num+tbBetResult[1]
        self.org_num = self.org_num+tbBetResult[2]
        self.man_num = self.man_num+tbBetResult[3]
        self.bing_num = self.bing_num+tbBetResult[4]
        self.wat_num = self.wat_num+tbBetResult[5]
        self.star_num = self.star_num+tbBetResult[6]
        self.sev_num = self.sev_num+tbBetResult[7]
        self.bar_num = self.bar_num+tbBetResult[8]
        self:SetBetNum(self.num_apple, self.app_num)
        self:SetBetNum(self.num_orange, self.org_num)
        self:SetBetNum(self.num_mango, self.man_num)
        self:SetBetNum(self.num_bing, self.bing_num)
        self:SetBetNum(self.num_watermelon, self.wat_num)
        self:SetBetNum(self.num_star, self.star_num)
        self:SetBetNum(self.num_seven, self.sev_num )
        self:SetBetNum(self.num_bar, self.bar_num )

        self._lUserScore = self._lUserScore-lChipRate*byBetNum
	    self.m_textUserCoin:setString(tostring(self._lUserScore))
    elseif tag == GameViewLayer.BT_ADD_SINGLE then
        self.byMulIdx = self.byMulIdx+1
        if self.byMulIdx > #self.tbMul then
            self.byMulIdx = 1
        end

        local spNewSingle = cc.Sprite:create(string.format("singnal%d.png", self.tbMul[self.byMulIdx]))
        self.spSingle:setTexture(spNewSingle:getTexture())
        local spNewAll = cc.Sprite:create(string.format("all%d.png", self.tbMul[self.byMulIdx]))
        self.spAll:setTexture(spNewAll:getTexture())
    end
end

function GameViewLayer:onBtnStart()
--      AudioEngine.stopAllEffects()
    if self.GameStatus ~= nil and self.GameStatus ~= cmd.GAME_STATUS_FREE then
	    return
    end

    if  self.zhuanPanAni ~= nil and self.zhuanPanAni.brightFrame~=nil then
        self.zhuanPanAni:StopShineFrame()
    end

    if self.isPlayerSound == false and self.isAutoStart == false then
        return
    end
    self.isPlayerSound = self.isAutoStart

	--如果猜大小之后，结果还没出来，又点了开始按钮，则视为放弃本次猜大小，中奖的分数加上去结算
	if (self.randomspin ~= nil) then
      AudioEngine.stopEffect(self.randomspin)
    end
	if nil ~= self.m_bigsmallschedule then
		scheduler:unscheduleScriptEntry(self.m_bigsmallschedule)
        self.m_bigsmallschedule = nil
	end
	--如果猜大小之后，结果还没出来，又点了开始按钮，则视为放弃本次猜大小，中奖的分数加上去结算

    --收分
    self._lUserScore = self._lUserScore + self.m_winScore
	local str = tostring(self._lUserScore)
	self.m_textUserCoin:setString(str)

    self.m_winScore = 0
    self.m_textUserWin:setString(0)

    --print("-------------------------self.longPress = ",self.longPress)
    if self.blick_apple~=nil then
        self.blick_apple:stopAction(self.blick_apple:getActionByTag(GameViewLayer.ACTION_APPLE))
        self.blick_apple:removeSelf()
        self.blick_apple=nil
    end
    if self.blick_orange~=nil then
        self.blick_orange:stopAction(self.blick_orange:getActionByTag(GameViewLayer.ACTION_ORANGE))
        self.blick_orange:removeSelf()
        self.blick_orange=nil
    end
    if self.blick_mango~=nil then
        self.blick_mango:stopAction(self.blick_mango:getActionByTag(GameViewLayer.ACTION_MANGO))
        self.blick_mango:removeSelf()
        self.blick_mango=nil
    end
    if self.blick_bell~=nil then
        self.blick_bell:stopAction(self.blick_bell:getActionByTag(GameViewLayer.ACTION_BELL))
        self.blick_bell:removeSelf()
        self.blick_bell=nil
    end
    if self.blick_watermelon~=nil then
        self.blick_watermelon:stopAction(self.blick_watermelon:getActionByTag(GameViewLayer.ACTION_WATERMELON))
        self.blick_watermelon:removeSelf()
        self.blick_watermelon=nil
    end
    if self.blick_star~=nil then
        self.blick_star:stopAction(self.blick_star:getActionByTag(GameViewLayer.ACTION_STAR))
        self.blick_star:removeSelf()
        self.blick_star=nil
    end
    if self.blick_seven~=nil then
        self.blick_seven:stopAction(self.blick_seven:getActionByTag(GameViewLayer.ACTION_SEVEN))
        self.blick_seven:removeSelf()
        self.blick_seven=nil
    end
    if self.blick_bar~=nil then
        self.blick_bar:stopAction(self.blick_bar:getActionByTag(GameViewLayer.ACTION_BAR))
        self.blick_bar:removeSelf()
        self.blick_bar=nil
    end
    if self.luckFrame1~=nil then
        self.luckFrame1:removeSelf()
        self.luckFrame1 =nil
    end

    if self.luckFrame2~=nil then
        self.luckFrame2:removeSelf()
        self.luckFrame2 =nil
    end

    if self.luckFrame3~=nil then
        self.luckFrame3:removeSelf()
        self.luckFrame3 =nil
    end

    if self.luckFrame4~=nil then
        self.luckFrame4:removeSelf()
        self.luckFrame4 =nil
    end

    if self.luckFrame5~=nil then
        self.luckFrame5:removeSelf()
        self.luckFrame5 =nil
    end

    if self.luckFrame6~=nil then
        self.luckFrame6:removeSelf()
        self.luckFrame6 =nil
    end

	if (self.hitsound ~= nil) then
      AudioEngine.stopEffect(self.hitsound)
    end

    self.m_textBigSmall:setString("00") 

    if(self.app_num>0 or self.org_num>0 or self.man_num>0 or self.bing_num>0 or self.wat_num>0 or self.star_num>0 or self.sev_num>0 or self.bar_num>0) then
	     local ChipRate = 1
         if self._scene._ChipRate ~= nil then
            ChipRate = self._scene._ChipRate
        else 
            ChipRate = 1000
         end

        local nCurBetTotal = 0
	    nCurBetTotal = self.app_num + self.org_num + self.man_num + self.bing_num + self.wat_num + self.star_num + self.sev_num + self.bar_num
	    nCurBetTotal = nCurBetTotal * ChipRate
        if self.bIsSubGameEnd then
            self._lUserScore = self._lUserScore - nCurBetTotal
            if 0 > self._lUserScore then
                 --提示游戏币不足
                showToast(self,"游戏币不足，不能下注",1)
                self._lUserScore = self._lUserScore + nCurBetTotal            
                self:SetGameStatus(cmd.GAME_STATUS_FREE)
                self.isAutoStart = false
                local lChipRate = self:getChipRate()
                self:clearPlaceJetton(lChipRate)
                self.isAutoStart = false
                self._sprAutoStart:setVisible(false)
                return
	        end
            --扣除金币并更新
            self.m_textUserCoin:setString(tostring(self._lUserScore))
            self.bIsSubGameEnd = false
        end
        self.btnBig:setBrightStyle(ccui.BrightStyle.normal)
        self.btnSmall:setBrightStyle(ccui.BrightStyle.normal)
        self._scene:OnPlaceJetton(self.app_num,self.org_num,self.man_num,self.bing_num,self.wat_num,self.star_num,self.sev_num,self.bar_num)
	else
        self.isAutoStart = false
		self._sprAutoStart:setVisible(false)
    end
end

--开始跑灯
function GameViewLayer:Run(cbWinArea, cbGoodLuckType, cbPaoHuoCheCount, cbPaoHuoCheArea)
    --print("-----Run-----")

	self._runSoundID = ExternalFun.playSoundEffect("fruitmachine_run.mp3")
	self.luck_key = cbWinArea
	local index = cbWinArea --math.random(24)
	local zhuanPanAni=ZhuanPanAni:create(self,self.begin_index,index,6,4)
	self.zhuanPanAni=zhuanPanAni
	local resultKind=ZhuanPanAni.zhuanpanPosToKind(index)
	self.begin_index = resultKind
	local function callback(resttime)		end
	self.zhuanPanAni:ZhuanPan(callback)

	self._cbGoodLuckType = cbGoodLuckType
	self._cbPaoHuoCheCount = cbPaoHuoCheCount
	self._cbPaoHuoCheArea = cbPaoHuoCheArea
end

function GameViewLayer:moveAStepLuck1(node,num)
    local luckNum = 0
 	local function play()
          self:moveAStep(node)
          luckNum = luckNum + 1
          if luckNum>=num then
	            if nil ~= self.m_schedule_luck1 then
		            scheduler:unscheduleScriptEntry(self.m_schedule_luck1)
		            self.m_schedule_luck1 = nil
		            ExternalFun.playSoundEffect("fruitmachine_Y007.mp3")
					if self._cbPaoHuoCheCount == 1 then
						self._scene:RunOver()
					end
                end
         end
    end

	if self.m_schedule_luck1 == nil then
		self.m_schedule_luck1 = scheduler:scheduleScriptFunc(play,0.02, false)
	end

end

function GameViewLayer:RunLuck1(cbWinArea)
    if nil == self.luckFrame1 then
	   self.luckFrame1=display.newSprite(cmd.RES.."gui-fruit-run.png")
       self.luckFrame1:setPosition(cmd.tabZhuanpanPos[self.begin_index])
	   :addTo(self)
    end

    local actStopShineFrame = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.25),cc.Blink:create(3,6)))
    actStopShineFrame:setTag(100)
    self.luckFrame1:runAction(actStopShineFrame)
    
    self.luckFrame1.m_index=self.begin_index
    self:moveAStepLuck1(self.luckFrame1,cbWinArea)

    print("-----RunLuck1-----")
end

function GameViewLayer:moveAStepLuck2(node,num)
    local luckNum = 0
 	local function play()
          self:moveAStep(node)
          luckNum = luckNum + 1
          if luckNum>=num then
	            if nil ~= self.m_schedule_luck2 then
		            scheduler:unscheduleScriptEntry(self.m_schedule_luck2)
		            self.m_schedule_luck2 = nil
		            ExternalFun.playSoundEffect("fruitmachine_Y007.mp3")
					if self._cbPaoHuoCheCount == 2 then
						self._scene:RunOver()
					end
                end
         end
    end

	if self.m_schedule_luck2 == nil then
		self.m_schedule_luck2 = scheduler:scheduleScriptFunc(play,0.02, false)
	end
end

function GameViewLayer:RunLuck2(cbWinArea)
    if nil == self.luckFrame2 then
	   self.luckFrame2=display.newSprite(cmd.RES.."gui-fruit-run.png")
       self.luckFrame2:setPosition(cmd.tabZhuanpanPos[self.begin_index])
	   :addTo(self)
    end

    local actStopShineFrame = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.25),cc.Blink:create(3,6)))
    actStopShineFrame:setTag(200)
    self.luckFrame2:runAction(actStopShineFrame)
     
    self.luckFrame2.m_index=self.begin_index
    self:moveAStepLuck2(self.luckFrame2,cbWinArea)

    print("-----RunLuck2-----")
end

function GameViewLayer:moveAStepLuck3(node,num)
    local luckNum = 0
    local function play()
        self:moveAStep(node)
        luckNum = luckNum + 1
        if luckNum>=num then
	        if nil ~= self.m_schedule_luck3 then
		        scheduler:unscheduleScriptEntry(self.m_schedule_luck3)
		        self.m_schedule_luck3 = nil
		        ExternalFun.playSoundEffect("fruitmachine_Y007.mp3")
				if self._cbPaoHuoCheCount == 3 then
					self._scene:RunOver()
				end
            end
        end
    end

    if self.m_schedule_luck3 == nil then
	    self.m_schedule_luck3 = scheduler:scheduleScriptFunc(play,0.02, false)
    end
end

function GameViewLayer:RunLuck3(cbWinArea)
    if nil == self.luckFrame3 then
	    self.luckFrame3=display.newSprite(cmd.RES.."gui-fruit-run.png")
        self.luckFrame3:setPosition(cmd.tabZhuanpanPos[self.begin_index])
	    :addTo(self)
    end

    local actStopShineFrame = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.25),cc.Blink:create(3,6)))
    actStopShineFrame:setTag(300)
    self.luckFrame3:runAction(actStopShineFrame)
    
    self.luckFrame3.m_index=self.begin_index
    self:moveAStepLuck3(self.luckFrame3,cbWinArea)
    print("-----RunLuck3-----")
end

function GameViewLayer:moveAStepLuck4(node,num)
    local luckNum = 0
 	local function play()
        self:moveAStep(node)
        luckNum = luckNum + 1
        if luckNum>=num then
            if nil ~= self.m_schedule_luck4 then
                scheduler:unscheduleScriptEntry(self.m_schedule_luck4)
                self.m_schedule_luck4 = nil
                ExternalFun.playSoundEffect("fruitmachine_Y007.mp3")
                if self._cbPaoHuoCheCount == 4 then
                    self._scene:RunOver()
                end
            end
        end
    end

	if self.m_schedule_luck4 == nil then
		self.m_schedule_luck4 = scheduler:scheduleScriptFunc(play,0.02, false)
	end
end

function GameViewLayer:RunLuck4(cbWinArea)
    if nil == self.luckFrame4 then
	    self.luckFrame4=display.newSprite(cmd.RES.."gui-fruit-run.png")
        self.luckFrame4:setPosition(cmd.tabZhuanpanPos[self.begin_index])
	    :addTo(self)
    end

    local actStopShineFrame = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.25),cc.Blink:create(3,6)))
    actStopShineFrame:setTag(400)
    self.luckFrame4:runAction(actStopShineFrame)
    
    self.luckFrame4.m_index=self.begin_index
    self:moveAStepLuck4(self.luckFrame4,cbWinArea)

    print("-----RunLuck4-----")
end

function GameViewLayer:moveAStepLuck5(node,num)
    local luckNum = 0
 	local function play()
        self:moveAStep(node)
        luckNum = luckNum + 1
        if luckNum>=num then
            if nil ~= self.m_schedule_luck5 then
                scheduler:unscheduleScriptEntry(self.m_schedule_luck5)
                self.m_schedule_luck5 = nil
                ExternalFun.playSoundEffect("fruitmachine_Y007.mp3")
                if self._cbPaoHuoCheCount == 5 then
                    self._scene:RunOver()
                end
            end
        end
    end

	if self.m_schedule_luck5 == nil then
		self.m_schedule_luck5 = scheduler:scheduleScriptFunc(play,0.02, false)
	end
end

function GameViewLayer:RunLuck5(cbWinArea)
    if nil == self.luckFrame5 then
	    self.luckFrame5=display.newSprite(cmd.RES.."gui-fruit-run.png")
        self.luckFrame5:setPosition(cmd.tabZhuanpanPos[self.begin_index])
	    :addTo(self)
    end

    local actStopShineFrame = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.25),cc.Blink:create(3,6)))
    actStopShineFrame:setTag(500)
    self.luckFrame5:runAction(actStopShineFrame)

    self.luckFrame5.m_index=self.begin_index
    self:moveAStepLuck5(self.luckFrame5,cbWinArea)

    print("-----RunLuck5-----")
end

function GameViewLayer:moveAStepLuck6(node,num)
    local luckNum = 0
 	local function play()
        self:moveAStep(node)
        luckNum = luckNum + 1
        if luckNum>=num then
            if nil ~= self.m_schedule_luck6 then
                scheduler:unscheduleScriptEntry(self.m_schedule_luck6)
                self.m_schedule_luck6 = nil
                ExternalFun.playSoundEffect("fruitmachine_Y007.mp3")
                if self._cbPaoHuoCheCount == 6 then
                    self._scene:RunOver()
                end
            end
        end
    end

	if self.m_schedule_luck6 == nil then
		self.m_schedule_luck6 = scheduler:scheduleScriptFunc(play,0.02, false)
	end
end

function GameViewLayer:RunLuck6(cbWinArea)
    if nil == self.luckFrame6 then
	    self.luckFrame6=display.newSprite(cmd.RES.."gui-fruit-run.png")
        self.luckFrame6:setPosition(cmd.tabZhuanpanPos[self.begin_index])
	    :addTo(self)
    end

    local actStopShineFrame = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.25),cc.Blink:create(3,6)))
    actStopShineFrame:setTag(600)
    self.luckFrame6:runAction(actStopShineFrame)

    self.luckFrame6.m_index=self.begin_index
    self:moveAStepLuck6(self.luckFrame6,cbWinArea)
    print("-----RunLuck6-----")
end

--开中小LUCK
function GameViewLayer:RunSmallLuck()
    if self._cbPaoHuoCheArea[1][1] <= 10 then
		self._cbPaoHuoCheArea[1][1] = self._cbPaoHuoCheArea[1][1]+24
	end
    if self._cbPaoHuoCheArea[1][2] <= 10 then
		self._cbPaoHuoCheArea[1][2] = self._cbPaoHuoCheArea[1][2]+24
	end
    if self._cbPaoHuoCheArea[1][3] <= 10 then
		self._cbPaoHuoCheArea[1][3] = self._cbPaoHuoCheArea[1][3]+24
	end

    --额外再跑1-3次灯
    local function callback3()
        self:RunLuck3(self._cbPaoHuoCheArea[1][3]-10)
    end

    local function callback2()
        if self._cbPaoHuoCheCount == 2 then
            self:RunLuck2(self._cbPaoHuoCheArea[1][2]-10)
        else
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),self:RunLuck2(self._cbPaoHuoCheArea[1][2]-10),cc.DelayTime:create(0.2),cc.CallFunc:create(callback3)))
        end
    end

    if self._cbPaoHuoCheCount == 1 then
        self:RunLuck1(self._cbPaoHuoCheArea[1][1]-10)
    else
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),self:RunLuck1(self._cbPaoHuoCheArea[1][1]-10),cc.DelayTime:create(0.2),cc.CallFunc:create(callback2)))
    end 

--	local function callbackRun2()
--		if self._cbPaoHuoCheArea[1][2] <= 10 then
--			self._cbPaoHuoCheArea[1][2] = self._cbPaoHuoCheArea[1][2]+24
--		end
--        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),self:RunLuck2(self._cbPaoHuoCheArea[1][2]-10)))
--    end

--	local function callbackRun3()
--		if self._cbPaoHuoCheArea[1][2] <= 10 then
--			self._cbPaoHuoCheArea[1][2] = self._cbPaoHuoCheArea[1][2]+24
--		end
--		if self._cbPaoHuoCheArea[1][3] <= 10 then
--			self._cbPaoHuoCheArea[1][3] = self._cbPaoHuoCheArea[1][3]+24
--		end
--        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),self:RunLuck2(self._cbPaoHuoCheArea[1][2]-10),cc.DelayTime:create(0.5),self:RunLuck3(self._cbPaoHuoCheArea[1][3]-10)))
--    end
--	----------------------------------------------------------

--    --额外再跑1-3次灯
--	if self._cbPaoHuoCheCount == 1 then
--		if self._cbPaoHuoCheArea[1][1] <= 10 then
--			self._cbPaoHuoCheArea[1][1] = self._cbPaoHuoCheArea[1][1]+24
--		end
--		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),self:RunLuck1(self._cbPaoHuoCheArea[1][1]-10)))
--	elseif self._cbPaoHuoCheCount == 2 then
--		if self._cbPaoHuoCheArea[1][1] <= 10 then
--			self._cbPaoHuoCheArea[1][1] = self._cbPaoHuoCheArea[1][1]+24
--		end
--		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),self:RunLuck1(self._cbPaoHuoCheArea[1][1]-10),cc.DelayTime:create(0.5),cc.CallFunc:create(callbackRun2)))
--	else
--		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),self:RunLuck1(self._cbPaoHuoCheArea[1][1]-10),cc.DelayTime:create(0.5),cc.CallFunc:create(callbackRun3)))
--	end
end

--开中大LUCK
function GameViewLayer:RunBigLuck()
    if self._cbPaoHuoCheArea[1][1] <= 22 then
		self._cbPaoHuoCheArea[1][1] = self._cbPaoHuoCheArea[1][1]+24
	end
    if self._cbPaoHuoCheArea[1][2] <= 22 then
		self._cbPaoHuoCheArea[1][2] = self._cbPaoHuoCheArea[1][2]+24
	end
    if self._cbPaoHuoCheArea[1][3] <= 22 then
		self._cbPaoHuoCheArea[1][3] = self._cbPaoHuoCheArea[1][3]+24
	end
    if self._cbPaoHuoCheArea[1][4] <= 22 then
		self._cbPaoHuoCheArea[1][4] = self._cbPaoHuoCheArea[1][4]+24
	end
    if self._cbPaoHuoCheArea[1][5] <= 22 then
		self._cbPaoHuoCheArea[1][5] = self._cbPaoHuoCheArea[1][5]+24
	end
    if self._cbPaoHuoCheArea[1][6] <= 22 then
		self._cbPaoHuoCheArea[1][6] = self._cbPaoHuoCheArea[1][6]+24
	end

    --额外再跑4-6次灯
    local function callback6()
        self:RunLuck6(self._cbPaoHuoCheArea[1][6]-22)
    end
    local function callback5()
        if self._cbPaoHuoCheCount == 5 then
            self:RunLuck5(self._cbPaoHuoCheArea[1][5]-22)
        else
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),self:RunLuck5(self._cbPaoHuoCheArea[1][5]-22),cc.DelayTime:create(0.2),cc.CallFunc:create(callback6)))
        end
    end
    local function callback4()
        if self._cbPaoHuoCheCount == 4 then
            self:RunLuck4(self._cbPaoHuoCheArea[1][4]-22)
        else
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),self:RunLuck4(self._cbPaoHuoCheArea[1][4]-22),cc.DelayTime:create(0.2),cc.CallFunc:create(callback5)))
        end
    end
    local function callback3()
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),self:RunLuck3(self._cbPaoHuoCheArea[1][3]-22),cc.DelayTime:create(0.2),cc.CallFunc:create(callback4)))
    end
    local function callback2()
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),self:RunLuck2(self._cbPaoHuoCheArea[1][2]-22),cc.DelayTime:create(0.2),cc.CallFunc:create(callback3)))
    end

    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),self:RunLuck1(self._cbPaoHuoCheArea[1][1]-22),cc.DelayTime:create(0.2),cc.CallFunc:create(callback2)))  
--	local function callbackRun3()
--        self:runAction(cc.Sequence:create(
--		cc.DelayTime:create(0.5),self:RunLuck2(self._cbPaoHuoCheArea[1][2]-22),
--		cc.DelayTime:create(0.5),self:RunLuck3(self._cbPaoHuoCheArea[1][3]-22),
--		cc.DelayTime:create(0.5),self:RunLuck4(self._cbPaoHuoCheArea[1][4]-22),
--        cc.DelayTime:create(0.5),self:RunLuck5(self._cbPaoHuoCheArea[1][5]-22),
--        cc.DelayTime:create(0.5),self:RunLuck6(self._cbPaoHuoCheArea[1][6]-22)))
--    end
	------------------------------------------------------
end

--跑灯结束
function GameViewLayer:RunOver()
    ----------luck_run----------
    if  self.luck_key==22 then
		if self._cbGoodLuckType ~= nil and self._cbGoodLuckType ~= 0 then
			self:RunBigLuck()
         else
            self._scene:RunOver()
		end
    end

    if  self.luck_key==10 then
		if self._cbGoodLuckType ~= nil and self._cbGoodLuckType ~= 0 then
			self:RunSmallLuck()
        else
            self._scene:RunOver()
		end
    end
    ----------luck_run----------
	if self.luck_key~=10 and self.luck_key~=22 then
		    self._scene:RunOver()
	end
	
    print("-----RunOver()-----")
    --print("self.luck_key"..self.luck_key.."   self.app_num"..self.app_num)
    local flag = false
    local function callback1()
        if self.GameStatus ~= nil and self.GameStatus ~= cmd.GAME_STATUS_FREE then
            return
        end
         if (self.luck_key==5 or self.luck_key==6 or self.luck_key==11 or self.luck_key==17 or self.luck_key==23) and self.app_num>0 then
            ExternalFun.playSoundEffect("fruitmachine_Y101.mp3")
            flag = true
            self.blick_apple=display.newSprite(cmd.RES.."button-0.png")
            self.blick_apple:setPosition(1126,689)
            self.blick_apple:setRotation(-90)
            self.blick_apple:addTo(self)
            local actApple = cc.RepeatForever:create(cc.Sequence:create(cc.Blink:create(3,6),cc.Hide:create()))
            actApple:setTag(GameViewLayer.ACTION_APPLE)
            --self.blick_apple:runAction(cc.Sequence:create(cc.Blink:create(3,6),cc.Hide:create()))
            self.blick_apple:runAction(actApple)
         elseif (self.luck_key==1 or self.luck_key==12 or self.luck_key==13) and self.org_num>0 then
            ExternalFun.playSoundEffect("fruitmachine_Y102.mp3")
            flag = true
            self.blick_orange=display.newSprite(cmd.RES.."button-1.png")
            self.blick_orange:setRotation(-90)
            self.blick_orange:setPosition(1126,600)
            self.blick_orange:addTo(self)
            local actOrange = cc.RepeatForever:create(cc.Sequence:create(cc.Blink:create(3,6),cc.Hide:create()))
            actOrange:setTag(GameViewLayer.ACTION_ORANGE)
            self.blick_orange:runAction(actOrange)
         elseif (self.luck_key==7 or self.luck_key==18 or self.luck_key==19) and self.man_num>0 then
            ExternalFun.playSoundEffect("fruitmachine_Y103.mp3")
            flag = true
            if self.luck_key==7 or self.luck_key==19 then
                self:WinLuck()
            end
            self.blick_mango=display.newSprite(cmd.RES.."button-2.png")
            self.blick_mango:setRotation(-90)
            self.blick_mango:setPosition(1126,510)
            self.blick_mango:addTo(self)
            local actMango = cc.RepeatForever:create(cc.Sequence:create(cc.Blink:create(3,6),cc.Hide:create()))
            actMango:setTag(GameViewLayer.ACTION_MANGO)
            self.blick_mango:runAction(actMango)
         elseif (self.luck_key==2 or self.luck_key==14 or self.luck_key==24) and self.bing_num>0 then
            ExternalFun.playSoundEffect("fruitmachine_Y104.mp3") 
            flag = true
            if self.luck_key==2 or self.luck_key==14 then
                self:WinLuck()
            end
            self.blick_bell=display.newSprite(cmd.RES.."button-3.png")
            self.blick_bell:setRotation(-90)
            self.blick_bell:setPosition(1126,419)
            self.blick_bell:addTo(self)
            local actBell = cc.RepeatForever:create(cc.Sequence:create(cc.Blink:create(3,6),cc.Hide:create()))
            actBell:setTag(GameViewLayer.ACTION_BELL)
            self.blick_bell:runAction(actBell)
         elseif (self.luck_key==8 or self.luck_key==9) and self.wat_num>0 then
            ExternalFun.playSoundEffect("fruitmachine_Y105.mp3")
            flag = true
            if self.luck_key==8 then
                self:WinLuck()
            end
            self.blick_watermelon=display.newSprite(cmd.RES.."button-4.png")
            self.blick_watermelon:setRotation(-90)
            self.blick_watermelon:setPosition(1126,328)
            self.blick_watermelon:addTo(self)
            local actWatermelon = cc.RepeatForever:create(cc.Sequence:create(cc.Blink:create(3,6),cc.Hide:create()))
            actWatermelon:setTag(GameViewLayer.ACTION_WATERMELON)
            self.blick_watermelon:runAction(actWatermelon)
         elseif (self.luck_key==20 or self.luck_key==21) and self.star_num>0 then
            ExternalFun.playSoundEffect("fruitmachine_Y106.mp3") 
            flag = true
            if self.luck_key==21 then
                self:WinLuck()  
            end
            self.blick_star=display.newSprite(cmd.RES.."button-5.png")
            self.blick_star:setRotation(-90)
            self.blick_star:setPosition(1126,235)
            self.blick_star:addTo(self)
            local actStar = cc.RepeatForever:create(cc.Sequence:create(cc.Blink:create(3,6),cc.Hide:create()))
            actStar:setTag(GameViewLayer.ACTION_STAR)
            self.blick_star:runAction(actStar)
         elseif (self.luck_key==15 or self.luck_key==16) and self.sev_num>0 then
            ExternalFun.playSoundEffect("fruitmachine_Y107.mp3") 
            flag = true
            if self.luck_key==16 then
                self:WinLuck()
            end
            self.blick_seven=display.newSprite(cmd.RES.."button-6.png")
            self.blick_seven:setRotation(-90)
            self.blick_seven:setPosition(1126,143)
            self.blick_seven:addTo(self)
            local actSeven = cc.RepeatForever:create(cc.Sequence:create(cc.Blink:create(3,6),cc.Hide:create()))
            actSeven:setTag(GameViewLayer.ACTION_SEVEN)
            self.blick_seven:runAction(actSeven)
         elseif (self.luck_key==3 or self.luck_key==4) and self.bar_num>0 then
            ExternalFun.playSoundEffect("fruitmachine_Y108.mp3") 
            flag = true
            self:WinLuck()
            self.blick_bar=display.newSprite(cmd.RES.."button-7.png")
            self.blick_bar:setRotation(-90)
            self.blick_bar:setPosition(1126,52)
            self.blick_bar:addTo(self)
            local actBar = cc.RepeatForever:create(cc.Sequence:create(cc.Blink:create(3,6),cc.Hide:create()))
            actBar:setTag(GameViewLayer.ACTION_BAR)
            self.blick_bar:runAction(actBar)
         elseif (self.luck_key==10 or self.luck_key==22) then
            if (self._cbGoodLuckType ~= nil and self._cbGoodLuckType ~= 0) then
                ExternalFun.playSoundEffect("fruitmachine_lucky.mp3") 
            else 
                ExternalFun.playSoundEffect("fruitmachine_luck_fail.mp3") 
            end
            flag = false
         end
    end
    local function callback2()
        if flag == true then
            self:PlayHitMusic()
        end
        self.isPlayerSound = true
    end

    local delay = cc.DelayTime:create(0.25)
    local sequence = cc.Sequence:create(delay,cc.CallFunc:create(callback1),delay,cc.CallFunc:create(callback2))
	--去掉delay，防止快速点击开始各种不停止
	--local sequence = cc.Sequence:create(cc.CallFunc:create(callback1),cc.CallFunc:create(callback2))
    self:runAction(sequence)

 end

 --设置游戏状态
function GameViewLayer:PlayHitMusic()

    if self.hitsound ~= nil then
        AudioEngine.stopEffect(self.hitsound)
        self.hitsound = nil
    end

	local strSound = string.format("fruitmachine_C0%d.mp3",math.random(1,4))
	self.hitsound = ExternalFun.playSoundEffect(strSound)
end

--设置游戏状态
function GameViewLayer:SetGameStatus(GameStatus)
	self.GameStatus = GameStatus
end

--刷新彩金
function GameViewLayer:RefreshCaiJin(lCaiJin)
    --彩金
	local str = tostring(lCaiJin) --local str = ExternalFun.numberThousands(lCaiJin)
--	if string.len(str) > 19 then
--		str = string.sub(str, 1, 19)
--	end
--	str = string.gsub(str,",","/")
	self.m_textUserlCaiJin:setString(str)
end

--刷新游戏分数
function GameViewLayer:refreshGameScore(lUserScore, lUserWinScore)
    local function callback()
        if self._runSoundID ~= nil then
		    AudioEngine.stopEffect(self._runSoundID)
        end
    end 
    local delay = cc.DelayTime:create(0.5)
    local sequence = cc.Sequence:create(delay,cc.CallFunc:create(callback))
    self:runAction(sequence)
	self._runSoundID = nil
	
	--金币
	local str = tostring(lUserScore)
    self._lUserScore = lUserScore
	self.m_textUserCoin:setString(str)

	--分数
	str = tostring(lUserWinScore)
	self.m_textUserWin:setString(str)
    self.m_winScore = lUserWinScore

	self.isPreNextRun = true
end

--刷新游戏得分
function GameViewLayer:refreshWinScore(lUserWinScore)
    local function callback()
        if self._runSoundID ~= nil then
		    AudioEngine.stopEffect(self._runSoundID)
        end
    end 
    local delay = cc.DelayTime:create(0.5)
    local sequence = cc.Sequence:create(delay,cc.CallFunc:create(callback))
    self:runAction(sequence)
	self._runSoundID = nil
end

--刷新游戏分数
function GameViewLayer:LeftOrRight(byLeftRight, lBigSmallScore, lChipRate)
    if 0 == byLeftRight then
        --加倍
       if self.m_winScore+lChipRate <= lBigSmallScore*2 and self._lUserScore-lChipRate >= 0 then
            self.m_winScore = self.m_winScore + lChipRate
            self._lUserScore = self._lUserScore - lChipRate
        end
    else 
        --减倍
        if self.m_winScore-lChipRate >= 0 then
            self.m_winScore = self.m_winScore - lChipRate
            self._lUserScore = self._lUserScore + lChipRate
        end
    end
    self:refreshGameScore(self._lUserScore, self.m_winScore)
end

--猜大小结束
function GameViewLayer:OverBigSmall(bigSmall)
	if nil ~= self.m_bigsmallschedule then
			scheduler:unscheduleScriptEntry(self.m_bigsmallschedule)
            self.m_bigsmallschedule = nil
    end
	
   	if (self.randomspin ~= nil) then
      AudioEngine.stopEffect(self.randomspin)
    end

    local str = bigSmall
    self.m_textBigSmall:setString(str)
end

--刷新猜大小
function GameViewLayer:StartBigSmall()
	--金币
	local function run()
        local str = math.random(14)
        self.m_textBigSmall:setString(str)
    end
	if self.m_bigsmallschedule == nil then
		self.m_bigsmallschedule = scheduler:scheduleScriptFunc(run, 0.1, false)
	end

    local function callback()
		if nil ~= self.m_bigsmallschedule then
			scheduler:unscheduleScriptEntry(self.m_bigsmallschedule)
            self.m_bigsmallschedule = nil
            if self.m_winScore > 0 then
                --self:StartBigSmall()
                --选大小
                local lScore = tonumber(self.m_textUserWin:getString())
                if self._smallBig ~= nil then
                    self._scene:BigSmall(self._smallBig,lScore)
                end
            end
        end
    end
    self.randomspin = ExternalFun.playSoundEffect("fruitmachine_randomspin.mp3")
    local delay = cc.DelayTime:create(2)
    local sequence = cc.Sequence:create(delay,cc.CallFunc:create(callback))
    self:runAction(sequence)
end

function GameViewLayer:WinLuck()
	local csbNode = ExternalFun.loadCSB("BigLuck.csb", self)
	--csbNode:setVisible(false)
    csbNode:setRotation(-90)
    csbNode:setPosition(667,375)
	self.m_winLuck = csbNode

	self.m_winLuckAction = ExternalFun.loadTimeLine("BigLuck.csb", self)
	--self.m_winAction:retain()

    --播放时间轴动画
    self.m_winLuck:runAction(self.m_winLuckAction)
    self.m_winLuckAction:gotoFrameAndPlay(0, false)

    local function callback()
        self.m_winLuck:setVisible(false)
    end
    local delay = cc.DelayTime:create(3)
    local sequence = cc.Sequence:create(delay,cc.CallFunc:create(callback))
    self:runAction(sequence)
end
return GameViewLayer