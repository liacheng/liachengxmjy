local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local module_pre = "game.yule.sharkbattle.src"
local PopupWithCloseBtnLayer = appdf.req(module_pre .. ".views.layer.PopupWithCloseBtnLayer")


local SettingLayer = class("SettingLayer",PopupWithCloseBtnLayer)

SettingLayer.CBT_SILENCE 	= 1
SettingLayer.CBT_SOUND   	= 2

function SettingLayer:ctor(popBgFile)
 	SettingLayer.super.ctor(self,popBgFile)

 	local cbtlistener = function (sender,eventType)
    	self:onSelectedEvent(sender:getTag(),sender,eventType)
    end

 	self.effectAudio = ccui.CheckBox:create("soundoff.png","","soundon.png","","")
		:move(730,415)
		:setSelected(GlobalUserItem.nSound == 100)
		:addTo(self)
		:setTag(self.CBT_SOUND)
	self.effectAudio:addEventListener(cbtlistener)

	self.bgAudio = ccui.CheckBox:create("soundoff.png","","soundon.png","","")
		:move(730,305)
		:setSelected(GlobalUserItem.nMusic == 100)
		:addTo(self)
		:setTag(self.CBT_SILENCE)
	self.bgAudio:addEventListener(cbtlistener)

end


function SettingLayer:onSelectedEvent(tag,sender,eventType)
    local volume = 0
    if eventType == 0 then
        volume = 100
    end
	if tag == SettingLayer.CBT_SILENCE then
        GlobalUserItem.setMusicVolume(volume)
	elseif tag == SettingLayer.CBT_SOUND then
        GlobalUserItem.setSoundVolume(volume)
	end
end

return SettingLayer