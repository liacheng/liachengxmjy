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
            :move(bgSize.width * 0.52, bgSize.height * 0.6)
    end 

    return table_bg, 
    {cc.p(-55,100),cc.p(-5,175),cc.p(305,175),cc.p(355,100),cc.p(295,10),cc.p(5,10),cc.p(-55,100)},     --位置
    {0,0,0,0,0,0},                                                                                      --旋转
    {cc.p(25,135),cc.p(55,160),cc.p(255,160),cc.p(275,135),cc.p(250,110),cc.p(60,110)},                 --准备标识
    {cc.p(-55,90),cc.p(-5,245),cc.p(305,245),cc.p(355,90),cc.p(295,0),cc.p(5,0)},                       --名字
    {cc.p(0.5,0.5),cc.p(0.5,0.5),cc.p(0.5,0.5),cc.p(0.5,0.5),cc.p(0.5,0.5),cc.p(0.5,0.5)},              --名字对齐
    {cc.p(-95,115),cc.p(-45,217),cc.p(345,217),cc.p(395,115),cc.p(335,25),cc.p(-35,25)}                 --手机标识
end

return GameRoomLayer