--
-- Author: zhong
-- Date: 2016-06-28 16:40:04
--
--庄家申请列表
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local ApplyListItem = appdf.req(appdf.GAME_SRC.."yule.redblackbattle.src.views.layer.ApplyListItem")

local ApplyListLayer = class("ApplyListLayer", cc.Layer)
local PopupInfoHead = appdf.req(appdf.CLIENT_SRC.."external.PopupInfoHead")
ApplyListLayer.BT_HIDE = 1
ApplyListLayer.BT_CLOSE = 1
ApplyListLayer.BT_APPLY = 2

function ApplyListLayer:ctor( viewParent)
    --注册事件
	ExternalFun.registerNodeEvent(self) -- bind node event
	self.m_parent = viewParent

	--用户列表
	self.m_userlist = {}

	--加载csb资源
	local csbNode = ExternalFun.loadCSB("ApplyListLayer.csb", self)

	self.m_pIconBg = csbNode:getChildByName("m_pIconBG")
    self.m_pScrollView = self.m_pIconBg:getChildByName("m_pScrollView")
    self.m_pBtnClose = self.m_pIconBg:getChildByName("m_pBtnClose")
    self.m_pScrollView:setScrollBarEnabled( false )    -- 隐藏滚动条
    self.innerHeight = self.m_pScrollView:getInnerContainerSize().height  -- 计算滚动容器的宽

    --提示
    self.clipText = ccui.Text:create("", appdf.FONT_FILE, 35)
    self.clipText:setAnchorPoint(0.5,0.5)
    self.clipText:setPosition(self.m_pIconBg:getContentSize().width/2,self.m_pIconBg:getContentSize().height/2)
    self.clipText:addTo(self.m_pIconBg)

    local function btnClick(sender, eventType)
        ExternalFun.btnEffect(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender);
        end
    end

    self.m_pBtnClose:setTag(ApplyListLayer.BT_HIDE)
    self.m_pBtnClose:addTouchEventListener(btnClick)
    ExternalFun.showLayer(self, self,true,true,self.m_pIconBg,false)
end

function ApplyListLayer:refreshList(userlist)
    self.m_pScrollView:removeAllChildren()
	self.m_userlist = userlist
    self:reload()
end

function ApplyListLayer:reload()
    local innerWidth = self.m_pScrollView:getInnerContainerSize().width
    local gapX = 160                        -- 单元X间隔
    local gapY = 185                      -- 单元Y间隔
    local addCount = 0                      -- 加多少行
    if #self.m_userlist > 6 then             -- 如果超过最大显示6个则计算需要增加多少行
        local surplusCount = #self.m_userlist - 6 - 1    
        addCount = math.floor(surplusCount / 4) + 1
    end
    self.m_pScrollView:setInnerContainerSize(cc.size(innerWidth, self.innerHeight+addCount*gapY))     -- 设置滚动容器的宽高
    local startPosX = 90                                                                       -- 计算X起始点
    local startPosY = self.m_pScrollView:getInnerContainerSize().height - 90                    -- 计算Y起始点
    if #self.m_userlist == 0 then 
        self.clipText:setString("目前还无人上庄！")
    end
    local count = #self.m_userlist

    for i = count,1,-1 do
        local useritem = self.m_userlist[i].m_userItem
        if nil ~= useritem then
            self.clipText:setString("")
		    self:refresh(useritem,cc.p(startPosX + math.floor(((count-i)%4)) * gapX, startPosY - math.floor(((count-i)/4)) * gapY),i)
	    end
    end
end

function ApplyListLayer:refreshBtnState(  )
	if nil == self.m_parent or nil == self.m_parent.getApplyState then
		ExternalFun.enableBtn(self.m_btnApply, false)
		return
	end

	--获取当前申请状态
	local state = self.m_parent:getApplyState()
	if state == self.m_parent._apply_state.kApplyedState then
		--已申请状态，下庄限制
		ExternalFun.enableBtn(self.m_btnApply, self.m_parent:getCancelable())
	end
end

function ApplyListLayer:onButtonClickedEvent( tag, sender )
	ExternalFun.playClickEffect()
    if ApplyListLayer.BT_HIDE == tag then        	
		ExternalFun.hideLayer(self, self, false)   
	end
end

function ApplyListLayer:onApplyClickedEvent( tag,sender )
	ExternalFun.playClickEffect()
	if nil ~= self.m_parent then
		self.m_parent:applyBanker(tag)
	end
end

function ApplyListLayer:onExit()
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:removeEventListener(self.listener)
end

function ApplyListLayer:onEnterTransitionFinish()
	self:registerTouch()
end

function ApplyListLayer:registerTouch()
	local function onTouchBegan( touch, event )
		return self:isVisible()
	end

	local function onTouchEnded( touch, event )
		local pos = touch:getLocation();
        pos = self.m_pIconBg:convertToNodeSpace(pos)
        local rec = cc.rect(0, 0, self.m_pIconBg:getContentSize().width, self.m_pIconBg:getContentSize().height)
        if false == cc.rectContainsPoint(rec, pos) then
        end        
	end

	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(false)
	self.listener = listener;
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN );
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED );
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function ApplyListLayer:refresh(useritem, pos,rank)
	if nil == useritem then
		return
	end
    local sprite = display.newSprite("#userinfo_head_frame.png")
    sprite:setPosition(pos)
    sprite:setScale(0.55)
    self.m_pScrollView:addChild(sprite)
	local head = PopupInfoHead:createNormal(useritem, 90)
    head:setPosition(pos)
	self.m_pScrollView:addChild(head)
    --head:enableInfoPop(true, cc.p(45,45), cc.p(0.5,0.5))

    --坐庄排次
--    local szRank = string.format("( %d )", rank)
--    local textSortBanker = ccui.Text:create(szRank, appdf.FONT_FILE, 25)
--    textSortBanker:setColor(cc.c3b(120, 255, 0))
--    textSortBanker:setAnchorPoint(cc.p(0.5,0.5))
--    textSortBanker:setPosition(0,60)
--    head:addChild(textSortBanker)

	--更新昵称
	local szNick = ""
	if nil ~= useritem.szNickName then
		szNick = useritem.szNickName
	end
	local clipText = ccui.Text:create(ExternalFun.GetShortName(szNick,10,8), appdf.FONT_FILE, 24)
    clipText:setAnchorPoint(cc.p(0.5,0.5))
    clipText:setColor(cc.c3b(94, 58, 29))
    clipText:setPosition(0,63)
    head:addChild(clipText)

	--更新金币
	local coin = 0
	if nil ~= useritem.lScore then
		coin = useritem.lScore
	end
--	local str = ExternalFun.numberThousands(coin)
--	if string.len(str) > 11 then
--		str = string.sub(str, 1, 7) .. "..."
--	end
	local textCoin = ccui.Text:create(ExternalFun.formatScoreText(coin), appdf.FONT_FILE, 24)
    textCoin:setColor(cc.c3b(162, 32, 23))
    textCoin:setAnchorPoint(cc.p(0.5,0.5))
    textCoin:setPosition(0,-62)
    head:addChild(textCoin)
end

function ApplyListLayer:onClose()
	--self._isDiss = true
	self:stopAllActions()
	self:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,cc.p(0,appdf.HEIGHT)),cc.RemoveSelf:create()))	
end

function ApplyListLayer:onShow()
    ExternalFun.showLayer(self, self,true,true)
end
return ApplyListLayer