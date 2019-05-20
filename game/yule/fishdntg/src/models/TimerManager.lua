local TimerManager = class("TimerManager", function()        --创建物理世界
    local gameLayer = display.newLayer()
    return gameLayer
end) 

TimerManager.kMaxDiffrence = 2000
function TimerManager:ctor()
    self.client_tick_ = currentTime()
    self.server_tick_ = currentTime()
    self.sc_diffrence_ = 0
    self.sync_elapsed_ = 0
end

function TimerManager:TimerSync(client_tick, server_tick)
    local now_tick = currentTime()
    local trade = (now_tick - client_tick) / 2
    self.server_tick_ = self.server_tick + trade
    self.sc_diffrence_ = self.server_tick_ - now_tick
end

function TimerManager:GetDelayTick(packet_tick)
    local delay = self:GetServerTick() - packet_tick
    if delay >= TimerManager.kMaxDiffrence then
        delay = TimerManager.kMaxDiffrence
    end
    return delay
end

function TimerManager:GetServerTick()
    return currentTime() + self.sc_diffrence_
end

function TimerManager:UpdateDelay(delta_time)
    self.sync_elapsed_ = self.sync_elapsed_ + delta_time
end

function TimerManager:sync_elapsed()
    return self.sync_elapsed_
end

function TimerManager:Reset()
    self.sync_elapsed_ = 0
end

return TimerManager