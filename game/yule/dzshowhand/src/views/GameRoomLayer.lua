--
-- Author: zhong
-- Date: 2016-10-12 15:22:2
--
local RoomLayerModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameRoomLayerModel")
local GameRoomLayer = class("GameRoomLayer", RoomLayerModel)

--获取桌子参数(背景、椅子布局)
function GameRoomLayer:getTableParam()
    local table_bg = cc.Sprite:create("game/yule/dzshowhand/res/roomlist/roomtable.png")

    if nil ~= table_bg then
        local bgSize = table_bg:getContentSize()
        --桌号背景
        display.newSprite("Room/bg_tablenum.png")
            :addTo(table_bg)
            :move(bgSize.width * 0.5,10)
        ccui.Text:create("", appdf.FONT_FILE, 16)
            :addTo(table_bg)
            :setColor(cc.c4b(255,19,200,255))
            :setTag(1)
            :move(bgSize.width * 0.5,12)
        --状态
        display.newSprite("Room/flag_waitstatus.png")
            :addTo(table_bg)
            :setTag(2)
            :move(bgSize.width * 0.5,98)
    end    
    return table_bg, {cc.p(-3,160),cc.p(110,220),cc.p(235,220),cc.p(340,160),cc.p(340,40),cc.p(235,-15),cc.p(110,-15),cc.p(-3,40)}
   -- return table_bg, {cc.p(-3,160),cc.p(170,220),cc.p(42,160),cc.p(10,6),cc.p(0,6)}
end

return GameRoomLayer