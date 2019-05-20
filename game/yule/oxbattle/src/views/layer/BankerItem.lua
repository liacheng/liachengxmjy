--
-- Author: zhong
-- Date: 2016-07-07 18:55:48
--
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local BankerItem = class("BankerItem", cc.Node)
local ClipText = appdf.EXTERNAL_SRC .. "ClipText"

function BankerItem:ctor()
	--加载csb资源
	self.m_csbNode = ExternalFun.loadCSB("BankerItem.csb", self)
    self.m_pNode = self.m_csbNode:getChildByName("m_pNode")
	self.m_textCoin = self.m_pNode:getChildByName("text_coin")  -- 金币
	self.m_textCoin:setString("")

	local tmp = self.m_pNode:getChildByName("text_name")  -- 昵称
	local clipText = g_var(ClipText):createClipText(cc.size(110, 20), "")
	clipText:setTextFontSize(20)
	clipText:setAnchorPoint(tmp:getAnchorPoint())
	clipText:setPosition(tmp:getPosition())
	self.m_pNode:addChild(clipText)
	tmp:removeFromParent()
	self.m_clipText = clipText
end

function BankerItem.getSize()
	return 210, 31
end

function BankerItem:refresh(bankeritem)
	if nil == bankeritem then
		return
	end

	if bankeritem.szNickName ~= nil then        -- 更新昵称
	    self.m_clipText:setString(bankeritem.szNickName)
    else
	    self.m_clipText:setString("")
	end

	local coin = 0      -- 更新金币
	if nil ~= bankeritem.lScore then
		coin = bankeritem.lScore
	end
	local str = ExternalFun.numberThousands(coin)
	if string.len(str) > 11 then
		str = string.sub(str, 1, 7) .. "..."
	end
	self.m_textCoin:setString(str)
end

return BankerItem