-- Author: cjm
-- Date: 2018-07-10

--玩家列表
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local GoldRuleLayer = class("GoldRuleLayer", cc.Layer)
local PopupInfoHead = appdf.req(appdf.CLIENT_SRC.."external.PopupInfoHead")
local g_var = ExternalFun.req_var
function GoldRuleLayer:ctor()
	--加载csb资源
	local csbNode = ExternalFun.loadCSB("GoldRuleLayer.csb", self)
    local callBack = function(sender, eventType) 
                                ExternalFun.btnEffect(sender, eventType)
                                ExternalFun.hideLayer(self, self,false) end
	local m_pIconBg = csbNode:getChildByName("m_pIconBG")   
    self.m_pBtnClose = m_pIconBg:getChildByName("m_pBtnClose")
    self.m_pTxtGoldRule = m_pIconBg:getChildByName("txt_goldrule")
    self.m_pTxtGoldRule:setFontName(appdf.FONT_FILE)
    self.m_pBtnClose:addClickEventListener(callBack)
    ExternalFun.showLayer(self, self, true, true,m_pIconBg,false)
end
function GoldRuleLayer:onShow()
    ExternalFun.showLayer(self, self, true, true)
end
return GoldRuleLayer