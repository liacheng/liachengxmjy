--[[游戏的设置界面当前只支持音乐音效]]
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameSetLayer = class("GameSetLayer", function(version, index)
    local gamesetlayer = display.newLayer()
    return gamesetlayer
end)

GameSetLayer.TAG_BACKGROUND  =  0   
GameSetLayer.TAG_MUSIC_OPEN  =  1   
GameSetLayer.TAG_MUSIC_CLOSE =  2
GameSetLayer.TAG_SOUND_OPEN  =  3
GameSetLayer.TAG_SOUND_CLOSE =  4
GameSetLayer.TAG_CLOSE       =  5

-- 进入场景而且过渡动画结束时候触发。
function GameSetLayer:onEnterTransitionFinish()
    return self
end

-- 退出场景而且开始过渡动画时候触发。
function GameSetLayer:onExitTransitionStart()
	self:unregisterScriptTouchHandler()
    return self
end

function GameSetLayer:ctor(version)
	--回调函数
	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			self:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			self:onExitTransitionStart()
		end
	end)

	--按键监听
	local onBtnCallBack = function(ref, type)
        if ref:getTag() == GameSetLayer.TAG_CLOSE then
            ExternalFun.btnEffect(ref, type)
        end

        if type == ccui.TouchEventType.ended then
         	self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    if version == nil then
        return nil
    end
    
    self.m_pNode = ccui.Layout:create()
    self.m_pNode:setContentSize(cc.size(yl.DESIGN_WIDTH, yl.DESIGN_HEIGHT))
    self.m_pNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_pNode:setPosition(cc.p(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2))
    self:addChild(self.m_pNode)
    -- 背景
    local bgNode = ccui.ImageView:create("baccaratnew_bg_score.png", ccui.TextureResType.plistType)
		:setTag(GameSetLayer.TAG_BACKGROUND)
		:move(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2)
        :setScale9Enabled(true)
        :setContentSize(cc.size(579, 383))
		:addTo(self.m_pNode)

    ccui.ImageView:create("baccaratnew_bg_setandhelp.png", ccui.TextureResType.plistType)
		:setTag(GameSetLayer.TAG_BACKGROUND)
		:move(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2-10)
        :setScale9Enabled(true)
        :setContentSize(cc.size(537, 230))
		:addTo(self.m_pNode)

    display.newSprite("#baccaratnew_bg_score_title.png")
		:move(yl.DESIGN_WIDTH/2, 515)
		:addTo(self.m_pNode)

    display.newSprite("#baccaratnew_set_icon_bgTitle.png")
		:move(yl.DESIGN_WIDTH/2, 539)
		:addTo(self.m_pNode)
        
        
    -- 音乐按钮-开
    -- 音乐按钮-关
    -- 音乐文字
	ccui.Button:create("baccaratnew_set_btn_open.png", "baccaratnew_set_btn_open.png", "", ccui.TextureResType.plistType)
        :move(578, 360)
        :setTag(GameSetLayer.TAG_MUSIC_OPEN)
        :addTo(self.m_pNode)
        :addTouchEventListener(onBtnCallBack)

	ccui.Button:create("baccaratnew_set_btn_close.png", "baccaratnew_set_btn_close.png", "", ccui.TextureResType.plistType)
        :move(578, 360)
        :setTag(GameSetLayer.TAG_MUSIC_CLOSE)
        :addTo(self.m_pNode)
        :addTouchEventListener(onBtnCallBack)
        
    display.newSprite("#baccaratnew_set_icon_music.png")
		:setTag(GameSetLayer.TAG_BACKGROUND)
		:move(462, 360)
		:addTo(self.m_pNode)

    -- 音效按钮-开
    -- 音效按钮-关
    -- 音效文字
	ccui.Button:create("baccaratnew_set_btn_open.png", "baccaratnew_set_btn_open.png", "", ccui.TextureResType.plistType)
        :move(yl.DESIGN_WIDTH/2+179, 360)
        :setTag(GameSetLayer.TAG_SOUND_OPEN)
        :addTo(self.m_pNode)
        :addTouchEventListener(onBtnCallBack)
        
	ccui.Button:create("baccaratnew_set_btn_close.png", "baccaratnew_set_btn_close.png", "", ccui.TextureResType.plistType)
        :move(yl.DESIGN_WIDTH/2+179, 360)
        :setTag(GameSetLayer.TAG_SOUND_CLOSE)
        :addTo(self.m_pNode)
        :addTouchEventListener(onBtnCallBack)
        
    display.newSprite("#baccaratnew_set_icon_sound.png")
		:setTag(GameSetLayer.TAG_BACKGROUND)
		:move(730,360)
		:addTo(self.m_pNode)

    -- 关闭按钮
	ccui.Button:create("baccaratnew_btn_close_1.png", "baccaratnew_btn_close_1.png", "", ccui.TextureResType.plistType)
        :move(940, 505)
        :setTag(GameSetLayer.TAG_CLOSE)
        :addTo(self.m_pNode)
        :addTouchEventListener(onBtnCallBack)
        
    --版本号
    local verstr = "当前版本: ver " .. appdf.BASE_C_VERSION .. "." .. version
    -- 文字
    ccui.Text:create(verstr, "fonts/round_body.ttf", 25)
		:setTextColor(cc.c4b(255,255,255,255))
		:setAnchorPoint(cc.p(1, 0.5))
		:move(892, 228)
		:addTo(self.m_pNode)

    ExternalFun.showLayer(self, self, true, true,bgNode,false)
    self:updateBtnState()
