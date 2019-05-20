-- Author: cjm
-- Date: 2018-07-10

--玩家列表
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local UserListLayer = class("UserListLayer", cc.Layer)
local PopupInfoHead = appdf.req(appdf.CLIENT_SRC.."external.PopupInfoHead")
local g_var = ExternalFun.req_var
function UserListLayer:ctor()
	--注册事件
	ExternalFun.registerNodeEvent(self) -- bind node event

	--用户列表
	self.m_userlist = {}

	--加载csb资源
	local csbNode = ExternalFun.loadCSB("UserListLayer.csb", self)

	local m_pIconBg = csbNode:getChildByName("m_pIconBG")
    self.m_pScrollView = m_pIconBg:getChildByName("m_pScrollView")
    self.m_pBtnClose = m_pIconBg:getChildByName("m_pBtnClose")
    self.m_pBtnClose:addClickEventListener(function(sender, eventType) 
        ExternalFun.hideLayer(self, self, false)
    end)
    self.m_pScrollView:setScrollBarEnabled( false )    -- 隐藏滚动条
end

function UserListLayer:show()
    ExternalFun.showLayer(self, self)
end

function UserListLayer:refreshList( userlist )
    self.m_pScrollView:removeAllChildren()
	self:setVisible(true)
	self.m_userlist = userlist
    self:reloadData()
end

function UserListLayer:reloadData()
    local innerHeight = self.m_pScrollView:getInnerContainerSize().height  -- 计算滚动容器的宽
    local innerWidth = self.m_pScrollView:getInnerContainerSize().width
    local gapX = 200                        -- 单元X间隔
    local gapY = 235                      -- 单元Y间隔
    local addCount = 0                      -- 加多少行
    if #self.m_userlist > 6 then             -- 如果超过最大显示6个则计算需要增加多少行
        local surplusCount = #self.m_userlist - 6 - 1    
        addCount = math.floor(surplusCount / 3) + 1
    end
    self.m_pScrollView:setInnerContainerSize(cc.size(innerWidth, innerHeight+addCount*235))     -- 设置滚动容器的宽高
    local startPosX = 145                                                                       -- 计算X起始点
    local startPosY = self.m_pScrollView:getInnerContainerSize().height - 45                    -- 计算Y起始点
    for i = 1, #self.m_userlist do
        local useritem = self.m_userlist[i]
        if nil ~= useritem then
		    self:refresh(useritem,cc.p(startPosX + math.floor(((i-1)%3)) * gapX, startPosY - math.floor(((i-1)/3)) * gapY))
	    end
    end
end

function UserListLayer:refresh(useritem, pos)
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
    --head:enableInfoPop(true, cc.p(70,220), cc.p(1,0.5))

	--更新昵称
	local szNick = ""
	if nil ~= useritem.szNickName then
		szNick = useritem.szNickName
	end
	local clipText = ccui.Text:create(szNick, appdf.FONT_FILE, 25)
    clipText:setAnchorPoint(cc.p(0.5,0.5))
    clipText:setColor(cc.c3b(255, 255, 254))
    clipText:setPosition(0,-60)
    head:addChild(clipText)

	--更新金币
	local coin = 0
	if nil ~= useritem.lScore then
		coin = useritem.lScore
	end
	local str = ExternalFun.numberThousands(coin)
	if string.len(str) > 11 then
		str = string.sub(str, 1, 7) .. "..."
	end
	local textCoin = ccui.Text:create(str, appdf.FONT_FILE, 25)
    textCoin:setColor(cc.c3b(255, 228, 0))
    textCoin:setAnchorPoint(cc.p(0.5,0.5))
    textCoin:setPosition(0,-90)
    head:addChild(textCoin)
end

return UserListLayer