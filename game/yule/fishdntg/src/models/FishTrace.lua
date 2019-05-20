--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local FishTrace = class("FishTrace")
FishTrace.scene_kind_1_trace_ = {}
FishTrace.scene_kind_2_trace_ = {}
FishTrace.scene_kind_3_trace_ = {}
FishTrace.scene_kind_4_trace_ = {}
FishTrace.scene_kind_5_trace_ = {}
FishTrace.scene_kind_6_trace_ = {}

FishTrace.scene_kind_1_kind_id = {}
FishTrace.scene_kind_2_kind_id = {}
FishTrace.scene_kind_3_kind_id = {}
FishTrace.scene_kind_4_kind_id = {}
FishTrace.scene_kind_5_kind_id = {}
FishTrace.scene_kind_6_kind_id = {}

function FishTrace:ctor()
    self.kResolutionWidth = 1334
    self.kResolutionHeight = 750
    self.M_PI = 3.14159265358979323846
    self.M_PI_2 = 1.57079632679489661923
    self.M_PI_4 = 0.785398163397448309616
    self.M_1_PI = 0.318309886183790671538
    self.M_2_PI = 0.636619772367581343076
end

function FishTrace:BuildTrace(posx, posy, trace_vector, count)
    trace_vector = {}

    for i = 1, count do
        local point = {}
        point.x = posx[i]
        point.y = posy[i]
        table.insert(trace_vector, point)
    end

    return trace_vector
end 

function FishTrace:BuildSceneKind1Trace(screen_width,screen_height) 
    local startPos = cc.p(0, 0)
    local endPos = cc.p(0, 0)
    local offsetX = -268
    local fish_count = 0
    local fishPosX = {}
    local fishPosY = {}
    -- 绿草鱼 16 * 4
    for i = 1, 16 do
        fishPosX[1] = offsetX - i * 54
        fishPosY[1] = 150
        fishPosX[2] = self.kResolutionWidth * 2 + fishPosX[1]
        fishPosY[2] = 150
        FishTrace.scene_kind_1_trace_[i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_1_trace_[i], 2)
        FishTrace.scene_kind_1_kind_id[i] = 1
    end
    fish_count = fish_count + 16

    for i = 1, 16 do
        fishPosX[1] = offsetX - i * 54
        fishPosY[1] = 150 + 100
        fishPosX[2] = self.kResolutionWidth * 2 + fishPosX[1]
        fishPosY[2] = 150 + 100
        FishTrace.scene_kind_1_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_1_trace_[fish_count + i], 2)
        FishTrace.scene_kind_1_kind_id[fish_count + i] = 1
    end
    fish_count = fish_count + 16

    for i = 1, 16 do
        fishPosX[1] = offsetX - i * 54
        fishPosY[1] = self.kResolutionHeight - 150 - 100
        fishPosX[2] = self.kResolutionWidth * 2 + fishPosX[1]
        fishPosY[2] = self.kResolutionHeight - 150 - 100
        FishTrace.scene_kind_1_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_1_trace_[fish_count + i], 2)
        FishTrace.scene_kind_1_kind_id[fish_count + i] = 1
    end
    fish_count = fish_count + 16

    for i = 1, 16 do
        fishPosX[1] = offsetX - i * 54
        fishPosY[1] = self.kResolutionHeight - 150
        fishPosX[2] = self.kResolutionWidth * 2 + fishPosX[1]
        fishPosY[2] = self.kResolutionHeight - 150
        FishTrace.scene_kind_1_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_1_trace_[fish_count + i], 2)
        FishTrace.scene_kind_1_kind_id[fish_count + i] = 1
    end
    fish_count = fish_count + 16

    -- 小刺鱼 10 + 10 + 3 + 3
    offsetX = -100
    for i = 1, 10 do
        fishPosX[1] = offsetX - i * 120
        fishPosY[1] = 150 + 50
        fishPosX[2] = self.kResolutionWidth * 2 + fishPosX[1]
        fishPosY[2] = 150 + 50
        FishTrace.scene_kind_1_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_1_trace_[fish_count + i], 2)
        FishTrace.scene_kind_1_kind_id[fish_count + i] = 6
    end
    fish_count = fish_count + 10

    for i = 1, 10 do
        fishPosX[1] = offsetX - i * 120
        fishPosY[1] = self.kResolutionHeight - 150 - 50
        fishPosX[2] = self.kResolutionWidth * 2 + fishPosX[1]
        fishPosY[2] = self.kResolutionHeight - 150 - 50
        FishTrace.scene_kind_1_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_1_trace_[fish_count + i], 2)
        FishTrace.scene_kind_1_kind_id[fish_count + i] = 6
    end
    fish_count = fish_count + 10

    for i = 1, 3 do
        fishPosX[1] = offsetX - 120
        fishPosY[1] = 150 + 50 + i * 87.5
        fishPosX[2] = self.kResolutionWidth * 2 + fishPosX[1]
        fishPosY[2] = 150 + 50 + i * 87.5
        FishTrace.scene_kind_1_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_1_trace_[fish_count + i], 2)
        FishTrace.scene_kind_1_kind_id[fish_count + i] = 6
    end
    fish_count = fish_count + 3

    for i = 1, 3 do
        fishPosX[1] = offsetX - 10 * 120
        fishPosY[1] = 150 + 50 + i * 87.5
        fishPosX[2] = self.kResolutionWidth * 2 + fishPosX[1]
        fishPosY[2] = 150 + 50 + i * 87.5
        FishTrace.scene_kind_1_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_1_trace_[fish_count + i], 2)
        FishTrace.scene_kind_1_kind_id[fish_count + i] = 6
    end
    fish_count = fish_count + 3

    -- 大眼鱼 4 + 4
    offsetX = -268
    local radius = 50
    local angle = 0
    for i = 1, 4 do
        fishPosX[1] = offsetX - 2 * 54 + radius * math.cos(angle)
        fishPosY[1] = self.kResolutionHeight/2 + radius * math.sin(angle)
        fishPosX[2] = self.kResolutionWidth * 2 + fishPosX[1]
        fishPosY[2] = fishPosY[1]
        FishTrace.scene_kind_1_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_1_trace_[fish_count + i], 2)
        FishTrace.scene_kind_1_kind_id[fish_count + i] = 3

        angle = angle + self.M_PI_2;
    end
    fish_count = fish_count + 4

    angle = 0
    for i = 1, 4 do
        fishPosX[1] = offsetX - 15 * 54 + radius * math.cos(angle)
        fishPosY[1] = self.kResolutionHeight/2 + radius * math.sin(angle)
        fishPosX[2] = self.kResolutionWidth * 2 + fishPosX[1]
        fishPosY[2] = fishPosY[1]
        FishTrace.scene_kind_1_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_1_trace_[fish_count + i], 2)
        FishTrace.scene_kind_1_kind_id[fish_count + i] = 3

        angle = angle + self.M_PI_2;
    end
    fish_count = fish_count + 4

    -- 悟空
  
    fishPosX[1] = -100 - self.kResolutionWidth/2
    fishPosY[1] = self.kResolutionHeight/2 + 110
    fishPosX[2] = self.kResolutionWidth * 2 + fishPosX[1]
    fishPosY[2] = fishPosY[1]
    
    FishTrace.scene_kind_1_trace_[fish_count + 1] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_1_trace_[fish_count + 1], 2)
    FishTrace.scene_kind_1_kind_id[fish_count + 1] = 24
    fish_count = fish_count + 1


