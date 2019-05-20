--
-- Author: luo
-- Date: 2016年12月30日 15:18:32
--
--设置界面
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local SettingLayer = class("SettingLayer", cc.Layer)

SettingLayer.BT_EFFECT = 1
SettingLayer.BT_MUSIC  = 2
SettingLayer.BT_CLOSE  = 3
SettingLayer.BT_RULE   = 4
--构造
function SettingLayer:ctor( verstr )
    --加载csb资源
    self._csbNode = ExternalFun.loadCSB("set_res/GameSetLayer.csb", self)
    --回调方法
    local cbtlistener = function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            ExternalFun.playClickEffect()
            self:OnButtonClickedEvent(sender:getTag(),sender)
        end
    end
    --背景
    local sp_bg = self._csbNode:getChildByName("set_bg")

    ExternalFun.showLayer(self, self, true, true,sp_bg,false)
    --关闭按钮
    local btn = self._csbNode:getChildByName("btn_close")
    btn:setTag(SettingLayer.BT_CLOSE)
    btn:addTouchEventListener(function (ref, eventType)
        if eventType == ccui.TouchEventType.ended then
            ExternalFun.playClickEffect()
            ExternalFun.hideLayer(self, self,false)
        end
    end)

    --音效
    self.m_btnEffect = self._csbNode:getChildByName("btn_sound")
    self.m_btnEffect:setTag(SettingLayer.BT_EFFECT)
    self.m_btnEffect:addTouchEventListener(cbtlistener)

    --音乐
    self.m_btnMusic = self._csbNode:getChildByName("btn_music")
    self.m_btnMusic:setTag(SettingLayer.BT_MUSIC)
    self.m_btnMusic:addTouchEventListener(cbtlistener)
    --按钮纹理
    if GlobalUserItem.nMusic == 100 then 
        self.m_btnMusic:loadTextureNormal("set_res/anniu3.png")
    else
        self.m_btnMusic:loadTextureNormal("set_res/anniu4.png")
    end
    if GlobalUserItem.nSound == 100 then 
        self.m_btnEffect:loadTextureNormal("set_res/anniu3.png")
    else
        self.m_btnEffect:loadTextureNormal("set_res/anniu4.png")
    end

    --玩法
    self.m_btnRule = self._csbNode:getChildByName("btn_rule")
    self.m_btnRule:setTag(SettingLayer.BT_RULE)
    self.m_btnRule:addTouchEventListener(cbtlistener)

    --版本号
    self.m_TextVer = self._csbNode:getChildByName("text_version")
    self.m_TextVer:setFontName("fonts/round_body.ttf")
    self.m_TextVer:setString(verstr)


end

--
function SettingLayer:showLayer( var )
    self:setVisible(var)
end
--按钮回调方法
function SettingLayer:OnButtonClickedEvent( tag, sender )
    if SettingLayer.BT_MUSIC == tag then    --音乐
        local volume = GlobalUserItem.nMusic
        volume = math.abs(volume - 100)
        GlobalUserItem.setMusicVolume(volume)
        if GlobalUserItem.nMusic == 100 then 
            self:getParent():playBackGroundMusic(self:getParent().m_cbGameStatus)
            sender:loadTextureNormal("set_res/anniu3.png")
        else
            sender:loadTextureNormal("set_res/anniu4.png")
        end
    elseif SettingLayer.BT_EFFECT == tag then   --音效
        local volume = GlobalUserItem.nSound
        volume = math.abs(volume - 100)
        GlobalUserItem.setSoundVolume(volume)
        if GlobalUserItem.nSound == 100 then 
            sender:loadTextureNormal("set_res/anniu3.png")
        else
            sender:loadTextureNormal("set_res/anniu4.png")
        end
    elseif SettingLayer.BT_RULE == tag then   --音效
        --self:getParent()._scene._scene:popHelpLayer2(140, 0)
        self:getParent():popHelpLayer()
    end
end
function SettingLayer:onShow()
    ExternalFun.showLayer(self, self, true, true)
end
return SettingLayer