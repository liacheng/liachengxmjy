--
-- Author: luo
-- Date: 2016年12月26日 20:24:43
--
local HelpLayer = class("HelpLayer", cc.Layer)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

HelpLayer.TAG_NEXT_PAGE  = 1
HelpLayer.TAG_LAST_PAGE  = 2
HelpLayer.TAG_CLOSE      = 3

function HelpLayer:ctor( )
    local onBtnCallBack = function(ref, type)
        ExternalFun.btnEffect(ref, type)
        if type == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    self.m_pNode = cc.CSLoader:createNode("game/GameRuleLayer.csb")
    self.m_pNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_pNode:setPosition(cc.p(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2))
	self:addChild(self.m_pNode)

    self.m_pBtnNextPage = self.m_pNode:getChildByName("m_pBtnNext")
    self.m_pBtnLastPage = self.m_pNode:getChildByName("m_pBtnLast")
    self.m_pBtnClose = self.m_pNode:getChildByName("m_pBtnClose")

    self.m_pBtnNextPage:setTag(HelpLayer.TAG_NEXT_PAGE)
    self.m_pBtnLastPage:setTag(HelpLayer.TAG_LAST_PAGE)
    self.m_pBtnClose:setTag(HelpLayer.TAG_CLOSE)

    self.m_pBtnNextPage:addTouchEventListener(onBtnCallBack)
    self.m_pBtnLastPage:addTouchEventListener(onBtnCallBack)
    self.m_pBtnClose:addTouchEventListener(onBtnCallBack)

    self.m_iCurPage = 1
    self.m_iMaxPage = 4
    self.m_bIsCanTouch = true

    self.m_pTextPage = self.m_pNode:getChildByName("m_pTextPage")
    self.m_pTextPage:setFontName("fonts/round_body.ttf")
    self.m_pTextPage:setString(string.format("%d/%d", self.m_iCurPage, self.m_iMaxPage))

    self.m_pNodeRule = self.m_pNode:getChildByName("m_pNodeClip"):getChildByName("m_pNodeRule")
    self.m_pBtnNextPage:setVisible(self.m_iCurPage ~= self.m_iMaxPage)
    self.m_pBtnLastPage:setVisible(self.m_iCurPage ~= 1)
    ExternalFun.showLayer(self, self.m_pNode, true, true)
end

--按键点击
function HelpLayer:onButtonClickedEvent(tag, ref)
	if self.isDiss == true then
		return
	end

    if tag == HelpLayer.TAG_CLOSE then
        ExternalFun.playClickEffect()
        ExternalFun.hideLayer(self, self.m_pNode, false)
    elseif tag == HelpLayer.TAG_NEXT_PAGE then
        if self.m_bIsCanTouch then
            if self.m_iCurPage < self.m_iMaxPage then
                self.m_iCurPage = self.m_iCurPage + 1
            end
            self:updatePage()
        end
    elseif tag == HelpLayer.TAG_LAST_PAGE then
        if self.m_bIsCanTouch then
            if self.m_iCurPage > 1 then
                self.m_iCurPage = self.m_iCurPage - 1
            end
            self:updatePage()
        end
    end
end

function HelpLayer:updatePage()
    self.m_bIsCanTouch = false
    self.m_pBtnNextPage:setVisible(self.m_iCurPage ~= self.m_iMaxPage)
    self.m_pBtnLastPage:setVisible(self.m_iCurPage ~= 1)
    self.m_pTextPage:setString(string.format("%d/%d", self.m_iCurPage, self.m_iMaxPage))
    
    self.m_pNodeRule:runAction(
        cc.Sequence:create(
            cc.MoveTo:create(0.5, cc.p(0-(self.m_iCurPage-1)*928, self.m_pNodeRule:getPositionY())), 
            cc.CallFunc:create(function()
                self.m_bIsCanTouch = true
            end)
        )
    )
end

function HelpLayer:onShow()
    ExternalFun.showLayer(self, self.m_pNode, true, true)
    
    self.m_iCurPage = 1
    self.m_pBtnNextPage:setVisible(self.m_iCurPage ~= self.m_iMaxPage)
    self.m_pBtnLastPage:setVisible(self.m_iCurPage ~= 1)
    self.m_pTextPage:setString(string.format("%d/%d", self.m_iCurPage, self.m_iMaxPage))
    self.m_pNodeRule:setPosition(cc.p(0, 0))
end

return HelpLayer