end

function FishTrace:BuildSceneKind2Trace(screen_width,screen_height)
    local centerPos = cc.p(self.kResolutionWidth / 2, self.kResolutionHeight / 2)
    local radius = 0
    local curRotate = 0
    local gapRotate = 0
    local fish_count = 0
    local curIndex = 1
    local fishPosX = {}
    local fishPosY = {}

    -- 玉皇大帝
    radius = 1
    fishPosX[1] = centerPos.x
    fishPosY[1] = centerPos.y
    curIndex = 2
    curRotate = 90
    for rotate = 24, 720, 24 do
        fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
        fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
        curIndex = curIndex + 1
    end
    fishPosX[curIndex] = 1500
    fishPosY[curIndex] = centerPos.y

    FishTrace.scene_kind_2_trace_[1] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_2_trace_[1], curIndex)
    FishTrace.scene_kind_2_kind_id[1] = 25
    fish_count = fish_count + 1
    
    -- 小丑鱼
    fishPosX = {}
    fishPosY = {}
    radius = 150
    gapRotate = 360 / 10
    for i = 1, 10 do
        curRotate = i * gapRotate;
        fishPosX[1] = centerPos.x
        fishPosY[1] = centerPos.y
        curIndex = 2
        for rotate = 24, 720, 24 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            curIndex = curIndex + 1
        end
        fishPosX[curIndex] = (radius * math.cos((curRotate - 0) * self.M_PI / 180) - radius * math.cos((curRotate - 1) * self.M_PI / 180)) * (100)
        fishPosY[curIndex] = (radius * math.sin((curRotate - 0) * self.M_PI / 180) - radius * math.sin((curRotate - 1) * self.M_PI / 180)) * (100)
        
        FishTrace.scene_kind_2_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_2_trace_[fish_count + i], curIndex)
        FishTrace.scene_kind_2_kind_id[fish_count + i] = 5
    end
    fish_count = fish_count + 10
    
    -- 大眼鱼
    fishPosX = {}
    fishPosY = {}
    curRotate = 0
    radius = 150 + 52 + 42
    gapRotate = 360 / 18
    for i = 1, 18 do
        curRotate = i * gapRotate;
        fishPosX[1] = centerPos.x
        fishPosY[1] = centerPos.y
        curIndex = 2
        
        for rotate = 21, 630, 21 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            curIndex = curIndex + 1
        end

        fishPosX[curIndex] = (radius * math.cos((curRotate - 90) * self.M_PI / 180) - radius * math.cos((curRotate - 91) * self.M_PI / 180)) * (100)
        fishPosY[curIndex] = (radius * math.sin((curRotate - 90) * self.M_PI / 180) - radius * math.sin((curRotate - 91) * self.M_PI / 180)) * (100)

        FishTrace.scene_kind_2_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_2_trace_[fish_count + i], curIndex)
        FishTrace.scene_kind_2_kind_id[fish_count + i] = 3
    end
    fish_count = fish_count + 18
    
    -- 黄草鱼
    fishPosX = {}
    fishPosY = {}
    curRotate = 0
    radius = 150 + 52 + 42 * 2 + 30
    gapRotate = 360 / 30
    for i = 1, 30 do
        curRotate = i * gapRotate;
        fishPosX[1] = centerPos.x
        fishPosY[1] = centerPos.y
        curIndex = 2
        
        for rotate = 18, 540, 18 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            curIndex = curIndex + 1
        end

        fishPosX[curIndex] = (radius * math.cos((curRotate - 180) * self.M_PI / 180) - radius * math.cos((curRotate - 181) * self.M_PI / 180)) * (100)
        fishPosY[curIndex] = (radius * math.sin((curRotate - 180) * self.M_PI / 180) - radius * math.sin((curRotate - 181) * self.M_PI / 180)) * (100)

        FishTrace.scene_kind_2_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_2_trace_[fish_count + i], curIndex)
        FishTrace.scene_kind_2_kind_id[fish_count + i] = 2
    end
    fish_count = fish_count + 30
    
    -- 蜗牛鱼
    fishPosX = {}
    fishPosY = {}
    curRotate = 0
    radius = 150 + 52 + 42 * 2 + 30 * 2 + 35
    gapRotate = 360 / 30
    for i = 1, 30 do
        curRotate = i * gapRotate;
        fishPosX[1] = centerPos.x
        fishPosY[1] = centerPos.y
        curIndex = 2
        
        for rotate = 15, 450, 15 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            curIndex = curIndex + 1
        end

        fishPosX[curIndex] = (radius * math.cos((curRotate - 270) * self.M_PI / 180) - radius * math.cos((curRotate - 271) * self.M_PI / 180)) * (100)
        fishPosY[curIndex] = (radius * math.sin((curRotate - 270) * self.M_PI / 180) - radius * math.sin((curRotate - 271) * self.M_PI / 180)) * (100)

        FishTrace.scene_kind_2_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_2_trace_[fish_count + i], curIndex)
        FishTrace.scene_kind_2_kind_id[fish_count + i] = 0
    end
    fish_count = fish_count + 30
