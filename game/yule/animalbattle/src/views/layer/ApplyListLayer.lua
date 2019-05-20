--
-- Author: cjm
-- Date: 2018.7.10 
--
--庄家申请列表
local module_pre = "game.yule.animalbattle.src"

local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var;
local PopupInfoHead = appdf.req(appdf.CLIENT_SRC.."external.PopupInfoHead")
local ApplyListLayer = class("ApplyListLayer", cc.Layer)
ApplyListLayer.BT_CLOSE = 1
ApplyListLayer.BT_APPLY = 2
ApplyListLayer.BT_SHOW = 3
ApplyListLayer.BT_HIDE = 4

function ApplyListLayer:ctor(viewParent)
	--注册事件
	ExternalFun.registerNodeEvent(self) -- bind node event

	--
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

    self.m_pBtnShow = csbNode:getChildByName("m_pBtnShow")
    self.m_pBtnShadeClose = self.m_pIconBg:getChildByName("Button_1")

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

    self.m_pBtnShow:setTag(ApplyListLayer.BT_SHOW)
    self.m_pBtnClose:setTag(ApplyListLayer.BT_HIDE)
    self.m_pBtnShadeClose:setTag(ApplyListLayer.BT_HIDE)
    self.m_pBtnShow:addTouchEventListener(btnClick)
    self.m_pBtnClose:addTouchEventListener(btnClick)
    self.m_pBtnShadeClose:addTouchEventListener(btnClick)
end

function ApplyListLayer:refreshList(userlist)
    self.m_pScrollView:removeAllChildren()
	self.m_userlist = userlist
    self:reload()
end

function ApplyListLayer:reload()
    local innerWidth = self.m_pScrollView:getInnerContainerSize().width
    local gapX = 200                        -- 单元X间隔
    local gapY = 235                      -- 单元Y间隔
    local addCount = 0                      -- 加多少行
    if #self.m_userlist > 8 then             -- 如果超过最大显示6个则计算需要增加多少行
        local surplusCount = #self.m_userlist - 8 - 1    
        addCount = math.floor(surplusCount / 4) + 1
    end
    self.m_pScrollView:setInnerContainerSize(cc.size(innerWidth, self.innerHeight+addCount*gapY))     -- 设置滚动容器的宽高
    local startPosX = 115                                                                      -- 计算X起始点
    local startPosY = self.m_pScrollView:getInnerContainerSize().height - 120                    -- 计算Y起始点
    if #self.m_userlist == 0 then 
        self.clipText:setString("目前还无人上庄！")
    end
    
    for i = 1, #self.m_userlist do
        local useritem = self.m_userlist[i].m_userItem
        if nil ~= useritem then
            self.clipText:setString("")
		    self:refresh(useritem,cc.p(startPosX + math.floor(((i-1)%4)) * gapX, startPosY - math.floor(((i-1)/4)) * gapY),i)
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
	if ApplyListLayer.BT_SHOW == tag then
        self.m_pIconBg:setVisible(true)
        self.m_pBtnShow:setVisible(false)
        self.m_pScrollView:removeAllChildren()
        self:reload()
    elseif ApplyListLayer.BT_HIDE == tag then
        self.m_pIconBg:setVisible(false)
        self.m_pBtnShow:setVisible(true)
        self.m_pScrollView:removeAllChildren()
        self:reload()
	end
end

function ApplyListLayer:onApplyClickedEvent( tag,sender )
	ExternalFun.playClickEffect()
	if nil ~= self.m_parent then
		self.m_parent:applyBanker(tag)
	end
end

function ApplyListLayer:refresh(useritem, pos)
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

	--更新昵称
	local szNick = ""
	if nil ~= useritem.szNickName then
		szNick = useritem.szNickName
	end
	local clipText = ccui.Text:create(szNick, appdf.FONT_FILE, 25)
    clipText:setAnchorPoint(cc.p(0.5,0.5))
    clipText:setColor(cc.c3b(163, 238, 161))
    clipText:setPosition(0,60)
    head:addChild(clipText)

	--更新金币
	local coin = 0
	if nil ~= useritem.lScore then
		coin = useritem.lScore
	end

	local textCoin = ccui.Text:create(ExternalFun.formatScoreText(coin), appdf.FONT_FILE, 25)
    textCoin:setColor(cc.c3b(255, 228, 0))
    textCoin:setAnchorPoint(cc.p(0.5,0.5))
    textCoin:setPosition(0,-63)
    head:addChild(textCoin)
end

return ApplyListLayer