local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local module_pre = "game.yule.animalbattle.src"
local cmd = appdf.req(module_pre .. ".models.CMD_Game")
local SettingLayer = class("SettingLayer", function(version)
    local SettingLayer = display.newLayer()
    return SettingLayer
end)

SettingLayer.TAG_BACKGROUND  =  0 
SettingLayer.TAG_SOUND 	= 1
SettingLayer.TAG_MUSIC   	= 2
SettingLayer.RES_PATH 				= "game/yule/animalbattle/res/"
function SettingLayer:ctor(parentNode)
	self._parentNode=parentNode
 	self.csbNode=ExternalFun.loadCSB(SettingLayer.RES_PATH.."SettingLayer.csb",self)

    self.setBg = self.csbNode:getChildByName("bg")
    self.setBg:setTag(SettingLayer.TAG_BACKGROUND)
    ExternalFun.showLayer(self, self, true, true,self.setBg,false)

    local cbtlistener = function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onSelectedEvent(sender:getTag(),sender)
        end
    end
     --音效
    self.effectAudio = self.csbNode:getChildByName("effect")
    self.effectAudio:setTag(self.TAG_SOUND)
    self.effectAudio:addTouchEventListener(cbtlistener)

    --音乐
    self.bgAudio = self.csbNode:getChildByName("music")
    self.bgAudio:setTag(self.TAG_MUSIC)
    self.bgAudio:addTouchEventListener(cbtlistener)

	appdf.getNodeByName(self.csbNode,"Button_1")
		:addClickEventListener(function() 
                                ExternalFun.playClickEffect()
                                ExternalFun.hideLayer(self, self, false) 
                                end)
    
    local mgr = self._parentNode._scene._scene:getApp():getVersionMgr(cmd.KIND_ID)
    local verstr = mgr:getResVersion() or "0"
    appdf.getNodeByName(self.csbNode,"txt_versoin")
        :setFontName("fonts/round_body.ttf")
        :setString("当前版本: ver " .. appdf.BASE_C_VERSION .. "." .. verstr)


    --按钮纹理
    if GlobalUserItem.nMusic == 100 then 
        self.bgAudio:loadTextureNormal("animalbattle_img_off.png",ccui.TextureResType.plistType)
    else
        self.bgAudio:loadTextureNormal("animalbattle_img_on.png",ccui.TextureResType.plistType)
    end
    if GlobalUserItem.nSound == 100 then 
        self.effectAudio:loadTextureNormal("animalbattle_img_off.png",ccui.TextureResType.plistType)
    else
        self.effectAudio:loadTextureNormal("animalbattle_img_on.png",ccui.TextureResType.plistType)
    end
end


function SettingLayer:onSelectedEvent(tag,sender)
	if tag == SettingLayer.TAG_MUSIC then
        local volume = GlobalUserItem.nMusic
        volume = math.abs(volume - 100)
        GlobalUserItem.setMusicVolume(volume)
        if GlobalUserItem.nMusic == 100 then 
            sender:loadTextureNormal("animalbattle_img_off.png",ccui.TextureResType.plistType)
        else
            sender:loadTextureNormal("animalbattle_img_on.png",ccui.TextureResType.plistType)
        end
	elseif tag == SettingLayer.TAG_SOUND then
        local volume = GlobalUserItem.nSound
        volume = math.abs(volume - 100)
        GlobalUserItem.setSoundVolume(volume)
        if GlobalUserItem.nSound == 100 then 
            sender:loadTextureNormal("animalbattle_img_off.png",ccui.TextureResType.plistType)
        else
            sender:loadTextureNormal("animalbattle_img_on.png",ccui.TextureResType.plistType)
        end
	end
end
function SettingLayer:onShow()
    ExternalFun.showLayer(self, self, true, true)
end
return SettingLayer