end

function FishTrace:BuildSceneKind3Trace(screen_width,screen_height) 
    local centerPos = cc.p(self.kResolutionWidth / 2, self.kResolutionHeight / 2)
    local radius = 0
    local curRotate = 0
    local gapRotate = 0
    local fish_count = 0
    local curIndex = 1
    local fishPosX = {}
    local fishPosY = {}

    -- 孙悟空
    radius = 1
    fishPosX[1] = centerPos.x
    fishPosY[1] = centerPos.y
    curIndex = 2
    curRotate = 90
    for rotate = 24, 720, 24 do
        fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
        fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
        curIndex = curIndex + 1
    end
    fishPosX[curIndex] = 1500
    fishPosY[curIndex] = centerPos.y

    FishTrace.scene_kind_3_trace_[1] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_3_trace_[1], curIndex)
    FishTrace.scene_kind_3_kind_id[1] = 24
    fish_count = fish_count + 1
    
    -- 小丑鱼
    fishPosX = {}
    fishPosY = {}
    radius = 150
    gapRotate = 360 / 10
    for i = 1, 10 do
        curRotate = i * gapRotate;
        fishPosX[1] = centerPos.x
        fishPosY[1] = centerPos.y
        curIndex = 2
        for rotate = 24, 720, 24 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            curIndex = curIndex + 1
        end
        fishPosX[curIndex] = (radius * math.cos((curRotate - 0) * self.M_PI / 180) - radius * math.cos((curRotate - 1) * self.M_PI / 180)) * (100)
        fishPosY[curIndex] = (radius * math.sin((curRotate - 0) * self.M_PI / 180) - radius * math.sin((curRotate - 1) * self.M_PI / 180)) * (100)
        
        FishTrace.scene_kind_3_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_3_trace_[fish_count + i], curIndex)
        FishTrace.scene_kind_3_kind_id[fish_count + i] = 5
    end
    fish_count = fish_count + 10
    
    -- 大眼鱼
    fishPosX = {}
    fishPosY = {}
    curRotate = 0
    radius = 150 + 52 + 42
    gapRotate = 360 / 18
    for i = 1, 18 do
        curRotate = i * gapRotate;
        fishPosX[1] = centerPos.x
        fishPosY[1] = centerPos.y
        curIndex = 2
        
        for rotate = 21, 630, 21 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            curIndex = curIndex + 1
        end

        fishPosX[curIndex] = (radius * math.cos((curRotate - 90) * self.M_PI / 180) - radius * math.cos((curRotate - 91) * self.M_PI / 180)) * (100)
        fishPosY[curIndex] = (radius * math.sin((curRotate - 90) * self.M_PI / 180) - radius * math.sin((curRotate - 91) * self.M_PI / 180)) * (100)

        FishTrace.scene_kind_3_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_3_trace_[fish_count + i], curIndex)
        FishTrace.scene_kind_3_kind_id[fish_count + i] = 3
    end
    fish_count = fish_count + 18
    
    -- 黄草鱼
    fishPosX = {}
    fishPosY = {}
    curRotate = 0
    radius = 150 + 52 + 42 * 2 + 30
    gapRotate = 360 / 30
    for i = 1, 30 do
        curRotate = i * gapRotate;
        fishPosX[1] = centerPos.x
        fishPosY[1] = centerPos.y
        curIndex = 2
        
        for rotate = 18, 540, 18 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            curIndex = curIndex + 1
        end

        fishPosX[curIndex] = (radius * math.cos((curRotate - 180) * self.M_PI / 180) - radius * math.cos((curRotate - 181) * self.M_PI / 180)) * (100)
        fishPosY[curIndex] = (radius * math.sin((curRotate - 180) * self.M_PI / 180) - radius * math.sin((curRotate - 181) * self.M_PI / 180)) * (100)

        FishTrace.scene_kind_3_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_3_trace_[fish_count + i], curIndex)
        FishTrace.scene_kind_3_kind_id[fish_count + i] = 2
    end
    fish_count = fish_count + 30
    
    -- 蜗牛鱼
    fishPosX = {}
    fishPosY = {}
    curRotate = 0
    radius = 150 + 52 + 42 * 2 + 30 * 2 + 35
    gapRotate = 360 / 30
    for i = 1, 30 do
        curRotate = i * gapRotate;
        fishPosX[1] = centerPos.x
        fishPosY[1] = centerPos.y
        curIndex = 2
        
        for rotate = 15, 450, 15 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            curIndex = curIndex + 1
        end

        fishPosX[curIndex] = (radius * math.cos((curRotate - 270) * self.M_PI / 180) - radius * math.cos((curRotate - 271) * self.M_PI / 180)) * (100)
        fishPosY[curIndex] = (radius * math.sin((curRotate - 270) * self.M_PI / 180) - radius * math.sin((curRotate - 271) * self.M_PI / 180)) * (100)

        FishTrace.scene_kind_3_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_3_trace_[fish_count + i], curIndex)
        FishTrace.scene_kind_3_kind_id[fish_count + i] = 0
    end
    fish_count = fish_count + 30
