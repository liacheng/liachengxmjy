--
-- Author: HJL
-- Date: 2017-10-17 10:51:42
--
local cmd = appdf.req(appdf.GAME_SRC.."yule.dzshowhand.src.models.CMD_Game")
local SetLayer = class("SetLayer", function(scene)
	local setLayer = display.newLayer()
	return setLayer
end)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local MUSIC_SWITCH_ON   = 1
local MUSIC_SWITCH_OFF  = 2
local EFFECT_SWITCH_ON   = 3
local EFFECT_SWITCH_OFF  = 4

function SetLayer:onInitData()
end

function SetLayer:onResetData()
end

function SetLayer:ctor(scene)
	self._scene = scene
	self:onInitData()

	self.colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 125))
		:setContentSize(display.width, display.height)
		:addTo(self)
	local this = self
	self.colorLayer:registerScriptTouchHandler(function(eventType, x, y)
		return this:onClickCallback(eventType, x, y)
	end)

        -- 按钮回调
    local btcallback = function(ref, type)
        if type == ccui.TouchEventType.began then
            ExternalFun.popupTouchFilter(1, false)
        elseif type == ccui.TouchEventType.canceled then
            ExternalFun.dismissTouchFilter()
        elseif type == ccui.TouchEventType.ended then
            ExternalFun.dismissTouchFilter()
            self:OnButtonClickedEvent(ref:getTag(), ref)
        end
    end
	self._csbNode = cc.CSLoader:createNode(cmd.RES.."GameSetLayer/GameSetLayer.csb")
		:addTo(self, 1)
    self.sp_layerBg = self._csbNode:getChildByName("setBg")
	self.sp_music_ON = self.sp_layerBg:getChildByName("music_open")
    self.sp_music_ON:setTag(MUSIC_SWITCH_ON)
    self.sp_music_ON:addTouchEventListener(btcallback)

    self.sp_music_OFF = self.sp_layerBg:getChildByName("music_close")
    self.sp_music_OFF:setTag(MUSIC_SWITCH_OFF)
    self.sp_music_OFF:addTouchEventListener(btcallback)

	self.sp_effect_ON = self.sp_layerBg:getChildByName("effect_open")
    self.sp_effect_ON:setTag(EFFECT_SWITCH_ON)
    self.sp_effect_ON:addTouchEventListener(btcallback)

    self.sp_effect_OFF = self.sp_layerBg:getChildByName("effect_close")
    self.sp_effect_OFF:setTag(EFFECT_SWITCH_OFF)
    self.sp_effect_OFF:addTouchEventListener(btcallback)

	local btnClose = self.sp_layerBg:getChildByName("Btn_Close")
	btnClose:addClickEventListener(function()
		this:hideLayer()
	end)

    --更新声音
	self:updateMusic()  
	self:updateEffect()

	self:setVisible(false)
end

function SetLayer:onClickCallback(eventType, x, y)
	print(eventType)
	if eventType == "began" then
		return true
	end

	local pos = cc.p(x, y)
   -- local rectMusic = self.sp_music_ON:getBoundingBox()
   -- local rectEffect = self.sp_effect_ON:getBoundingBox()
    local rectLayerBg = self.sp_layerBg:getBoundingBox()
   -- if cc.rectContainsPoint(rectMusic, pos) then
--        local volume = GlobalUserItem.nMusic
--        volume = math.abs(volume - 100)
--        GlobalUserItem.setMusicVolume(volume)
--    	self:updateMusic()  
--    elseif cc.rectContainsPoint(rectEffect, pos) then
--		
--        local volume = GlobalUserItem.nSound
--        volume = math.abs(volume - 100)
--        GlobalUserItem.setSoundVolume(volume)
--    	self:updateEffect()
    --elseif not cc.rectContainsPoint(rectLayerBg, pos) then
    if not cc.rectContainsPoint(rectLayerBg, pos) then
    	self:hideLayer()
    end

    return true
end

function SetLayer:OnButtonClickedEvent(tag, ref)
    if tag == MUSIC_SWITCH_ON  or tag == MUSIC_SWITCH_OFF then
        local volume = GlobalUserItem.nMusic
        volume = math.abs(volume - 100)
        GlobalUserItem.setMusicVolume(volume)
        self:updateMusic()
    elseif tag == EFFECT_SWITCH_ON or  tag == EFFECT_SWITCH_OFF then
        local volume = GlobalUserItem.nSound
        volume = math.abs(volume - 100)
        GlobalUserItem.setSoundVolume(volume)
        self:updateEffect()
    end
end

function SetLayer:showLayer()
	self.colorLayer:setTouchEnabled(true)
	self:setVisible(true)
end

function SetLayer:hideLayer()
	self.colorLayer:setTouchEnabled(false)
	self:setVisible(false)
	self:onResetData()
end

function SetLayer:updateMusic()
	if GlobalUserItem.nMusic == 100 then
        self.sp_music_ON:setVisible(true)
        self.sp_music_OFF:setVisible(false)
	else
        self.sp_music_ON:setVisible(false)
        self.sp_music_OFF:setVisible(true)
	end
end

function SetLayer:updateEffect()
	if GlobalUserItem.nSound == 100 then
        self.sp_effect_ON:setVisible(true)
        self.sp_effect_OFF:setVisible(false)
	else
        self.sp_effect_ON:setVisible(false)
        self.sp_effect_OFF:setVisible(true)
	end
end

return SetLayer