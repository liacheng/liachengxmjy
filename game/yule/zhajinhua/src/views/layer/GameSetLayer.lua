--[[
	所有游戏的设置界面
    当前只支持音乐音效
]]
local GameSetLayer = class("GameSetLayer", function(version, index)
    local GameSetLayer = display.newLayer()
    return GameSetLayer
end)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
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

--窗外触碰
function GameSetLayer:setCanTouchOutside(canTouchOutside)
	self._canTouchOutside = canTouchOutside
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

    -- 背景
    local sprStr = string.format("setting/zhajinhua_set_icon_bg.png")
	local bg = display.newSprite(sprStr)
		:setTag(GameSetLayer.TAG_BACKGROUND)
		:move(appdf.WIDTH/2,appdf.HEIGHT/2)
		:addTo(self)
        
    -- 音乐按钮-开
    -- 音乐按钮-关
    -- 音乐文字
    sprStr = string.format("setting/zhajinhua_set_btn_open.png")
	ccui.Button:create(sprStr, sprStr)
        :move(568, 360)
        :setTag(GameSetLayer.TAG_MUSIC_OPEN)
        :addTo(self)
        :addTouchEventListener(onBtnCallBack)

    sprStr = string.format("setting/zhajinhua_set_btn_close.png")
	ccui.Button:create(sprStr, sprStr)
        :move(568, 360)
        :setTag(GameSetLayer.TAG_MUSIC_CLOSE)
        :addTo(self)
        :addTouchEventListener(onBtnCallBack)
        
    sprStr = string.format("setting/zhajinhua_set_icon_music.png")
    display.newSprite(sprStr)
		:setTag(GameSetLayer.TAG_BACKGROUND)
		:move(472, 360)
		:addTo(self)

    -- 音效按钮-开
    -- 音效按钮-关
    -- 音效文字
    sprStr = string.format("setting/zhajinhua_set_btn_open.png")
	ccui.Button:create(sprStr, sprStr)
        :move(appdf.WIDTH/2+169, 360)
        :setTag(GameSetLayer.TAG_SOUND_OPEN)
        :addTo(self)
        :addTouchEventListener(onBtnCallBack)

    sprStr = string.format("setting/zhajinhua_set_btn_close.png")
	ccui.Button:create(sprStr, sprStr)
        :move(appdf.WIDTH/2+169, 360)
        :setTag(GameSetLayer.TAG_SOUND_CLOSE)
        :addTo(self)
        :addTouchEventListener(onBtnCallBack)
        
    sprStr = string.format("setting/zhajinhua_set_icon_sound.png")
    display.newSprite(sprStr)
		:setTag(GameSetLayer.TAG_BACKGROUND)
		:move(740,360)
		:addTo(self)

    -- 关闭按钮
    ccui.Button:create("setting/zhajinhua_set_btn_exit.png","setting/zhajinhua_set_btn_exit.png")
        :move(910, 490)
        :setTag(GameSetLayer.TAG_CLOSE)
        :addTo(self)
        :addTouchEventListener(onBtnCallBack)
        
    --版本号
    local verstr = "当前版本: ver " .. appdf.BASE_C_VERSION .. "." .. version
    -- 文字
    ccui.Text:create(verstr, "fonts/round_body.ttf", 20)
		:setTextColor(cc.c4b(255,255,255,255))
		:setAnchorPoint(cc.p(1, 0.5))
		:move(892, 242)
		:addTo(self)
    ExternalFun.showLayer(self, self,true,true,bg,false)
    self:updateBtnState()
end

--按键点击
function GameSetLayer:onButtonClickedEvent(tag, ref)
	if self._isDiss == true then
		return
	end

    if tag == GameSetLayer.TAG_CLOSE then
	    ExternalFun.playClickEffect()
        ExternalFun.hideLayer(self, self, false)
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
        self:getChildByTag(GameSetLayer.TAG_MUSIC_OPEN):setVisible(true)
        self:getChildByTag(GameSetLayer.TAG_MUSIC_CLOSE):setVisible(false)
    else
        self:getChildByTag(GameSetLayer.TAG_MUSIC_OPEN):setVisible(false)
        self:getChildByTag(GameSetLayer.TAG_MUSIC_CLOSE):setVisible(true)
    end
    
    if GlobalUserItem.nSound == 100 then
        self:getChildByTag(GameSetLayer.TAG_SOUND_OPEN):setVisible(true)
        self:getChildByTag(GameSetLayer.TAG_SOUND_CLOSE):setVisible(false)
    else
        self:getChildByTag(GameSetLayer.TAG_SOUND_OPEN):setVisible(false)
        self:getChildByTag(GameSetLayer.TAG_SOUND_CLOSE):setVisible(true)
    end
end

--取消消失
function GameSetLayer:onClose()
	self._isDiss = true
	self:stopAllActions()
	self:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,cc.p(0,appdf.HEIGHT)),cc.RemoveSelf:create()))	
end
function GameSetLayer:onShow()
    ExternalFun.showLayer(self, self,true,true)
end
return GameSetLayer