end

function FishTrace:BuildSceneKind4Trace(screen_width,screen_height) 
    local fishPosX = {}
    local fishPosY = {}
    local startX = 194
    local gapX = 60
    local fish_count = 0
    -- 蜗牛鱼 上50 下50
    local curIndex = 0
    for i = 1, 10 do
        for j = 1, 5 do
            curIndex = (i-1)*5 + j
            fishPosX[1] = startX + (i - 1) * 60 * 2
            fishPosY[1] = -100 - (j - 1) * 125 - math.fmod((i - 1), 3) * 25 
            fishPosX[2] = fishPosX[1]
            fishPosY[2] = self.kResolutionHeight * 2 + fishPosY[1]
            FishTrace.scene_kind_4_trace_[curIndex] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_4_trace_[curIndex], 2)
            FishTrace.scene_kind_4_kind_id[curIndex] = 0
        end
    end
    fish_count = fish_count + 50

    for i = 1, 10 do
        for j = 1, 5 do
            curIndex = (i-1)*5 + j
            fishPosX[1] = startX + 60 + (i - 1) * 60 * 2
            fishPosY[1] = self.kResolutionHeight + 100 + (j - 1) * 125 + math.fmod((i - 1), 3) * 25 
            fishPosX[2] = fishPosX[1]
            fishPosY[2] = fishPosY[1] - self.kResolutionHeight * 2
            FishTrace.scene_kind_4_trace_[fish_count + curIndex] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_4_trace_[fish_count + curIndex], 2)
            FishTrace.scene_kind_4_kind_id[fish_count + curIndex] = 0
        end
    end
    fish_count = fish_count + 50

    -- 蝙蝠鱼 银鲨 金鲨
    local kFishStart1 = { 
        cc.p(self.kResolutionWidth +  200, self.kResolutionHeight / 2), 
        cc.p(self.kResolutionWidth +  500, self.kResolutionHeight / 2 - 50), 
        cc.p(self.kResolutionWidth +  800, self.kResolutionHeight / 2 + 60), 
        cc.p(self.kResolutionWidth + 1100, self.kResolutionHeight / 2 - 60), 
        cc.p(self.kResolutionWidth + 1400, self.kResolutionHeight / 2 - 60)}
    local kFishEnd1 = { 
        cc.p(-1400, self.kResolutionHeight / 2), 
        cc.p(-1100, self.kResolutionHeight / 2 - 100), 
        cc.p( -800, self.kResolutionHeight / 2 + 100), 
        cc.p( -500, self.kResolutionHeight / 2 +  60), 
        cc.p( -200, self.kResolutionHeight / 2 -  60) }
    for i = 1, 5 do
        fishPosX[1] = kFishStart1[i].x
        fishPosY[1] = kFishStart1[i].y
        fishPosX[2] = kFishEnd1[i].x
        fishPosY[2] = kFishEnd1[i].y
        FishTrace.scene_kind_4_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_4_trace_[fish_count + i], 2)
        FishTrace.scene_kind_4_kind_id[fish_count + i] = 14
    end
    fish_count = fish_count + 5

    local kFishStart2 = { 
        cc.p(self.kResolutionWidth +  200, self.kResolutionHeight / 2), 
        cc.p(self.kResolutionWidth +  500, self.kResolutionHeight / 2 - 50), 
        cc.p(self.kResolutionWidth +  800, self.kResolutionHeight / 2 + 60), 
        cc.p(self.kResolutionWidth + 1100, self.kResolutionHeight / 2 - 60), 
        cc.p(self.kResolutionWidth + 1400, self.kResolutionHeight / 2 - 60) }
    local kFishEnd2 = { 
        cc.p(-1800, self.kResolutionHeight - 100), 
        cc.p(-1500, self.kResolutionHeight +   1), 
        cc.p(-1200, self.kResolutionHeight + 100), 
        cc.p( -900, self.kResolutionHeight +  60), 
        cc.p( -600, self.kResolutionHeight -  60) }

    for i = 1, 5 do
        fishPosX[1] = kFishStart2[i].x
        fishPosY[1] = kFishStart2[i].y
        fishPosX[2] = kFishEnd2[i].x
        fishPosY[2] = kFishEnd2[i].y
        FishTrace.scene_kind_4_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_4_trace_[fish_count + i], 2)
        FishTrace.scene_kind_4_kind_id[fish_count + i] = 15
    end
    fish_count = fish_count + 5

    local kFishStart3 = { 
        cc.p(self.kResolutionWidth +  200, self.kResolutionHeight / 2), 
        cc.p(self.kResolutionWidth +  500, self.kResolutionHeight / 2 - 50), 
        cc.p(self.kResolutionWidth +  800, self.kResolutionHeight / 2 + 60), 
        cc.p(self.kResolutionWidth + 1100, self.kResolutionHeight / 2 - 60), 
        cc.p(self.kResolutionWidth + 1400, self.kResolutionHeight / 2 - 60)}
    local kFishEnd3 = { 
        cc.p(-1800,  100), 
        cc.p(-1500,    0), 
        cc.p(-1200, -100), 
        cc.p( -900,  -60), 
        cc.p( -600,   60)}

    for i = 1, 5 do
        fishPosX[1] = kFishStart3[i].x
        fishPosY[1] = kFishStart3[i].y
        fishPosX[2] = kFishEnd3[i].x
        fishPosY[2] = kFishEnd3[i].y
        FishTrace.scene_kind_4_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_4_trace_[fish_count + i], 2)
        FishTrace.scene_kind_4_kind_id[fish_count + i] = 16
    end
    fish_count = fish_count + 5
