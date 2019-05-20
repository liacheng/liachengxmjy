--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ScreenShaker = class("ScreenShaker")
local scheduler = cc.Director:getInstance():getScheduler()

function ScreenShaker:ctor(target, time)
    self.init_x = 0         --[[初始位置x]]
    self.init_y = 0         --[[初始位置y]]
    self.diff_x = 0         --[[偏移量x]]
    self.diff_y = 0         --[[偏移量y]]
    self.diff_max = 20      --[[最大偏移量]]
    self.interval = 0.01    --[[震动频率]]
    self.totalTime = 0      --[[震动时间]]
    self.time = 0           --[[计时器]]
    self.scheduler = nil
    self.target = target
    self.init_x = target:getPositionX()
    self.init_y = target:getPositionY()
    self.totalTime = time
end

function ScreenShaker:run()
    local function updateScreenShaker(dt)
        self:shake(dt)
	end
	--定时器
	if nil == self.scheduler then
        self.scheduler = scheduler:scheduleScriptFunc(updateScreenShaker, self.interval, false)
	end
    --[[self.scheduler = scheduler.scheduleGlobal(function (ft)
    self:shake(ft)
    end, self.interval)
    ]]
end

function ScreenShaker:shake(ft)
    if self.time >= self.totalTime then
        self:stop()
        return
    end
    self.time = self.time+ft
    self.diff_x = math.random(-self.diff_max, self.diff_max)*math.random()
    self.diff_y = math.random(-self.diff_max, self.diff_max)*math.random()
    if self.target ~= nil then
        self.target:setPosition(cc.p(self.init_x+self.diff_x, self.init_y+self.diff_y))
    end
end

function ScreenShaker:stop()
    self.time = 0
    if nil ~= self.scheduler then
        scheduler:unscheduleScriptEntry(self.scheduler)
	    self.scheduler = nil
	end
    --scheduler.unscheduleGlobal(self.scheduler)
    if self.target ~= nil then
        self.target:setPosition(cc.p(self.init_x, self.init_y))
    end
end

return ScreenShaker
--endregion
