--
-- Author: zhong
-- Date: 2016-10-12 15:22:32
--
local RoomLayerModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameRoomLayerModel")
local GameRoomLayer = class("GameRoomLayer", RoomLayerModel)

--获取桌子参数(背景、椅子布局)
function GameRoomLayer:getTableParam()
    local table_bg = cc.Sprite:create("Room/bg_table2.png")
    if nil ~= table_bg then
        local bgSize = table_bg:getContentSize()
        --游戏中背景
        display.newSprite("Room/flag_playstatus2.png")
            :move(150, 185)
            :addTo(table_bg)
            :setTag(4)
        --桌号背景
        display.newSprite("Room/bg_tablenum.png")
            :addTo(table_bg)
            :move(bgSize.width * 0.5,bgSize.height * 0.8)
        --桌号
        cc.LabelAtlas:_create("", "Room/font_table_num.png", 20, 25, string.byte("."))
            :addTo(table_bg)
            :setTag(1)
            :move(bgSize.width * 0.43,bgSize.height * 0.74)
        --状态
        display.newSprite("Room/flag_playstatus.png")
            :addTo(table_bg)
            :setTag(2)
            :move(bgSize.width * 0.5, bgSize.height * 0.6)
    end    
    return table_bg, {cc.p(-55,100),cc.p(-5,175),cc.p(305,175),cc.p(355,100),cc.p(295,10),cc.p(5,10)}
end

return GameRoomLayer