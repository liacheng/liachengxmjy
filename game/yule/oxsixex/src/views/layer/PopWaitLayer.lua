--[[
    防作弊房
    配置桌子等待界面
]]
local PopWaitLayer = class("PopWaitLayer", function(szTips, callfun)
    local PopWaitLayer = display.newLayer()
    return PopWaitLayer
end)

PopWaitLayer.TAG_BACKGROUND  =  0  
PopWaitLayer.TAG_CLOSE       =  5

-- 进入场景而且过渡动画结束时候触发。
function PopWaitLayer:onEnterTransitionFinish()
    return self
end

-- 退出场景而且开始过渡动画时候触发。
function PopWaitLayer:onExitTransitionStart()
	self:unregisterScriptTouchHandler()
    return self
end

--窗外触碰
function PopWaitLayer:setCanTouchOutside(canTouchOutside)
	self._canTouchOutside = canTouchOutside
end

function PopWaitLayer:ctor(szTips, callfun)
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
        if type == ccui.TouchEventType.ended then
         	self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end
        
	self._isDiss  = false
	self._canTouchOutside = true
	self:setContentSize(appdf.WIDTH,appdf.HEIGHT)
	self:setTouchEnabled(true)
    self.m_maskPopWait = nil

	szTips = szTips or ""
	-- 屏蔽层
	local mask = ccui.Layout:create()
	mask:setTouchEnabled(true)
	mask:setContentSize(appdf.WIDTH, appdf.HEIGHT)
    mask:setTag(PopWaitLayer.TAG_BACKGROUND)
	self:addChild(mask, yl.MAX_INT)
	self.m_maskPopWait = mask

	local bg = display.newSprite("query_bg.png")
		:move(appdf.WIDTH/2,appdf.HEIGHT/2)
		:addTo(mask)
        :setTag(PopWaitLayer.TAG_BACKGROUND)
	cc.Label:createWithTTF(szTips, "fonts/round_body.ttf", 32)
		:setTextColor(cc.c4b(255,255,255,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:setDimensions(600, 180)
		:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:move(appdf.WIDTH/2 ,375 )
		:addTo(mask)
        :setTag(PopWaitLayer.TAG_BACKGROUND)

	-- 取消按钮
--	local btn = ccui.Button:create("bt_query_cancel_0.png","bt_query_cancel_1.png")
--	btn:addTo(mask)
--	btn:move(appdf.WIDTH/2 , 200 )
--    btn:setTag(PopWaitLayer.TAG_CLOSE)
--	btn:addTouchEventListener(function(ref, tType)
--        if tType == ccui.TouchEventType.ended then
--         	self.m_maskPopWait:removeFromParent()
--			self.m_maskPopWait = nil
--         	if type(callfun) == "function" then
--         		callfun()
--         	end
--        end
--    end)
end

--按键点击
function PopWaitLayer:onButtonClickedEvent(tag, ref)
	if self._isDiss == true then
		return
    end

   if tag == PopWaitLayer.TAG_CLOSE then
	    self:onClose()  --取消显示
   end       
end

--取消消失
function PopWaitLayer:onClose()
	self._isDiss = true
	self:stopAllActions()
	self:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,cc.p(0,appdf.HEIGHT)),cc.RemoveSelf:create()))	
end

return PopWaitLayer

