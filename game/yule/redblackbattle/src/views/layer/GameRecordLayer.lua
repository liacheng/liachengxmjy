--
-- Author: zhouweixiang
-- Date: 2016-12-27 16:03:00
--
--游戏记录
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local GameRecordLayer = class("GameRecordLayer", cc.Layer)
GameRecordLayer.BT_CLOSE = 1

--胜负球坐标（21，18）差 40 
--牌路坐标(21,283) 水平差40 垂直差31
--牌型坐标(3,266) 水品差87  垂直差33
local MaxNumLie = 20  --显示最大列

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

    local btn = sp_bg:getChildByName("bt_close")
	btn:setTag(GameRecordLayer.BT_CLOSE)
	btn:addTouchEventListener(btnEvent)

	--胜负
	self.m_winlose = sp_bg:getChildByName("layout_winlose")
    self.m_winloseLayQiu = self.m_winlose:getChildByName("layout_qiu")
    self.m_proBlack = self.m_winlose:getChildByName("progress_black")
    self.m_proBlack:setVisible(false)
    self.m_proBlack:setPercent(10)

    self.m_proBlackRatio = self.m_proBlack:getChildByName("black_ratio")
        :setString("10")
    self.m_proRed = self.m_winlose:getChildByName("progress_red")
    self.m_proRed:setVisible(false)
    self.m_proRed:setPercent(20)
    self.m_proRedRatio = self.m_proRed:getChildByName("red_ratio")
        :setString("10")

    --牌路
    self.m_cardluLay = sp_bg:getChildByName("layout_cardlu")
    self.m_cardluLay:setScrollBarEnabled(false)
    --牌型
    self.m_cardtypeLay = sp_bg:getChildByName("layout_cardtype")
    self.m_cardtypeLay:setScrollBarEnabled(false)

    self.m_cardluLie = 1
    self.m_cardluHang = 1
    self.m_cardlu6Count = 0
    self.m_winAreaNew = 0
    self.m_winAreaOld = 0
    self.m_saveLudan = {}
    for i=1,MaxNumLie do
        local cardlu = {}
        table.insert(self.m_saveLudan, cardlu)
    end

    ExternalFun.showLayer(self, self,true,true,self.sp_bg,false)
end

function GameRecordLayer:onButtonClickedEvent( tag, sender )
	if GameRecordLayer.BT_CLOSE == tag then
		ExternalFun.hideLayer(self, self, false)        
	end
end

function GameRecordLayer:refreshRecord(vecRecord)
	self:setVisible(true)
	if nil == vecRecord then
		return
	end

    local cardTypeLie = 0
    local cardTypeHang = 0
    local kingwinCount = 0
    local itemCount = #vecRecord 

	self.m_winloseLayQiu:removeAllChildren()
    self.m_cardtypeLay:removeAllChildren()  

	for i,v in ipairs(vecRecord) do
        local pimage = cc.Sprite:createWithSpriteFrameName("redblackbattle_icon_win_black.png")
        if v.bWinKing == false then
            pimage:setSpriteFrame("redblackbattle_icon_win_red.png")
        else 
            kingwinCount = kingwinCount+1
        end   		
		pimage:setPosition(cc.p(21+(i-1)*40,18))
		self.m_winloseLayQiu:addChild(pimage)      

        if cardTypeHang == 2 then
            cardTypeLie = cardTypeLie +1
            cardTypeHang = 0
        end
        local frameName  = string.format("redblackbattle_icon_cardtype%d.png",v.bWinCardType) 
		pimage = cc.Sprite:createWithSpriteFrameName(frameName)
        pimage:setScale(0.8)
		pimage:setPosition(cc.p(43+83*cardTypeLie,286-33*cardTypeHang))
		self.m_cardtypeLay:addChild(pimage)
        cardTypeHang = cardTypeHang + 1
	end

    local ratio = (kingwinCount/itemCount)*100
    local strRatioKing  = string.format("%d",ratio) 
    local strRatioRed  = string.format("%d",100-ratio) 
    self.m_proBlack:setPercent(ratio)
    self.m_proBlack:setVisible(true)
    self.m_proBlackRatio:setString(strRatioKing.."%")
    self.m_proRed:setPercent(100-ratio)
    self.m_proRed:setVisible(true)
    self.m_proRedRatio:setString(strRatioRed.."%")         
