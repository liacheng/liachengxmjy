--
-- Author: zhong
-- Date: 2016-10-12 15:22:32
--
local RoomLayerModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameRoomLayerModel")
local GameRoomLayer = class("GameRoomLayer", RoomLayerModel)

--获取桌子参数(背景、椅子布局)
function GameRoomLayer:getTableParam()
--    local table_bg = cc.Sprite:create("game/qipai/land/res/roomlist/roomtable.png")

--    if nil ~= table_bg then
--        local bgSize = table_bg:getContentSize()
--        --桌号背景
--        display.newSprite("Room/bg_tablenum.png")
--            :addTo(table_bg)
--            :move(bgSize.width * 0.5,10)
--        ccui.Text:create("", appdf.FONT_FILE, 16)
--            :addTo(table_bg)
--            :setColor(cc.c4b(255,193,200,255))
--            :setTag(1)
--            :move(bgSize.width * 0.5,12)
--        --状态
--        display.newSprite("Room/flag_waitstatus.png")
--            :addTo(table_bg)
--            :setTag(2)
--            :move(bgSize.width * 0.5,48)
--    end    

--    return table_bg, {cc.p(18,130), cc.p(212,130), cc.p(115, -30)}
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
        --桌号
        cc.LabelAtlas:_create("", "Room/font_table_num.png", 20, 25, string.byte("."))
            :addTo(table_bg)
            :setTag(1)
            :move(bgSize.width * 0.4,bgSize.height * 0.74)
        --状态
        display.newSprite("Room/flag_playstatus.png")
            :addTo(table_bg)
            :setTag(2)
            :move(bgSize.width * 0.5, bgSize.height * 0.6)
    end    
    return table_bg, {cc.p(100,203), cc.p(7, 25), cc.p(208,35), cc.p(113, 230)}
end

return GameRoomLayer