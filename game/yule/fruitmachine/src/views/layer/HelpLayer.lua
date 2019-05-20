
local HelpLayer = class("HelpLayer", cc.Layer)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

HelpLayer.RES_PATH = "game/yule/fruitmachine/res/"

HelpLayer.BT_HOME = 1

function HelpLayer:ctor( )
    --注册触摸事件
    ExternalFun.registerTouchEvent(self, true)

    self.m_rootLayer,self._csbNode = ExternalFun.loadRootCSB(HelpLayer.RES_PATH .."HelpScene.csb", self);

	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			local tag = sender:getTag()
			if HelpLayer.BT_HOME == tag then
				ExternalFun.playClickEffect()
				self:removeFromParent()
			end
		end
	end


    local panel = self._csbNode:getChildByName("Panel_1")
    self.btnExit = panel:getChildByName("Button_exit")
                   :setTag(HelpLayer.BT_HOME)
	self.btnExit:addTouchEventListener(btnEvent)

end

function HelpLayer:onTouchBegan( touch, event )
	return self:isVisible()
end

return HelpLayer