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

--zy	local btn = sp_bg:getChildByName("bt_close")
--	btn:setTag(GameRecordLayer.BT_CLOSE)
--	btn:addTouchEventListener(btnEvent)

	local layoutbg = csbNode:getChildByName("layout_bg")
	layoutbg:setTag(GameRecordLayer.BT_CLOSE)
	layoutbg:addTouchEventListener(btnEvent)

	--
	self.m_content = sp_bg:getChildByName("layout_content")
    
    self.m_spBg:getChildByName("Text_1"):setFontName(appdf.FONT_FILE)
    self.m_spBg:getChildByName("Text_2"):setFontName(appdf.FONT_FILE)
    self.m_spBg:getChildByName("Text_3"):setFontName(appdf.FONT_FILE)
    self.m_spBg:getChildByName("Text_4"):setFontName(appdf.FONT_FILE)
    sp_bg:setScale(0, 0)
    sp_bg:runAction(cc.ScaleTo:create(0.2, 1))
end

function GameRecordLayer:onButtonClickedEvent( tag, sender )
	ExternalFun.playClickEffect()
	if GameRecordLayer.BT_CLOSE == tag then
        self.m_spBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function()
            self:setVisible(false)
        end)))
	end
end

function GameRecordLayer:refreshRecord(vecRecord)
    
    self:setVisible(true)
    self.m_spBg:runAction(cc.ScaleTo:create(0.2, 1))
    local recordCount = 0

    for i = 1, #vecRecord do
        recordCount = recordCount + 1
    end
    if recordCount < 7 then
        recordCount = 7
    end
    self.m_content:setInnerContainerSize(cc.size(self.m_content:getInnerContainerSize().width, 52*recordCount))
    local recordGapWidth = 70
    local recordGapHeight = 52
    local recordListHeight = 1020
    local count = {0,0,0,0,}
	self:setVisible(true)
	if nil == vecRecord then
		return
	end
	self.m_content:removeAllChildren()

    local item = nil
	for i = 1, #vecRecord do
        item = vecRecord[#vecRecord - i + 1] 
		local pimage = cc.Sprite:createWithSpriteFrameName("oxbattle_icon_trendtrue.png")
		if item.bWinTianMen == false then
            count[1] = count[1]+1
			pimage:setSpriteFrame("oxbattle_icon_trendfalse.png")
		end
		pimage:setPosition(35 , recordListHeight-(i-1)*recordGapHeight)
		self.m_content:addChild(pimage)

		pimage = cc.Sprite:createWithSpriteFrameName("oxbattle_icon_trendtrue.png")
		if item.bWinDiMen == false then
            count[2] = count[2]+1
			pimage:setSpriteFrame("oxbattle_icon_trendfalse.png")
		end
		pimage:setPosition(35 + recordGapWidth,recordListHeight-(i-1)*recordGapHeight)
		self.m_content:addChild(pimage)

		pimage = cc.Sprite:createWithSpriteFrameName("oxbattle_icon_trendtrue.png")
		if item.bWinXuanMen == false then
            count[3] = count[3]+1
			pimage:setSpriteFrame("oxbattle_icon_trendfalse.png")
		end
		pimage:setPosition(35 + recordGapWidth*2, recordListHeight-(i-1)*recordGapHeight)
		self.m_content:addChild(pimage)

		pimage = cc.Sprite:createWithSpriteFrameName("oxbattle_icon_trendtrue.png")
		if item.bWinHuangMen == false then
            count[4] = count[4]+1
			pimage:setSpriteFrame("oxbattle_icon_trendfalse.png")
		end
		pimage:setPosition(35 + recordGapWidth*3, recordListHeight-(i-1)*recordGapHeight)	
		self.m_content:addChild(pimage) 
	end
    count[1] = #vecRecord - count[1]
    count[2] = #vecRecord - count[2]
    count[3] = #vecRecord - count[3]
    count[4] = #vecRecord - count[4]
    local probability1 = self.m_spBg:getChildByName("Text_1")
    local strprobability1 = string.format("%0.1f%%",(count[1]/#vecRecord)*100) 
    probability1:setString(strprobability1)
    local probability2 = self.m_spBg:getChildByName("Text_2")
    local strprobability2 = string.format("%0.1f%%",(count[2]/#vecRecord)*100) 
    probability2:setString(strprobability2)
    local probability3 = self.m_spBg:getChildByName("Text_3")
    local strprobability3 = string.format("%0.1f%%",(count[3]/#vecRecord)*100) 
    probability3:setString(strprobability3)
    local probability4 = self.m_spBg:getChildByName("Text_4")
    local strprobability4 = string.format("%0.1f%%",(count[4]/#vecRecord)*100) 
    probability4:setString(strprobability4)



    
end

return GameRecordLayer