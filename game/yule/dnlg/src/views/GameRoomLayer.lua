local RoomLayerModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameRoomLayerModel")
local GameRoomLayer = class("GameRoomLayer", RoomLayerModel)

--获取桌子参数(背景、椅子布局)
function GameRoomLayer:getTableParam()
    local table_bg = cc.Sprite:create("game/yule/fishlk/res/roomlist/roomtable.png")

    if nil ~= table_bg then
        local bgSize = table_bg:getContentSize()
        --桌号背景
        display.newSprite("Room/bg_tablenum.png")
            :addTo(table_bg)
            :setScale(1.3)
            :move(bgSize.width * 0.5,28)
        ccui.Text:create("", "fonts/round_body.ttf", 22)
            :addTo(table_bg)
            :setColor(cc.c4b(255,193,200,255))
            :setTag(1)
            :move(bgSize.width * 0.5,30)
        --状态
        display.newSprite("Room/flag_waitstatus.png")
            :addTo(table_bg)
            :setTag(2)
            :move(bgSize.width * 0.5,68)
    end    

    return table_bg, {cc.p(30,200),cc.p(140,200),cc.p(250,200),cc.p(30,-25),cc.p(140,-25),cc.p(250,-25)}
end

return GameRoomLayer