--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local FishTrace = class("FishTrace")
FishTrace.scene_kind_1_trace_ = {}
FishTrace.scene_kind_2_trace_ = {}
FishTrace.scene_kind_2_small_fish_stop_index_ = {}
FishTrace.scene_kind_2_small_fish_stop_count_ = 0
FishTrace.scene_kind_2_big_fish_stop_index_ = 0
FishTrace.scene_kind_2_big_fish_stop_count_ = 0
FishTrace.scene_kind_3_trace_ = {}
FishTrace.scene_kind_4_trace_ = {}
FishTrace.scene_kind_5_trace_ = {}

function FishTrace:ctor()
    self.kResolutionWidth = 1334
    self.kResolutionHeight = 750
    self.M_PI = 3.14159265358979323846
    self.M_PI_2 = 1.57079632679489661923
    self.M_PI_4 = 0.785398163397448309616
    self.M_1_PI = 0.318309886183790671538
    self.M_2_PI = 0.636619772367581343076
end

function FishTrace:BuildSceneKind1Trace(screen_width,screen_height) 
    local fish_count = 0
	local kVScale = screen_height / self.kResolutionHeight
	local kRadius = (screen_height - (240 * kVScale)) / 2
	local kSpeed = 1.5 * screen_width / self.kResolutionWidth
	local fish_pos = {}
	local center = {}
	center.x = screen_width + kRadius
	center.y = kRadius + 120 * kVScale
	self:BuildCircle(center.x, center.y, kRadius, fish_pos, 100);
	local init_x = {}
    local init_y = {}
	for i = 1,100 do
        init_x[1] = fish_pos[i].x
		init_y[1] = fish_pos[i].y
		init_x[2] = init_x[1]- screen_width -2 * kRadius
		init_y[2] = init_y[1]
		FishTrace.scene_kind_1_trace_[i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_1_trace_[i], kSpeed)
	end
	fish_count = fish_count + 100

	local kRotateRadian1 = 45 * self.M_PI / 180
	local kRotateRadian2 = 135 * self.M_PI / 180
	local kRadiusSmall = kRadius / 2
	local kRadiusSmall1 = kRadius / 3
	local center_small = {{},{},{},{}}
	center_small[1].x = center.x + kRadiusSmall * math.cos(-kRotateRadian2);
	center_small[1].y = center.y + kRadiusSmall * math.sin(-kRotateRadian2);
	center_small[2].x = center.x + kRadiusSmall * math.cos(-kRotateRadian1);
	center_small[2].y = center.y + kRadiusSmall * math.sin(-kRotateRadian1);
	center_small[3].x = center.x + kRadiusSmall * math.cos(kRotateRadian2);
	center_small[3].y = center.y + kRadiusSmall * math.sin(kRotateRadian2);
	center_small[4].x = center.x + kRadiusSmall * math.cos(kRotateRadian1);
    center_small[4].y = center.y + kRadiusSmall * math.sin(kRotateRadian1);

    fish_pos = self:BuildCircle(center_small[1].x, center_small[1].y, kRadiusSmall1, fish_pos, 17);
    for  i = 1,17 do
        init_x[1] = fish_pos[i].x;
        init_y[1] = fish_pos[i].y;
        init_x[2] = init_x[1]- screen_width -2 * kRadius;
        init_y[2] = init_y[1];
        FishTrace.scene_kind_1_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_1_trace_[fish_count + i], kSpeed);
    end
    fish_count = fish_count + 17;

    fish_pos = self:BuildCircle(center_small[2].x, center_small[2].y, kRadiusSmall1, fish_pos, 17);
    for  i = 1,17 do
        init_x[1] = fish_pos[i].x;
        init_y[1] = fish_pos[i].y;
        init_x[2] = init_x[1]- screen_width -2 * kRadius;
        init_y[2] = init_y[1];
        FishTrace.scene_kind_1_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_1_trace_[fish_count + i], kSpeed);
    end
    fish_count = fish_count + 17;

    fish_pos = self:BuildCircle(center_small[3].x, center_small[3].y, kRadiusSmall1, fish_pos, 30);
    for i = 1,30 do
        init_x[1] = fish_pos[i].x;
        init_y[1] = fish_pos[i].y;
        init_x[2] = init_x[1]- screen_width -2 * kRadius;
        init_y[2] = init_y[1];
        FishTrace.scene_kind_1_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_1_trace_[fish_count + i], kSpeed);
    end
    fish_count = fish_count + 30;

    fish_pos = self:BuildCircle(center_small[4].x, center_small[4].y, kRadiusSmall1, fish_pos, 30);
    for i = 1,30 do
        init_x[1] = fish_pos[i].x;
        init_y[1] = fish_pos[i].y;
        init_x[2] = init_x[1]- screen_width -2 * kRadius;
        init_y[2] = init_y[1];
        FishTrace.scene_kind_1_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_1_trace_[fish_count + i], kSpeed);
    end
    fish_count = fish_count + 30;

    fish_pos = self:BuildCircle(center.x, center.y, kRadiusSmall / 2, fish_pos, 15);
    for  i = 1, 15 do
        init_x[1] = fish_pos[i].x;
        init_y[1] = fish_pos[i].y;
        init_x[2] = init_x[1]- screen_width -2 * kRadius;
        init_y[2] = init_y[1];
        FishTrace.scene_kind_1_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_1_trace_[fish_count + i], kSpeed);
    end
    fish_count = fish_count + 15;

    init_x[1] = center.x;
    init_y[1] = center.y;
    init_x[2] = init_x[1]- screen_width -2 * kRadius;
    init_y[2] = init_y[1];
    fish_count = fish_count + 1;
    FishTrace.scene_kind_1_trace_[fish_count] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_1_trace_[fish_count], kSpeed);
