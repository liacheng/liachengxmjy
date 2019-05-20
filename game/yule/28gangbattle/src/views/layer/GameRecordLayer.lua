--
-- Author: zhouweixiang
-- Date: 2016-12-27 16:03:00
--
--游戏记录
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local GameRecordLayer = class("GameRecordLayer", cc.Layer)
GameRecordLayer.BT_CLOSE = 1

function GameRecordLayer:ctor(viewParent)
	self.m_parent = viewParent

	--加载csb资源
	local csbNode = ExternalFun.loadCSB("LudanLayer.csb", self)

	local sp_bg = csbNode:getChildByName("im_ludan_bg")
	self.m_spBg = sp_bg
	--关闭按钮
	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(sender:getTag(), sender);
		end
	end

	local layoutbg = csbNode:getChildByName("layout_bg")
	layoutbg:setTag(GameRecordLayer.BT_CLOSE)
	layoutbg:addTouchEventListener(btnEvent)

	--
	self.m_content = sp_bg:getChildByName("layout_content")
    self.m_content:setScrollBarEnabled(false)
    for i = 1 ,3 do 
        sp_bg:getChildByName("txt_win"..i):setFontName(appdf.FONT_FILE)
    end
end

function GameRecordLayer:onButtonClickedEvent( tag, sender )
	if GameRecordLayer.BT_CLOSE == tag then
		self:setVisible(false)
	end
end
--local vecRecord = 
--{
--    [1] = {bWinShunMen = false,bWinDuiMen = false,bWinDaoMen = true},
--    [2] = {bWinShunMen = false,bWinDuiMen = true,bWinDaoMen = true}
--}
function GameRecordLayer:refreshRecord(vecRecord)
	self:setVisible(true)
	if nil == vecRecord or #vecRecord == 0 then
		return
	end
    local count = {0,0,0}
    local itemCount = #vecRecord 
    local itemHeight = 42
	self.m_content:removeAllChildren()
    self.m_content:setInnerContainerSize(cc.size(self.m_content:getInnerContainerSize().width, itemHeight*itemCount))
    
	for i,v in ipairs(vecRecord) do
		local pimage = cc.Sprite:createWithSpriteFrameName("28gang_icon_ludan_win.png")
		if v.bWinShangMen == false then
            count[1] = count[1]+1
			pimage:setSpriteFrame("28gang_icon_ludan_lose.png")
		end
		pimage:setPosition(43,self.m_content:getInnerContainerSize().height-itemHeight/2 - (itemCount-i)*itemHeight)
		self.m_content:addChild(pimage)

		pimage = cc.Sprite:createWithSpriteFrameName("28gang_icon_ludan_win.png")
		if v.bWinTianMen == false then
            count[2] = count[2]+1
			pimage:setSpriteFrame("28gang_icon_ludan_lose.png")
		end
		pimage:setPosition(43+90,self.m_content:getInnerContainerSize().height-itemHeight/2 - (itemCount-i)*itemHeight)
		self.m_content:addChild(pimage)

		pimage = cc.Sprite:createWithSpriteFrameName("28gang_icon_ludan_win.png")
		if v.bWinXiaMen == false then
            count[3] = count[3]+1
			pimage:setSpriteFrame("28gang_icon_ludan_lose.png")
		end
		pimage:setPosition(43+180,self.m_content:getInnerContainerSize().height-itemHeight/2 - (itemCount-i)*itemHeight)
		self.m_content:addChild(pimage)
	end
    for i = 1 ,3 do 
        count[i] = #vecRecord - count[i]
        local probability = self.m_spBg:getChildByName("txt_win"..i)
        local strprobability = string.format("%d%%",(count[i]/#vecRecord)*100) 
        probability:setString(strprobability)
    end
end

return GameRecordLayer