--
-- Author: zhong
-- Date: 2016-07-08 17:16:26
--
--设置界面
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local SettingLayer = class("SettingLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
SettingLayer.TAG_BACKGROUND  =  0   
SettingLayer.TAG_MUSIC_OPEN  =  1   
SettingLayer.TAG_MUSIC_CLOSE =  2
SettingLayer.TAG_SOUND_OPEN  =  3
SettingLayer.TAG_SOUND_CLOSE =  4
SettingLayer.TAG_CLOSE       =  5

-- 进入场景而且过渡动画结束时候触发。
function SettingLayer:onEnterTransitionFinish()
    return self
end

-- 退出场景而且开始过渡动画时候触发。
function SettingLayer:onExitTransitionStart()
	self:unregisterScriptTouchHandler()
    return self
end

--窗外触碰
function SettingLayer:setCanTouchOutside(canTouchOutside)
	self._canTouchOutside = canTouchOutside
end

function SettingLayer:ctor(version)
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
        if ref:getTag() == SettingLayer.TAG_CLOSE then
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
    rootLayer, self._setLayer = ExternalFun.loadRootCSB("SettingLayer.csb", self)
    self.setBg = self._setLayer:getChildByName("sp_setLayer_bg")
        
    -- 音乐按钮-开
    -- 音乐按钮-关
    -- 音乐文字
	ccui.Button:create("28gang_btn_set_open.png","28gang_btn_set_open.png","28gang_btn_set_open.png",UI_TEX_TYPE_PLIST)
        :move(575, 394)
        :setTag(SettingLayer.TAG_MUSIC_OPEN)
        :addTo(self)
        :addTouchEventListener(onBtnCallBack)

	ccui.Button:create("28gang_btn_set_close.png","28gang_btn_set_close.png","28gang_btn_set_close.png",UI_TEX_TYPE_PLIST)
        :move(575, 394)
        :setTag(SettingLayer.TAG_MUSIC_CLOSE)
        :addTo(self)
        :addTouchEventListener(onBtnCallBack)
        

    -- 音效按钮-开
    -- 音效按钮-关
    -- 音效文字
	ccui.Button:create("28gang_btn_set_open.png","28gang_btn_set_open.png","28gang_btn_set_open.png",UI_TEX_TYPE_PLIST)
        :move(845, 394)
        :setTag(SettingLayer.TAG_SOUND_OPEN)
        :addTo(self)
        :addTouchEventListener(onBtnCallBack)

	ccui.Button:create("28gang_btn_set_close.png","28gang_btn_set_close.png","28gang_btn_set_close.png",UI_TEX_TYPE_PLIST)
        :move(845, 394)
        :setTag(SettingLayer.TAG_SOUND_CLOSE)
        :addTo(self)
        :addTouchEventListener(onBtnCallBack)
     

    -- 关闭按钮
    ccui.Button:create("28gang_btn_wnd_close.png","28gang_btn_wnd_close.png","28gang_btn_wnd_close.png",UI_TEX_TYPE_PLIST)
        :move(939, 532)
        :setTag(SettingLayer.TAG_CLOSE)
        :addTo(self)
        :addTouchEventListener(onBtnCallBack)
        
    --版本号
    local verstr = "当前版本: ver " .. appdf.BASE_C_VERSION .. "." .. version
    -- 文字
    ccui.Text:create(verstr, "fonts/round_body.ttf", 25)
		:setTextColor(cc.c4b(122,61,21,255))
		:setAnchorPoint(cc.p(1, 0.5))
		:move(917, 253)
		:addTo(self)
    ExternalFun.showLayer(self, self,true,true,self.setBg,false)
    self:updateBtnState()
end

--按键点击
function SettingLayer:onButtonClickedEvent(tag, ref)
	if self._isDiss == true then
		return
	end

    if tag == SettingLayer.TAG_CLOSE then
        ExternalFun.hideLayer(self, self, false)
    elseif tag == SettingLayer.TAG_MUSIC_OPEN then
        GlobalUserItem.nMusic = 0
		GlobalUserItem.setMusicVolume(0)
    elseif tag == SettingLayer.TAG_MUSIC_CLOSE then
        GlobalUserItem.nMusic = 100
		GlobalUserItem.setMusicVolume(100)
    elseif tag == SettingLayer.TAG_SOUND_OPEN then
        GlobalUserItem.nSound = 0
		GlobalUserItem.setSoundVolume(0)
    elseif tag == SettingLayer.TAG_SOUND_CLOSE then
        GlobalUserItem.nSound = 100
		GlobalUserItem.setSoundVolume(100)
    end
    self:updateBtnState()
end

function SettingLayer:updateBtnState()
    -- 检测当前音乐音效是否开启
    if GlobalUserItem.nMusic == 100 then
        self:getChildByTag(SettingLayer.TAG_MUSIC_OPEN):setVisible(true)
        self:getChildByTag(SettingLayer.TAG_MUSIC_CLOSE):setVisible(false)
    else
        self:getChildByTag(SettingLayer.TAG_MUSIC_OPEN):setVisible(false)
        self:getChildByTag(SettingLayer.TAG_MUSIC_CLOSE):setVisible(true)
    end
    
    if GlobalUserItem.nSound == 100 then
        self:getChildByTag(SettingLayer.TAG_SOUND_OPEN):setVisible(true)
        self:getChildByTag(SettingLayer.TAG_SOUND_CLOSE):setVisible(false)
    else
        self:getChildByTag(SettingLayer.TAG_SOUND_OPEN):setVisible(false)
        self:getChildByTag(SettingLayer.TAG_SOUND_CLOSE):setVisible(true)
    end
end

--取消消失
function SettingLayer:onClose()
	self._isDiss = true
	self:stopAllActions()
	self:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,cc.p(0,appdf.HEIGHT)),cc.RemoveSelf:create()))	
end
function SettingLayer:onShow()
    ExternalFun.showLayer(self, self,true,true)
end
return SettingLayer