end

function FishTrace:BuildSceneKind2Trace(screen_width,screen_height) 
    local kHScale = screen_width / self.kResolutionWidth;
    local kVScale = screen_height / self.kResolutionHeight;
    local kStopExcursion = 180 * kVScale;
    local kHExcursion = 27 * kHScale / 2;
    local kSmallFishInterval = (screen_width - kHExcursion * 2) / 100;
    local kSmallFishHeight = 65 * kVScale;
    local kSpeed = 3 * kHScale;
    local fish_count = 0;
    local init_x = {{},{}}
    local init_y = {{},{}}
    local small_height = math.floor(kSmallFishHeight * 3);
    for i = 1, 200 do 
        init_x[1] = kHExcursion + (i % 100) * kSmallFishInterval;
        init_x[2] = kHExcursion + (i % 100) * kSmallFishInterval;
        local excursion = math.random(0,small_height) 
        if i < 100 then
            init_y[1] = -65 - excursion;
            init_y[2] = screen_height + 65;
        else 
            init_y[1] = screen_height + 65 + excursion;
            init_y[2] = -65;
        end
        FishTrace.scene_kind_2_trace_[i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_2_trace_[i], kSpeed);
    end
    fish_count =fish_count + 200;

    -- local big_fish_width = { 126 * kHScale, 175 * kHScale, 229 * kHScale, 230 * kHScale, 238 * kHScale, 240 * kHScale, 300 * kHScale };
    local big_fish_width = { 300 * kHScale, 320 * kHScale, 340 * kHScale, 375 * kHScale, 380 * kHScale, 380 * kHScale, 400 * kHScale };
    local big_fish_excursion = {};
    for i = 1, 7 do
        big_fish_excursion[i] = big_fish_width[i];
        for  j = 1, i do
            big_fish_excursion[i] = big_fish_excursion[i] + big_fish_width[j];
        end
    end
    local  y_excursoin = 250 * kVScale / 2;

    for i = 1, 14 do
        if i <= 7 then
            init_y[1] = screen_height / 2 - y_excursoin;
            init_y[2] = screen_height / 2 - y_excursoin;
            init_x[1] = -big_fish_excursion[i];
            init_x[2] = screen_width + big_fish_width[i];
            FishTrace.scene_kind_2_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_2_trace_[fish_count + i], kSpeed);
        else 
            init_y[1] = screen_height / 2 + y_excursoin;
            init_y[2] = screen_height / 2 + y_excursoin;
            init_x[1] = screen_width + big_fish_excursion[i-7];
            init_x[2] = -big_fish_width[i-7];
            FishTrace.scene_kind_2_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_2_trace_[fish_count + i], kSpeed);
        end
    end
    fish_count = fish_count + 14;

    local  small_fish_trace = {};
    init_x[1] = 0
    init_x[2] = 0
    init_y[1] = -2 * kSmallFishHeight;
    init_y[2] = kStopExcursion;
    small_fish_trace = self:BuildLinear(init_x, init_y, 2, small_fish_trace, kSpeed);

    local big_fish_trace;
    init_y[1] = 0
    init_y[2] = 0
    init_x[1] = -big_fish_excursion[6];
    init_x[2] = screen_width + big_fish_width[6];
    big_fish_trace = self:BuildLinear(init_x, init_y, 2, big_fish_trace, kSpeed);

    local  big_stop_count = 0;
    for i = 1, 200 do
        for j = 1 , #FishTrace.scene_kind_2_trace_[i] do
            local  pos = FishTrace.scene_kind_2_trace_[i][j];
            if i <= 100 then
                if pos.y >= kStopExcursion then
                    FishTrace.scene_kind_2_small_fish_stop_index_[i] = j;
                    if big_stop_count == 0 then 
                        big_stop_count = j;
                    elseif big_stop_count <= j then
                        big_stop_count = j;
                    end
                    break;
                end
            else 
                if pos.y < screen_height - kStopExcursion then
                    FishTrace.scene_kind_2_small_fish_stop_index_[i] = j;
                    if big_stop_count == 0 then 
                        big_stop_count = j;
                    elseif big_stop_count < j then 
                        big_stop_count = j;
                    end
                    break
                end
            end
        end
    end

    FishTrace.scene_kind_2_small_fish_stop_count_ = #big_fish_trace;
    FishTrace.scene_kind_2_big_fish_stop_index_ = 0;
    FishTrace.scene_kind_2_big_fish_stop_count_ = big_stop_count + 1;
