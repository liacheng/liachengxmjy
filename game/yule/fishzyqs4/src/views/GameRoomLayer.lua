local RoomLayerModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameRoomLayerModel")
local GameRoomLayer = class("GameRoomLayer", RoomLayerModel)

--获取桌子参数(背景、椅子布局)
function GameRoomLayer:getTableParam()
    local table_bg = cc.Sprite:create("Room/bg_table3.png")

    if nil ~= table_bg then
        local bgSize = table_bg:getContentSize()
        --游戏中背景
        display.newSprite("Room/flag_playstatus3.png")
            :move(150, 180)
            :addTo(table_bg)
            :setTag(4)
        --桌号背景
        display.newSprite("Room/bg_tablenum.png")
            :addTo(table_bg)
            :move(bgSize.width * 0.5,bgSize.height * 0.9)
        --桌号背景
        cc.LabelAtlas:_create("", "Room/font_table_num.png", 20, 25, string.byte("."))
            :addTo(table_bg)
            :setTag(1)
            :move(bgSize.width * 0.43,bgSize.height * 0.84)
        --状态
        display.newSprite("Room/flag_playstatus.png")
            :addTo(table_bg)
            :setTag(2)
            :move(bgSize.width * 0.5, bgSize.height * 0.6)
    end    

    return table_bg, 
    {cc.p(5,170),cc.p(295,170),cc.p(295,40),cc.p(5,40)},            --位置
    {0,0,0,0},                                                      --旋转
    {cc.p(65,165),cc.p(240,165),cc.p(240,110),cc.p(65,110)},        --准备标识
    {cc.p(5,240),cc.p(295,240),cc.p(295,30),cc.p(5,30)},            --名字
    {cc.p(0.5,0.5),cc.p(0.5,0.5),cc.p(0.5,0.5),cc.p(0.5,0.5)},      --名字对齐
    {cc.p(-35,215),cc.p(335,215),cc.p(335,55),cc.p(-35,55)}         --手机标识
end

return GameRoomLayer