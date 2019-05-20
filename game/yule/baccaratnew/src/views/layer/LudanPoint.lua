--
-- Author: zhong
-- Date: 2016-06-27 11:36:40
--
local LudanPoint = class("LudanPoint", cc.Layer)
local module_pre = "game.yule.baccaratnew.src"
local cmd = module_pre .. ".models.CMD_Game"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var

--纹理宽高
local LUDAN_WIDTH = 49;
local LUDAN_HEIGHT = 48;

function LudanPoint:ctor(blackGray, scale)
	-- body
    self.winArea = g_var(cmd).AREA_MAX
    self.check = g_var(cmd).AREA_MAX
    self:setContentSize(cc.size(LUDAN_WIDTH,LUDAN_HEIGHT))
    self:setScale(scale)

    local gridName = string.format("baccaratnew_icon_ludan_grid%d.png", blackGray+1)
    local bg = display.newSprite(gridName)
        :setAnchorPoint(cc.p(0.5, 0.5))
        :setPosition(cc.p(LUDAN_WIDTH/2, LUDAN_HEIGHT/2))
        :addTo(self)
end

function LudanPoint:addWinner(winArea, kingWinArea, check)
    self.winArea = winArea
    self.check = check
    local winnerName = ""
    if winArea == g_var(cmd).AREA_XIAN then
        winnerName = "#baccaratnew_icon_ludan_playerwin.png"
    elseif winArea == g_var(cmd).AREA_ZHUANG then
        winnerName = "#baccaratnew_icon_ludan_bankerwin.png"
    elseif winArea == g_var(cmd).AREA_PING then
        winnerName = "#baccaratnew_icon_ludan_flatwin.png"
    end

    if winnerName == "" then
        assert("区域错误")
    end
    
    if self:getChildByTag(199) ~= nil then
        local child = self:getChildByTag(199)
        child:removeFromParent()
    end

    local point = display.newSprite(winnerName)
        :setAnchorPoint(cc.p(0.5, 0.5))
        :setPosition(cc.p(LUDAN_WIDTH/2, LUDAN_HEIGHT/2))
        :addTo(self)
        :setTag(199)

    local atlas = self:getChildByTag(200)
    if atlas == nil then
         atlas = ccui.TextAtlas:create("", "baccaratnew_icon_ludan_cardtype.png", 17, 15, "0")
            :setAnchorPoint(cc.p(0, 0))
            :setPosition(cc.p(0, 0))
            :addTo(self)
            :setTag(200)
            :setLocalZOrder(2)
    end
        
    if winArea == g_var(cmd).AREA_XIAN then
        if kingWinArea == g_var(cmd).AREA_XIAN_DUI then
            atlas:setString("4")
        elseif kingWinArea == g_var(cmd).AREA_XIAN_TIAN then
            atlas:setString("1")
        end
    elseif winArea == g_var(cmd).AREA_ZHUANG then
        if kingWinArea == g_var(cmd).AREA_ZHUANG_DUI then
            atlas:setString("5")
        elseif kingWinArea == g_var(cmd).AREA_ZHUANG_TIAN then
            atlas:setString("2")
        end
    elseif winArea == g_var(cmd).AREA_PING then
        if kingWinArea == g_var(cmd).AREA_TONG_DUI then
            atlas:setString("6")
        end
    end

end

function LudanPoint:addWinType(isAdd)
    if self:getChildByTag(201) ~= nil then
        local child = self:getChildByTag(201)
        child:removeFromParent()
    end
    if isAdd then
        local point = display.newSprite("#baccaratnew_icon_ludan_tick.png")
            :setAnchorPoint(cc.p(0.5, 0.5))
            :setPosition(cc.p(LUDAN_WIDTH/2, LUDAN_HEIGHT/2))
            :addTo(self)
            :setTag(201)
    end
end

function LudanPoint:getArea()
    return self.winArea
end

function LudanPoint:getCheck()
    return self.check
end

return LudanPoint;