end

function FishTrace:BuildSceneKind5Trace(screen_width,screen_height)
    local center = cc.p(self.kResolutionWidth / 2, self.kResolutionHeight / 2)
    local radius = 300
    local gapRotate = 360 / 15
    local rotate = 0
    local fishPosX = {}
    local fishPosY = {}
    local fish_count = 0

    for i = 1, 15 do
        rotate = i * gapRotate
        fishPosX[1] = center.x
        fishPosY[1] = center.y
        fishPosX[2] = center.x + radius * math.cos(rotate * self.M_PI / 180)
        fishPosY[2] = center.y + radius * math.sin(rotate * self.M_PI / 180)
        FishTrace.scene_kind_5_trace_[i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_5_trace_[i], 2)
        FishTrace.scene_kind_5_kind_id[i] = 5
    end
    fish_count = fish_count + 15

    for i = 1, 15 do
        rotate = i * gapRotate
        fishPosX[1] = center.x
        fishPosY[1] = center.y
        fishPosX[2] = center.x + radius * math.cos(rotate * self.M_PI / 180)
        fishPosY[2] = center.y + radius * math.sin(rotate * self.M_PI / 180)
        FishTrace.scene_kind_5_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_5_trace_[fish_count + i], 2)
        FishTrace.scene_kind_5_kind_id[fish_count + i] = 10
    end
    fish_count = fish_count + 15

    for i = 1, 15 do
        rotate = i * gapRotate
        fishPosX[1] = center.x
        fishPosY[1] = center.y
        fishPosX[2] = center.x + radius * math.cos(rotate * self.M_PI / 180)
        fishPosY[2] = center.y + radius * math.sin(rotate * self.M_PI / 180)
        FishTrace.scene_kind_5_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_5_trace_[fish_count + i], 2)
        FishTrace.scene_kind_5_kind_id[fish_count + i] = 14
    end
    fish_count = fish_count + 15

    for i = 1, 15 do
        rotate = i * gapRotate
        fishPosX[1] = center.x
        fishPosY[1] = center.y
        fishPosX[2] = center.x + radius * math.cos(rotate * self.M_PI / 180)
        fishPosY[2] = center.y + radius * math.sin(rotate * self.M_PI / 180)
        FishTrace.scene_kind_5_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_5_trace_[fish_count + i], 2)
        FishTrace.scene_kind_5_kind_id[fish_count + i] = 11
    end
    fish_count = fish_count + 15

    for i = 1, 15 do
        rotate = i * gapRotate
        fishPosX[1] = center.x
        fishPosY[1] = center.y
        fishPosX[2] = center.x + radius * math.cos(rotate * self.M_PI / 180)
        fishPosY[2] = center.y + radius * math.sin(rotate * self.M_PI / 180)
        FishTrace.scene_kind_5_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_5_trace_[fish_count + i], 2)
        FishTrace.scene_kind_5_kind_id[fish_count + i] = 16
    end
    fish_count = fish_count + 15
