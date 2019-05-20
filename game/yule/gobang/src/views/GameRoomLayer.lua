--
-- Author: Tang
-- Date: 2016-12-13 09:46:23
--
local RoomLayerModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameRoomLayerModel")
local GameRoomLayer = class("GameRoomLayer", RoomLayerModel)

--获取桌子参数(背景、椅子布局)
function GameRoomLayer:getTableParam()
    local table_bg = cc.Sprite:create("Room/bg_table1.png")
    if nil ~= table_bg then
        local bgSize = table_bg:getContentSize()
        --桌号
        cc.LabelAtlas:_create("", "Room/font_table_num.png", 21, 36, string.byte("."))
            :addTo(table_bg)
            :setTag(1)
            :move(bgSize.width * 0.41,bgSize.height * 0.4)
        --状态
        display.newSprite("Room/flag_playstatus.png")
            :addTo(table_bg)
            :setTag(2)
            :move(bgSize.width * 0.5, bgSize.height * 0.2)
    end    

    return table_bg, {cc.p(20,180),cc.p(220,-20)}
end

return GameRoomLayer