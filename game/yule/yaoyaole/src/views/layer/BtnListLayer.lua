--
-- Author: zhong
-- Date: 2016-07-07 18:09:11
--
--玩家列表
local module_pre = "game.yule.yaoyaole.src"

local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var;

local BtnListLayer = class("BtnListLayer", cc.Layer)

BtnListLayer.BT_EXIT = 100
BtnListLayer.BT_RULE = 104
BtnListLayer.BT_BANK = 102
BtnListLayer.BT_USERLIST = 108
BtnListLayer.BT_SET = 103
function BtnListLayer:ctor(scene)

	self.superParent = nil
	--注册事件
	ExternalFun.registerNodeEvent(self) -- bind node event

	--加载csb资源
	local csbNode = ExternalFun.loadCSB("game/yyl_btnList.csb", self)
	csbNode:setPosition(85,676)
	local sp_bg = csbNode:getChildByName("Sprite_ListBtn")
	self.m_spBg = sp_bg
	self.m_spBg:setScale(0)
	
	local function btnEvent( sender, eventType )
        ExternalFun.btnEffect(sender, eventType)
		if eventType == ccui.TouchEventType.ended then

		    self:hideUserList()
            self:setVisible(false)
            self.superParent.m_BtnMenu:setVisible(true)
			self.superParent:onButtonClickedEvent(sender:getTag(), sender);
		end
	end
	-- local btn = sp_bg:getChildByName("Button_close")
	-- btn:setTag(BtnListLayer.BT_CLOSE)
	-- btn:addTouchEventListener(btnEvent);

	--离开
	local btn = sp_bg:getChildByName("Button_back");
	btn:setTag(BtnListLayer.BT_EXIT);
	btn:addTouchEventListener(btnEvent);

	--规则
	btn = sp_bg:getChildByName("Button_rule");
	btn:setTag(BtnListLayer.BT_RULE);
	btn:addTouchEventListener(btnEvent);

	--银行
--	btn = sp_bg:getChildByName("Button_bank");
--	btn:setTag(BtnListLayer.BT_BANK);
--	btn:addTouchEventListener(btnEvent);
--    btn:setEnabled(scene._scene._gameFrame:GetServerType()==yl.GAME_GENRE_GOLD)

	--玩家列表
--	btn = sp_bg:getChildByName("Button_playList");
--	btn:setTag(BtnListLayer.BT_USERLIST);
--	btn:addTouchEventListener(btnEvent);

	--set
	btn = sp_bg:getChildByName("Button_set");
	btn:setTag(BtnListLayer.BT_SET);
	btn:addTouchEventListener(btnEvent);

    btn = sp_bg:getChildByName("Button_quqian");
	btn:setTag(BtnListLayer.BT_BANK);
	btn:addTouchEventListener(btnEvent);


end


-- function BtnListLayer:onButtonClickedEvent( tag, sender )
-- 	ExternalFun.playClickEffect()
-- 	if BtnListLayer.BT_EXIT == tag then

-- 	elseif BtnListLayer.BT_RULE == tag then

-- 	elseif BtnListLayer.BT_BANK == tag then

-- 	elseif BtnListLayer.BT_USERLIST == tag then

-- 	end
-- end

function BtnListLayer:onExit()
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:removeEventListener(self.listener)
end

function BtnListLayer:onEnterTransitionFinish()
	self:registerTouch()
end

function BtnListLayer:registerTouch()
	local function onTouchBegan( touch, event )
		return self:isVisible()
	end

	local function onTouchEnded( touch, event )
		local pos = touch:getLocation();
		local m_spBg = self.m_spBg
        pos = m_spBg:convertToNodeSpace(pos)
        local rec = cc.rect(0, 0, m_spBg:getContentSize().width, m_spBg:getContentSize().height)
        if false == cc.rectContainsPoint(rec, pos) then            
            self:hideUserList()
        end        
	end

	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true)
	self.listener = listener;
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN );
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED );
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function BtnListLayer:hideUserList()
    if self.m_spBg:getNumberOfRunningActions() > 0 then
        return
    end
    self.m_spBg:stopAllActions()
    self.m_spBg:runAction(cc.Sequence:create(self.superParent.m_actDropOut,
                           cc.CallFunc:create(function ()
		                    self:setVisible(false)
	                    end)))
end

return BtnListLayer