end

function FishTrace:BuildSceneKind6Trace(screen_width,screen_height) 
    local center = cc.p(self.kResolutionWidth / 2, self.kResolutionHeight / 2)
    local radius = 360
    local gapRotate = 360 / 15
    local curRotate = 0
    local fishPosX = {}
    local fishPosY = {}
    local fish_count = 0
    local curIndex = 0

    for i = 1, 15 do
        radius = 360
        curRotate = i * gapRotate
        fishPosX[1] = center.x
        fishPosY[1] = center.y
        fishPosX[2] = center.x + radius * math.cos(curRotate * self.M_PI / 180)
        fishPosY[2] = center.y + radius * math.sin(curRotate * self.M_PI / 180)
        curIndex = 3
        for rotate = 3, 360, 3 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            radius = radius - 3
            curIndex = curIndex + 1
        end
        
        FishTrace.scene_kind_6_trace_[i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_6_trace_[i], curIndex - 1)
        FishTrace.scene_kind_6_kind_id[i] = 5
    end
    fish_count = fish_count + 15

    for i = 1, 15 do
        radius = 360
        curRotate = i * gapRotate
        fishPosX[1] = center.x
        fishPosY[1] = center.y
        fishPosX[2] = center.x + radius * math.cos(curRotate * self.M_PI / 180)
        fishPosY[2] = center.y + radius * math.sin(curRotate * self.M_PI / 180)
        curIndex = 3
        for rotate = 9, 1080, 9 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            radius = radius - 3
            curIndex = curIndex + 1
        end
        
        FishTrace.scene_kind_6_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_6_trace_[fish_count + i], curIndex - 1)
        FishTrace.scene_kind_6_kind_id[fish_count + i] = 3
    end
    fish_count = fish_count + 15

    for i = 1, 15 do
        radius = 360
        curRotate = i * gapRotate
        fishPosX[1] = center.x
        fishPosY[1] = center.y
        fishPosX[2] = center.x + radius * math.cos(curRotate * self.M_PI / 180)
        fishPosY[2] = center.y + radius * math.sin(curRotate * self.M_PI / 180)
        curIndex = 3
        for rotate = 9, 1080, 9 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            radius = radius - 3
            curIndex = curIndex + 1
        end
        
        FishTrace.scene_kind_6_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_6_trace_[fish_count + i], curIndex - 1)
        FishTrace.scene_kind_6_kind_id[fish_count + i] = 2
    end
    fish_count = fish_count + 15

    for i = 1, 15 do
        radius = 360
        curRotate = i * gapRotate
        fishPosX[1] = center.x
        fishPosY[1] = center.y
        fishPosX[2] = center.x + radius * math.cos(curRotate * self.M_PI / 180)
        fishPosY[2] = center.y + radius * math.sin(curRotate * self.M_PI / 180)
        curIndex = 3
        for rotate = 9, 1080, 9 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            radius = radius - 3
            curIndex = curIndex + 1
        end
        
        FishTrace.scene_kind_6_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_6_trace_[fish_count + i], curIndex - 1)
        FishTrace.scene_kind_6_kind_id[fish_count + i] = 0
    end
    fish_count = fish_count + 15

    for i = 1, 15 do
        radius = 360
        curRotate = i * gapRotate
        fishPosX[1] = center.x
        fishPosY[1] = center.y
        fishPosX[2] = center.x + radius * math.cos(curRotate * self.M_PI / 180)
        fishPosY[2] = center.y + radius * math.sin(curRotate * self.M_PI / 180)
        curIndex = 3
        for rotate = 9, 1080, 9 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            radius = radius - 3
            curIndex = curIndex + 1
        end
        
        FishTrace.scene_kind_6_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_6_trace_[fish_count + i], curIndex - 1)
        FishTrace.scene_kind_6_kind_id[fish_count + i] = 5
    end
    fish_count = fish_count + 15

    for i = 1, 15 do
        radius = 360
        curRotate = i * gapRotate
        fishPosX[1] = center.x
        fishPosY[1] = center.y
        fishPosX[2] = center.x + radius * math.cos(curRotate * self.M_PI / 180)
        fishPosY[2] = center.y + radius * math.sin(curRotate * self.M_PI / 180)
        curIndex = 3
        for rotate = 9, 1080, 9 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            radius = radius - 3
            curIndex = curIndex + 1
        end
        
        FishTrace.scene_kind_6_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_6_trace_[fish_count + i], curIndex - 1)
        FishTrace.scene_kind_6_kind_id[fish_count + i] = 3
    end
    fish_count = fish_count + 15

    for i = 1, 15 do
        radius = 360
        curRotate = i * gapRotate
        fishPosX[1] = center.x
        fishPosY[1] = center.y
        fishPosX[2] = center.x + radius * math.cos(curRotate * self.M_PI / 180)
        fishPosY[2] = center.y + radius * math.sin(curRotate * self.M_PI / 180)
        curIndex = 3
        for rotate = 9, 1080, 9 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            radius = radius - 3
            curIndex = curIndex + 1
        end
        
        FishTrace.scene_kind_6_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_6_trace_[fish_count + i], curIndex - 1)
        FishTrace.scene_kind_6_kind_id[fish_count + i] = 2
    end
    fish_count = fish_count + 15

    for i = 1, 15 do
        radius = 360
        curRotate = i * gapRotate
        fishPosX[1] = center.x
        fishPosY[1] = center.y
        fishPosX[2] = center.x + radius * math.cos(curRotate * self.M_PI / 180)
        fishPosY[2] = center.y + radius * math.sin(curRotate * self.M_PI / 180)
        curIndex = 3
        for rotate = 9, 1080, 9 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            radius = radius - 3
            curIndex = curIndex + 1
        end
        
        FishTrace.scene_kind_6_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_6_trace_[fish_count + i], curIndex - 1)
        FishTrace.scene_kind_6_kind_id[fish_count + i] = 0
    end
    fish_count = fish_count + 15

    for i = 1, 15 do
        radius = 360
        curRotate = i * gapRotate
        fishPosX[1] = center.x
        fishPosY[1] = center.y
        fishPosX[2] = center.x + radius * math.cos(curRotate * self.M_PI / 180)
        fishPosY[2] = center.y + radius * math.sin(curRotate * self.M_PI / 180)
        curIndex = 3
        for rotate = 9, 1080, 9 do
            fishPosX[curIndex] = radius * math.cos((curRotate + rotate) * self.M_PI / 180)
            fishPosY[curIndex] = radius * math.sin((curRotate + rotate) * self.M_PI / 180)
            radius = radius - 3
            curIndex = curIndex + 1
        end
        
        FishTrace.scene_kind_6_trace_[fish_count + i] = FishTrace:BuildTrace(fishPosX, fishPosY, FishTrace.scene_kind_6_trace_[fish_count + i], curIndex - 1)
        FishTrace.scene_kind_6_kind_id[fish_count + i] = 16
    end
    fish_count = fish_count + 15