end

function FishTrace:BuildSceneKind3Trace(screen_width,screen_height) 
    local fish_count = 0;
    local kVScale = screen_height / self.kResolutionHeight;
    local kRadius = (screen_height - (240 * kVScale)) / 2;
    local kSpeed = 1.5 * screen_width / self.kResolutionWidth;
    local fish_pos = {};
    local center = {};
    center.x = screen_width + kRadius;
    center.y = kRadius + 120 * kVScale;
    fish_pos = self:BuildCircle(center.x, center.y, kRadius, fish_pos, 50);
    local init_x = {{},{}} 
    local init_y = {{},{}}
    for i =1, 50 do
        init_x[1] = fish_pos[i].x;
        init_y[1] = fish_pos[i].y;
        init_x[2] = fish_pos[i].x - screen_width -2 * kRadius;
        init_y[2] = init_y[1];
        FishTrace.scene_kind_3_trace_[i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_3_trace_[i], kSpeed);
    end
    fish_count = fish_count + 50;
    fish_pos = self:BuildCircle(center.x, center.y, kRadius * 40 / 50, fish_pos, 40);
    for i = 1, 40 do
        init_x[1] = fish_pos[i].x;
        init_y[1] = fish_pos[i].y;
        init_x[2] = fish_pos[i].x - screen_width -2 * kRadius;
        init_y[2] = init_y[1];
        FishTrace.scene_kind_3_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_3_trace_[fish_count + i], kSpeed);
    end
    fish_count = fish_count + 40;

    fish_pos = self:BuildCircle(center.x, center.y, kRadius * 30 / 50, fish_pos, 30);
    for i = 1, 30 do
        init_x[1] = fish_pos[i].x;
        init_y[1] = fish_pos[i].y;
        init_x[2] = fish_pos[i].x - screen_width -2 * kRadius;
        init_y[2] = init_y[1];
        FishTrace.scene_kind_3_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_3_trace_[fish_count + i], kSpeed);
    end
    fish_count = fish_count +30;

    init_x[1] = center.x;
    init_y[1] = center.y;
    init_x[2] = init_x[1] - screen_width-2 * kRadius;
    init_y[2] = init_y[1];
    fish_count = fish_count + 1;
    FishTrace.scene_kind_3_trace_[fish_count] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_3_trace_[fish_count], kSpeed);
  
    center.x = -kRadius;
    fish_pos = self:BuildCircle(center.x, center.y, kRadius, fish_pos, 50);
    for i = 1,50 do
        init_x[1] = fish_pos[i].x;
        init_y[1] = fish_pos[i].y;
        init_x[2] = screen_width + init_x[1] + 2 * kRadius;
        init_y[2] = init_y[1];
        FishTrace.scene_kind_3_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2,FishTrace.scene_kind_3_trace_[fish_count + i], kSpeed);
    end
    fish_count = fish_count + 50;

    fish_pos = self:BuildCircle(center.x, center.y, kRadius * 40 / 50, fish_pos, 40);
    for i = 1, 40 do
        init_x[1] = fish_pos[i].x;
        init_y[1] = fish_pos[i].y;
        init_x[2] = screen_width + init_x[1] + 2 * kRadius;
        init_y[2] = init_y[1];
        FishTrace.scene_kind_3_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_3_trace_[fish_count + i], kSpeed);
    end
    fish_count = fish_count + 40;

    fish_pos = self:BuildCircle(center.x, center.y, kRadius * 30 / 50, fish_pos, 30);
    for i =1, 30 do
        init_x[1] = fish_pos[i].x;
        init_y[1] = fish_pos[i].y;
        init_x[2] = screen_width + init_x[1] + 2 * kRadius;
        init_y[2] = init_y[1];
        FishTrace.scene_kind_3_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_3_trace_[fish_count + i], kSpeed);
    end
    fish_count = fish_count + 30;

    init_x[1] = center.x;
    init_y[1] = center.y;
    init_x[2] = screen_width + init_x[1] + 2 * kRadius;
    init_y[2] = init_y[1];
    fish_count = fish_count + 1;
    FishTrace.scene_kind_3_trace_[fish_count] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_3_trace_[fish_count], kSpeed);
