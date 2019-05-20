--
-- Author: luo
-- Date: 2016年12月26日 20:24:43
--
local HelpLayer = class("HelpLayer", cc.Layer)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

HelpLayer.SP_HELP_BEGIN = 1
HelpLayer.SP_HELP_END = 4
HelpLayer.BT_HOME = 5

function HelpLayer:ctor( )
    --注册触摸事件
    ExternalFun.registerTouchEvent(self, true)

    self.byShowIdx = 1
    for i=HelpLayer.SP_HELP_BEGIN,HelpLayer.SP_HELP_END do
        local spHelp = display.newSprite(string.format("loading/preBg_0%d.png", i))
        spHelp:setTag(i)
        spHelp:setPosition(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2)
        self:addChild(spHelp)
        spHelp:setVisible(false)
    end
    self.spHelp = self:getChildByTag(self.byShowIdx)
    self.spHelp:setVisible(true)
    self.helpSize = self.spHelp:getContentSize();

    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            local tag = sender:getTag()
            if HelpLayer.BT_HOME == tag then
                ExternalFun.playClickEffect()
                self:removeFromParent()
            end
        end
    end
	
    ccui.Button:create("game1_back_1.png", "game1_back_2.png", "p_bt_close_1.png")
	:move(yl.DESIGN_WIDTH- 50, yl.DESIGN_WIDTH - 50)
	:setTag(HelpLayer.BT_HOME)
	:addTo(self)
    :addTouchEventListener(btnEvent)

    local function onTouchBegan(touch, event)    	
    	local locationInNode = self:convertToNodeSpace(touch:getLocation());
    	local rect = cc.rect(0, 0, self.helpSize.width, self.helpSize.height);
    	if cc.rectContainsPoint(rect, locationInNode) then    		
    		return true;
    	end
    	return false;
    end

    local function onTouchMoved(touch, event)    	
        local delta = touch:getDelta()  
        local deltax = delta.x
        local deltay = delta.y

    	--水平滑动
    	if deltax ~= 0 and math.abs(deltay) < 10  then
            if self.bNextSpHelp then
                return
            end
    		if deltax > 0 then --向右划动
                if self.byShowIdx > HelpLayer.SP_HELP_BEGIN then
                    self.byShowIdx = self.byShowIdx-1
                    --print("onTouchMoved right byShowIdx=" .. self.byShowIdx)
                end                     			
    		else --向左滑动              
                if self.byShowIdx < HelpLayer.SP_HELP_END then
                    self.byShowIdx = self.byShowIdx+1
                    --print("onTouchMoved left byShowIdx=" .. self.byShowIdx)
                else
                    ExternalFun.playClickEffect()
                    self:removeFromParent()
                end  
    		end
            self.bNextSpHelp = true
    	end
    end

    local function onTouchEnded(touch, event)
        --水平滑动
        self:showSpHelp()
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)

    local dispacther = cc.Director:getInstance():getEventDispatcher()
    dispacther:addEventListenerWithSceneGraphPriority(listener, self.spHelp)
end

function HelpLayer:showSpHelp()
    --print("showSpHelp byShowIdx=" .. self.byShowIdx)
    for i=HelpLayer.SP_HELP_BEGIN,HelpLayer.SP_HELP_END do
        if i == self.byShowIdx then
            self:getChildByTag(i):setVisible(true)
        else
            self:getChildByTag(i):setVisible(false)
        end
    end  
    self.bNextSpHelp = false  
end

function HelpLayer:onTouchBegan( touch, event )
	return self:isVisible()
end

return HelpLayer