end

function FishTrace:angle_range(angle) 
    while (angle <= -self.M_PI * 2) do
        angle =angle + self.M_PI * 2;
    end
    if angle < 0 then
        angle =angle + self.M_PI * 2
    end
    while (angle >= self.M_PI * 2) do
        angle = angle - self.M_PI * 2;
    end
    return angle;
end

function FishTrace:GetTargetPoint(screen_width,screen_height,src_x_pos,src_y_pos,angle,target_x_pos, target_y_pos) 
    angle = self:angle_range(angle);
    if angle > 0 and angle < self.M_PI_2 then
        target_x_pos = screen_width + 300;
        target_y_pos = src_y_pos + (screen_width - src_x_pos + 300) * math.tan(angle);
    elseif angle >= self.M_PI_2 and angle < self.M_PI then
        target_x_pos = -300;
        target_y_pos = src_y_pos - (src_x_pos + 300) * math.tan(angle);
    elseif angle >= self.M_PI and angle < 3 * self.M_PI / 2 then
        target_x_pos = -300;
        target_y_pos = src_y_pos - (src_x_pos + 300) * math.tan(angle);
    else 
        target_x_pos = screen_width + 300;
        target_y_pos = src_y_pos + (screen_width - src_x_pos + 300) * math.tan(angle);
    end
    return {target_x_pos,target_y_pos}
end

function FishTrace:BuildCircle(center_x,center_y,radius,fish_pos,fish_count)
    if fish_count <= 0 then 
        return
    end
    local cell_radian = 2 * self.M_PI / fish_count
    for i = 1,fish_count do
        fish_pos[i] = {}
        fish_pos[i].x = center_x + radius * math.cos(i * cell_radian)
        fish_pos[i].y = center_y + radius * math.sin(i * cell_radian)
    end
    return fish_pos
end