end

function FishTrace:BuildSceneKind4Trace(screen_width,screen_height) 
    local kHScale = screen_width / self.kResolutionWidth;
    local kVScale = screen_height / self.kResolutionHeight
    local kSpeed = 3 * kHScale;
    local kFishWidth = 512 * kHScale;
    local kFishHeight = 304 * kVScale;

    local fish_count = 0;
    local init_x = {{},{}}
    local init_y = {{},{}}

    local start_pos ={}
    start_pos.x = 0
    start_pos.y = screen_height - kFishHeight / 2
    --左上（算法正常）
    local target_pos = {}
    target_pos.x = screen_width - kFishHeight / 2
    target_pos.y = 0
    local angle = math.acos((target_pos.x - start_pos.x) / self:CalcDistance(target_pos.x, target_pos.y, start_pos.x, start_pos.y));
    local radius = kFishWidth * 4;
    local length = radius + kFishWidth / 2
    local center_pos = {}
    center_pos.x = -length * math.cos(angle);
    center_pos.y = start_pos.y + length * math.sin(angle);
    init_x[2] = target_pos.x + kFishWidth;
    init_y[2] = target_pos.y - kFishHeight;
    for i = 1, 8 do
        if radius < 0 then
            init_x[1] = center_pos.x + radius * math.cos(angle);
            init_y[1] = center_pos.y - radius * math.sin(angle);
        else 
            init_x[1] = center_pos.x - radius * math.cos(angle + self.M_PI);
            init_y[1] = center_pos.y + radius * math.sin(angle + self.M_PI);
        end
        FishTrace.scene_kind_4_trace_[i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_4_trace_[i], kSpeed);
        radius = radius - kFishWidth;
    end
    fish_count = fish_count + 8;

    start_pos.x = kFishHeight / 2;
    start_pos.y = screen_height;
    target_pos.x = screen_width;
    target_pos.y = kFishHeight / 2;
    angle = math.acos((target_pos.x - start_pos.x) / self:CalcDistance(target_pos.x, target_pos.y, start_pos.x, start_pos.y));
    radius = kFishWidth * 4;
    length = radius + kFishWidth / 2;
    center_pos.x = start_pos.x - length * math.cos(angle);
    center_pos.y = start_pos.y + length * math.sin(angle);
    init_x[2] = target_pos.x + kFishWidth;
    init_y[2] = target_pos.y - kFishHeight;
    for i = 1,8 do
        if radius < 0 then
            init_x[1] = center_pos.x + radius * math.cos(angle);
            init_y[1] = center_pos.y - radius * math.sin(angle);
        else 
            init_x[1] = center_pos.x - radius * math.cos(angle + self.M_PI);
            init_y[1] = center_pos.y + radius * math.sin(angle + self.M_PI);
        end
        FishTrace.scene_kind_4_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_4_trace_[fish_count + i], kSpeed);
        radius = radius - kFishWidth;
    end
    fish_count = fish_count + 8;

    --右上
    start_pos.x = screen_width - kFishHeight / 2;
    start_pos.y = screen_height;
    target_pos.x = 0;
    target_pos.y = kFishHeight / 2;
    angle = math.acos((start_pos.x - target_pos.x) / self:CalcDistance(target_pos.x, target_pos.y, start_pos.x, start_pos.y));
    radius = kFishWidth * 4;
    length = radius + kFishWidth / 2;
    center_pos.x = start_pos.x + length * math.cos(angle);
    center_pos.y = start_pos.y + length * math.sin(angle);
    init_x[2] = target_pos.x - kFishWidth;
    init_y[2] = target_pos.y - kFishHeight;
    for i = 1, 8 do
        if radius < 0 then
            init_x[1] = center_pos.x + radius * math.cos(angle + self.M_PI);
            init_y[1] = center_pos.y + radius * math.sin(angle + self.M_PI);
        else 
            init_x[1] = center_pos.x - radius * math.cos(angle);
            init_y[1] = center_pos.y - radius * math.sin(angle);
        end
        FishTrace.scene_kind_4_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_4_trace_[fish_count + i], kSpeed);
        radius = radius - kFishWidth;
    end
    fish_count = fish_count + 8;

    start_pos.x = screen_width;
    start_pos.y = screen_height - kFishHeight / 2;
    target_pos.x = kFishHeight / 2;
    target_pos.y = 0;
    angle = math.acos((start_pos.x - target_pos.x) / self:CalcDistance(target_pos.x, target_pos.y, start_pos.x, start_pos.y));
    radius = kFishWidth * 4;
    length = radius + kFishWidth / 2;
    center_pos.x = start_pos.x + length * math.cos(angle);
    center_pos.y = start_pos.y + length * math.sin(angle);
    init_x[2] = target_pos.x - kFishWidth;
    init_y[2] = target_pos.y - kFishHeight;
    for i = 1, 8 do
        if radius < 0 then
            init_x[1] = center_pos.x - radius * math.cos(angle + self.M_PI);
            init_y[1] = center_pos.y - radius * math.sin(angle + self.M_PI);
        else 
            init_x[1] = center_pos.x - radius * math.cos(angle);
            init_y[1] = center_pos.y - radius * math.sin(angle);
        end
        FishTrace.scene_kind_4_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_4_trace_[fish_count + i], kSpeed);
        radius = radius - kFishWidth;
    end
    fish_count = fish_count + 8;
    --右下
    start_pos.x = screen_width;
    start_pos.y = kFishHeight / 2;
    target_pos.x = kFishHeight / 2;
    target_pos.y = screen_height;
    angle = math.acos((start_pos.x - target_pos.x) / self:CalcDistance(target_pos.x, target_pos.y, start_pos.x, start_pos.y));
    radius = kFishWidth * 4;
    length = radius + kFishWidth / 2;
    center_pos.x = start_pos.x + length * math.cos(angle);
    center_pos.y = start_pos.y - length * math.sin(angle);
    init_x[2] = target_pos.x - kFishWidth;
    init_y[2] = target_pos.y + kFishHeight;
    for i = 1, 8 do
        if radius < 0 then
            init_x[1] = center_pos.x + radius * math.cos(-angle - self.M_PI)
            init_y[1] = center_pos.y + radius * math.sin(-angle - self.M_PI)
        else 
            init_x[1] = center_pos.x - radius * math.cos(-angle)
            init_y[1] = center_pos.y - radius * math.sin(-angle)
        end
        FishTrace.scene_kind_4_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_4_trace_[fish_count + i], kSpeed);
        radius = radius - kFishWidth;
    end
    fish_count = fish_count + 8;

    start_pos.x = screen_width - kFishHeight / 2;
    start_pos.y = 0;
    target_pos.x = 0;
    target_pos.y = screen_height - kFishHeight / 2;
    angle = math.acos((start_pos.x - target_pos.x) / self:CalcDistance(target_pos.x, target_pos.y, start_pos.x, start_pos.y));
    radius = kFishWidth * 4;
    length = radius + kFishWidth / 2;
    center_pos.x = start_pos.x + length * math.cos(angle);
    center_pos.y = start_pos.y - length * math.sin(angle);
    init_x[2] = target_pos.x - kFishWidth;
    init_y[2] = target_pos.y + kFishHeight;
    for i = 1, 8 do
        if radius < 0 then
            init_x[1] = center_pos.x + radius * math.cos(-angle - self.M_PI);
            init_y[1] = center_pos.y + radius * math.sin(-angle - self.M_PI);
        else 
            init_x[1] = center_pos.x - radius * math.cos(-angle);
            init_y[1] = center_pos.y - radius * math.sin(-angle);
        end
        FishTrace.scene_kind_4_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_4_trace_[fish_count + i], kSpeed);
        radius = radius - kFishWidth;
    end
    fish_count = fish_count + 8;
    --左下
    start_pos.x = kFishHeight / 2;
    start_pos.y = 0
    target_pos.x = screen_width;
    target_pos.y = screen_height - kFishHeight / 2;
    angle = math.acos((target_pos.x - start_pos.x) / self:CalcDistance(target_pos.x, target_pos.y, start_pos.x, start_pos.y));
    radius = kFishWidth * 4;
    length = radius + kFishWidth / 2;
    center_pos.x = start_pos.x - length * math.cos(angle);
    center_pos.y = start_pos.y - length * math.sin(angle);
    init_x[2] = target_pos.x + kFishWidth;
    init_y[2] = target_pos.y + kFishHeight;
    for i = 1, 8 do
        if radius < 0 then
            init_x[1] = center_pos.x - radius * math.cos(angle + self.M_PI);
            init_y[1] = center_pos.y - radius * math.sin(angle + self.M_PI);
        else 
            init_x[1] = center_pos.x + radius * math.cos(angle);
            init_y[1] = center_pos.y + radius * math.sin(angle);
        end
        FishTrace.scene_kind_4_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_4_trace_[fish_count + i], kSpeed);
        radius = radius - kFishWidth;
    end
    fish_count = fish_count + 8;

    start_pos.x = 0;
    start_pos.y = kFishHeight / 2;
    target_pos.x = screen_width - kFishHeight / 2;
    target_pos.y = screen_height;
    angle = math.acos((target_pos.x - start_pos.x) / self:CalcDistance(target_pos.x, target_pos.y, start_pos.x, start_pos.y));
    radius = kFishWidth * 4;
    length = radius + kFishWidth / 2;
    center_pos.x = start_pos.x - length * math.cos(angle);
    center_pos.y = start_pos.y - length * math.sin(angle);
    init_x[2] = target_pos.x + kFishWidth;
    init_y[2] = target_pos.y + kFishHeight;
    for i = 1, 8 do
        if radius < 0 then
            init_x[1] = center_pos.x - radius * math.cos(angle + self.M_PI);
            init_y[1] = center_pos.y - radius * math.sin(angle + self.M_PI);
        else 
            init_x[1] = center_pos.x + radius * math.cos(angle);
            init_y[1] = center_pos.y + radius * math.sin(angle);
        end
        FishTrace.scene_kind_4_trace_[fish_count + i] = self:BuildLinear(init_x, init_y, 2, FishTrace.scene_kind_4_trace_[fish_count + i], kSpeed);
        radius = radius - kFishWidth;
    end
    fish_count = fish_count + 8;
