local RoomLayerModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameRoomLayerModel")
local GameRoomLayer = class("GameRoomLayer", RoomLayerModel)

--获取桌子参数(背景、椅子布局)
function GameRoomLayer:getTableParam()
    local table_bg = cc.Sprite:create("Room/bg_table1.png")
    if nil ~= table_bg then
        local bgSize = table_bg:getContentSize()
        --游戏中背景
        display.newSprite("Room/flag_playstatus1.png")
            :move(102, 180)
            :addTo(table_bg)
            :setTag(4)
        --桌号背景
        display.newSprite("Room/bg_tablenum.png")
            :addTo(table_bg)
            :move(bgSize.width * 0.5,bgSize.height * 0.8)
        --桌号背景
        cc.LabelAtlas:_create("", "Room/font_table_num.png", 20, 25, string.byte("."))
            :addTo(table_bg)
            :setTag(1)
            :move(bgSize.width * 0.41,bgSize.height * 0.74)
        --状态
        display.newSprite("Room/flag_playstatus.png")
            :addTo(table_bg)
            :setTag(2)
            :move(bgSize.width * 0.5, bgSize.height * 0.6)
    end   

    return table_bg, {cc.p(-10,160),cc.p(103,200),cc.p(215,160),cc.p(205,50),cc.p(0,50)}
end

return GameRoomLayer