function FishTrace:BuildCircle2(center_x, center_y,radius, fish_pos, fish_count, rotate, rotate_speed) 
    if fish_count <= 0 then
        return;
    end
    local  cell_radian = 2 * self.M_PI / fish_count;

    local last_pos = {};
    last_pos.x = 0;
    last_pos.y = 0
    last_pos.angle = 0

    for i = 1, fish_count do
        last_pos.x = center_x + radius * math.cos(i * cell_radian + rotate - rotate_speed);
        last_pos.y = center_y + radius * math.sin(i * cell_radian + rotate - rotate_speed);
        fish_pos[i] = {}
        fish_pos[i].x = center_x + radius * math.cos(i * cell_radian + rotate);
        fish_pos[i].y = center_y + radius * math.sin(i * cell_radian + rotate);
        local temp_dis = self:CalcDistance(fish_pos[i].x, fish_pos[i].y, last_pos.x, last_pos.y);
        if temp_dis ~= 0 then
            local temp_value = (fish_pos[i].x - last_pos.x) / temp_dis;
            if fish_pos[i].y - last_pos.y >= 0 then
                fish_pos[i].angle = math.acos(temp_value);
            else 
                fish_pos[i].angle = -math.acos(temp_value);
            end
        else 
            fish_pos[i].angle = self.M_PI_2;
        end
    end
    return fish_pos
end

function FishTrace:BuildLinear(init_x,init_y,init_count, trace_vector, distance)
    trace_vector = {}
    if init_count < 2 then 
        return;
    end
    if distance <= 0 then 
        return;
    end
    local distance_total = self:CalcDistance(init_x[init_count], init_y[init_count], init_x[1], init_y[1]);
    if distance_total <= 0 then
        return;
    end
    local cos_value = math.abs(init_y[init_count] - init_y[1]) / distance_total;
    local angle = math.acos(cos_value);
    local point = {}
    point.x = init_x[1];
    point.y = init_y[1];
    table.insert(trace_vector,point)
    --trace_vector.push_back(point);
    local temp_distance = 0
    local size;
    while (temp_distance < distance_total) do
        size = #trace_vector;
        local point = {}
        if init_x[init_count] < init_x[1] then
            point.x = init_x[1] - math.sin(angle) * (distance * size);
        else 
            point.x = init_x[1] + math.sin(angle) * (distance * size);
        end

        if init_y[init_count] < init_y[1] then
            point.y = init_y[1] - math.cos(angle) * (distance * size);
        else 
            point.y = init_y[1] + math.cos(angle) * (distance * size);
        end
        table.insert(trace_vector,point)
        --trace_vector.push_back(point);
        temp_distance = self:CalcDistance(point.x, point.y, init_x[1], init_y[1]);
    end

    local  temp_point = {}
    temp_point.x = init_x[2]
    temp_point.y = init_y[2]
    trace_vector[#trace_vector] = temp_point
    return trace_vector
end

function FishTrace:BuildLinear2(init_x, init_y,init_count, trace_vector,distance)
    trace_vector = {}
    if init_count < 2 then
        return;
    end
    if distance <= 0 then
        return
    end

    local distance_total = self:CalcDistance(init_x[init_count], init_y[init_count], init_x[1], init_y[1]);
    if distance_total <= 0 then
        return;
    end

    local cos_value = math.abs(init_y[init_count] - init_y[1]) / distance_total;
    local temp_angle = math.acos(cos_value);
    local point = {};
    point.x = init_x[1];
    point.y = init_y[1];
    point.angle = 1;
    --trace_vector.push_back(point);
    table.insert(trace_vector,1,point)
    local temp_distance = 0;
    local temp_pos = {}
    temp_pos.x = 0
    temp_pos.y = 0
    temp_pos.angle = 0

    local size;
    while (temp_distance < distance_total) do
        size = #trace_vector
        if init_x[init_count] < init_x[1] then
            point.x = init_x[1] - math.sin(temp_angle) * (distance * size);
        else 
            point.x = init_x[1] + math.sin(temp_angle) * (distance * size);
        end

        if init_y[init_count] < init_y[1] then
            point.y = init_y[1] - math.cos(temp_angle) * (distance * size);
        else 
            point.y = init_y[1] + math.cos(temp_angle) * (distance * size);
        end
        local temp_dis = self:CalcDistance(point.x, point.y, temp_pos.x, temp_pos.y);
        if temp_dis ~= 0 then
            local temp_value = (point.x - temp_pos.x) / temp_dis;
            if (point.y - temp_pos.y) >= 0 then 
                point.angle = math.acos(temp_value)
            else point.angle = -math.acos(temp_value)
            end
        else 
            point.angle = 1;
        end

        temp_pos.x = point.x;
        temp_pos.y = point.y;
        table.insert(trace_vector,size+1,point)
        temp_distance = self:CalcDistance(point.x, point.y, init_x[1], init_y[1]);
    end

    local  temp_point = trace_vector[#trace_vector]
    temp_point.x = init_x[init_count];
    temp_point.y = init_y[init_count];
    trace_vector[#trace_vector] = temp_point
    return trace_vector
end

function FishTrace:CalcDistance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
end

return FishTrace
--endregion