end

function FishTrace:BuildSceneKind5Trace(screen_width,screen_height)
    local fish_count = 0;
    local kVScale = screen_height / self.kResolutionHeight
    local kRadius = (screen_height - (200 * kVScale)) / 2;
    local kRotateSpeed = 1.5 * self.M_PI / 180;
    local kSpeed = 5 * screen_width / self.kResolutionWidth
    local fish_pos = {}
    local center= {{},{}}
    center[1].x = screen_width / 4
    center[1].y = kRadius + 100 * kVScale;
    center[2].x = screen_width - screen_width / 4
    center[2].y = kRadius + 100 * kVScale;

    local kLFish1Rotate = 720 * self.M_PI / 180
    local kRFish2Rotate = (720 + 90) * self.M_PI / 180;
    local kRFish5Rotate = (720 + 180) * self.M_PI / 180;
    local kLFish3Rotate = (720 + 180 + 45) * self.M_PI / 180;
    local kLFish4Rotate = (720 + 180 + 90) * self.M_PI / 180;
    local kRFish6Rotate = (720 + 180 + 90 + 30) * self.M_PI / 180;
    local kRFish7Rotate = (720 + 180 + 90 + 60) * self.M_PI / 180;
    local kLFish6Rotate = (720 + 180 + 90 + 60 + 30) * self.M_PI / 180;
    local kLFish18Rotate = (720 + 180 + 90 + 60 + 60) * self.M_PI / 180;
    local kRFish17Rotate = (720 + 180 + 90 + 60 + 60 + 30) * self.M_PI / 180;
    for i = 1,236 do
        FishTrace.scene_kind_5_trace_[i] = {}
    end
  
    for rotate = 0,  kLFish1Rotate ,kRotateSpeed do
        fish_pos = self:BuildCircle2(center[1].x, center[1].y, kRadius, fish_pos, 40, rotate, kRotateSpeed);
        for  j = 1, 40 do
            table.insert(FishTrace.scene_kind_5_trace_[j],fish_pos[j])
        end
    end
    fish_count = fish_count + 40;
    for  rotate = 0, kRFish2Rotate,kRotateSpeed do
        fish_pos = self:BuildCircle2(center[2].x, center[2].y, kRadius, fish_pos, 40, rotate, kRotateSpeed);
        for  j = 1, 40 do
            table.insert(FishTrace.scene_kind_5_trace_[fish_count + j],fish_pos[j])
        end
    end
    fish_count = fish_count + 40;

    for rotate = 0, kRFish5Rotate,kRotateSpeed do
        fish_pos = self:BuildCircle2(center[2].x, center[2].y, kRadius - 34.5 * kVScale, fish_pos, 40, rotate, kRotateSpeed);
        for  j = 1, 40 do
            table.insert(FishTrace.scene_kind_5_trace_[fish_count + j],fish_pos[j])
        end
    end
    fish_count = fish_count + 40;
    for rotate = 0, kLFish3Rotate,kRotateSpeed do
        fish_pos = self:BuildCircle2(center[1].x, center[1].y, kRadius - 36 * kVScale, fish_pos, 40, rotate, kRotateSpeed);
        for j = 1, 40 do
            table.insert(FishTrace.scene_kind_5_trace_[fish_count + j],fish_pos[j])
        end
    end
    fish_count = fish_count + 40;

    for rotate = 0, kLFish4Rotate, kRotateSpeed do
        fish_pos = self:BuildCircle2(center[1].x, center[1].y, kRadius - 36 * kVScale - 56 * kVScale, fish_pos, 24, rotate, kRotateSpeed);
        for j = 1, 24 do
            table.insert(FishTrace.scene_kind_5_trace_[fish_count + j],fish_pos[j])
        end
    end
    fish_count = fish_count + 24;
    for rotate = 0,  kRFish6Rotate, kRotateSpeed do
        fish_pos = self:BuildCircle2(center[2].x, center[2].y, kRadius - 34.5 * kVScale - 58.5 * kVScale, fish_pos, 24, rotate, kRotateSpeed);
        for j = 1, 24 do
            table.insert(FishTrace.scene_kind_5_trace_[fish_count + j],fish_pos[j])
        end
    end
    fish_count = fish_count + 24;

    for  rotate = 0, kRFish7Rotate, kRotateSpeed do
        fish_pos = self:BuildCircle2(center[2].x, center[2].y, kRadius - 34.5 * kVScale - 58.5 * kVScale - 65 * kVScale, fish_pos, 13, rotate, kRotateSpeed);
        for j = 1, 13 do
            table.insert(FishTrace.scene_kind_5_trace_[fish_count + j],fish_pos[j])
        end
    end
    fish_count = fish_count + 13;
    for  rotate = 0, kLFish6Rotate,kRotateSpeed do
        fish_pos = self:BuildCircle2(center[1].x, center[1].y, kRadius - 36 * kVScale - 56 * kVScale - 68 * kVScale, fish_pos, 13, rotate, kRotateSpeed);
        for j = 1,13 do
            table.insert(FishTrace.scene_kind_5_trace_[fish_count + j],fish_pos[j])
        end
    end
    fish_count = fish_count + 13;
  
    for  rotate = 0, kLFish18Rotate, kRotateSpeed do
        fish_pos[1] = {}
        fish_pos[1].x = center[1].x;
        fish_pos[1].y = center[1].y;
        fish_pos[1].angle = -self.M_PI_2 + rotate;
        table.insert(FishTrace.scene_kind_5_trace_[fish_count + 1],fish_pos[1])
    end
    fish_count = fish_count + 1;
    for  rotate = 0, kRFish17Rotate, kRotateSpeed do
        fish_pos[1] = {}
        fish_pos[1].x = center[2].x;
        fish_pos[1].y = center[2].y;
        fish_pos[1].angle = -self.M_PI_2 + rotate;
        table.insert(FishTrace.scene_kind_5_trace_[fish_count + 1],fish_pos[1])
    end
    fish_count = fish_count + 1;

    for  i = 1,fish_count do
        local  init_x = {{},{}} 
        local  init_y = {{},{}}
        local  temp_vector = {}
        local  size = #FishTrace.scene_kind_5_trace_[i]
        local  pos = FishTrace.scene_kind_5_trace_[i][size]
        init_x[1] = pos.x;
        init_y[1] = pos.y;
        local posT = self:GetTargetPoint(screen_width, screen_height, pos.x, pos.y, pos.angle, init_x[2], init_y[2]);
        init_x[2] = posT[1]
        init_y[2] = posT[2]
        temp_vector = self:BuildLinear2(init_x, init_y, 2, temp_vector, kSpeed);
        temp_vector[1].angle = pos.angle;
        temp_vector[2].angle = pos.angle;
    
        FishTrace.scene_kind_5_trace_[i][size + 1] = temp_vector[1]
        FishTrace.scene_kind_5_trace_[i][size + 2] = temp_vector[2]
    end
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