end

--按键点击
function GameSetLayer:onButtonClickedEvent(tag, ref)
	if self.isDiss == true then
		return
	end

    if tag == GameSetLayer.TAG_CLOSE then
        ExternalFun.playClickEffect()
        ExternalFun.hideLayer(self, self,false)
    elseif tag == GameSetLayer.TAG_MUSIC_OPEN then
        GlobalUserItem.nMusic = 0
        GlobalUserItem.setMusicVolume(0)
    elseif tag == GameSetLayer.TAG_MUSIC_CLOSE then
        GlobalUserItem.nMusic = 100
		GlobalUserItem.setMusicVolume(100)
    elseif tag == GameSetLayer.TAG_SOUND_OPEN then
        GlobalUserItem.nSound = 0
		GlobalUserItem.setSoundVolume(0)
    elseif tag == GameSetLayer.TAG_SOUND_CLOSE then
        GlobalUserItem.nSound = 100
		GlobalUserItem.setSoundVolume(100)
    end
    self:updateBtnState()
end

function GameSetLayer:updateBtnState()
    -- 检测当前音乐音效是否开启
    if GlobalUserItem.nMusic == 100 then
        self.m_pNode:getChildByTag(GameSetLayer.TAG_MUSIC_OPEN):setVisible(true)
        self.m_pNode:getChildByTag(GameSetLayer.TAG_MUSIC_CLOSE):setVisible(false)
    else
        self.m_pNode:getChildByTag(GameSetLayer.TAG_MUSIC_OPEN):setVisible(false)
        self.m_pNode:getChildByTag(GameSetLayer.TAG_MUSIC_CLOSE):setVisible(true)
    end
    
    if GlobalUserItem.nSound == 100 then
        self.m_pNode:getChildByTag(GameSetLayer.TAG_SOUND_OPEN):setVisible(true)
        self.m_pNode:getChildByTag(GameSetLayer.TAG_SOUND_CLOSE):setVisible(false)
    else
        self.m_pNode:getChildByTag(GameSetLayer.TAG_SOUND_OPEN):setVisible(false)
        self.m_pNode:getChildByTag(GameSetLayer.TAG_SOUND_CLOSE):setVisible(true)
    end
end
function GameSetLayer:onShow()
    ExternalFun.showLayer(self, self, true, true)
end
return GameSetLayer