end

function GameRecordLayer:refreshCardLu(vecRecord)
	if nil == vecRecord or self.m_winAreaOld >0 then
        return
	end
    self.m_cardluLay:removeAllChildren()
    for i,v in ipairs(vecRecord) do
        self:addLudan(v)
    end   
end

function GameRecordLayer:addLudan(vecRecord)
    self.m_winAreaNew = 0
    local ballName = "redblackbattle_icon_win_black.png"
    if vecRecord.bWinKing == false then         
        self.m_winAreaNew = 2
        ballName = "redblackbattle_icon_win_red.png"
    else 
        self.m_winAreaNew = 1
    end

    if (self.m_winAreaNew ~= self.m_winAreaOld and self.m_winAreaOld ~=0 and self.m_winAreaNew ~= 0) then
        self.m_cardluLie = self.m_cardluLie + 1
        self.m_cardluHang = 1   
        if 0 ~= self.m_cardlu6Count then
           self.m_cardluLie = self.m_cardluLie - self.m_cardlu6Count 
           self.m_cardlu6Count = 0
        end
        if self.m_cardluLie <1 then
            self.m_cardluLie = 1
        end
    elseif (7 == self.m_cardluHang) then
        self.m_cardluHang = 6
        self.m_cardluLie = self.m_cardluLie + 1        
        self.m_cardlu6Count = self.m_cardlu6Count + 1
    end
    
    if self.m_cardluLie > MaxNumLie then
        table.remove(self.m_saveLudan, 1)
        local cardLu = {}
        table.insert(self.m_saveLudan, cardLu)
        self.m_cardluLie = MaxNumLie
    end

    if nil ~= self.m_saveLudan[self.m_cardluLie][self.m_cardluHang] then      
       self.m_cardluLie = self.m_cardluLie + 1
       self.m_cardluHang = self.m_cardluHang - 1
       if self.m_cardluHang < 1 then
            self.m_cardluHang = 1
       end
       if self.m_cardluLie > MaxNumLie then
            table.remove(self.m_saveLudan, 1)
            local cardLu = {}
            table.insert(self.m_saveLudan, cardLu)
            self.m_cardluLie = MaxNumLie
       end
     end
    
    self.m_saveLudan[self.m_cardluLie][self.m_cardluHang] = self.m_winAreaNew

    --dump(self.m_saveLudan)
    self.m_cardluLay:removeAllChildren()
    local cardLuBg = cc.Sprite:createWithSpriteFrameName("redblackbattle_trend_cardlu_bg.png")   
    cardLuBg:setPosition(401, 204)
    cardLuBg:setAnchorPoint(cc.p(0.5, 0.5))
    cardLuBg:setLocalZOrder(2)
    self.m_cardluLay:addChild(cardLuBg)

    local ballName = ""
    for i = 1, MaxNumLie do
        for j = 1, 6 do
            if self.m_saveLudan[i][j] == 1 then
                ballName = "redblackbattle_icon_win_black.png"
            elseif self.m_saveLudan[i][j] == 2 then
                ballName = "redblackbattle_icon_win_red.png"
            else
                ballName = ""
            end

            if ballName ~= "" then
                local pimage1u = cc.Sprite:createWithSpriteFrameName(ballName)
                pimage1u:setPosition(cc.p(21+(i-1)*40, 283-(j-1)*31))
                pimage1u:setLocalZOrder(5)
	            --pimage1u:setPosition(cc.p(21+(self.m_cardluLie-1)*40, 283-(self.m_cardluHang-1)*31))
                self.m_cardluLay:addChild(pimage1u)
            end
        end
    end    
    self.m_cardluHang = self.m_cardluHang + 1
    self.m_winAreaOld = self.m_winAreaNew
end

--取消消失
function GameRecordLayer:onClose()
	self:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,cc.p(0,appdf.HEIGHT)),cc.RemoveSelf:create()))	
end
function GameRecordLayer:onShow()
    ExternalFun.showLayer(self, self,true,true)
end

return GameRecordLayer