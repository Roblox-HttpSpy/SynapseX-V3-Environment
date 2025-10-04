--!strict

--// module requires synsignal to be accessible
export type Timer = {
	Interval: number,
	IsRunning: boolean,
	Tick: any,
	Start: (self: Timer) -> (),
	Stop: (self: Timer) -> (),
	Restart: (self: Timer) -> (),
}

local timer = {}
timer.__index = timer

function timer.new(interval: number): Timer
	local self = setmetatable({
		Interval = interval,
		IsRunning = false,
		Tick = createSignal(),
		_thread = nil :: thread?,
	}, timer)
	table.freeze(self.Tick)
	return self
end

function timer:Start()
	if self.IsRunning then return end
	self.IsRunning = true
	self._thread = task.spawn(function()
		while self.IsRunning do
			task.wait(self.Interval)
			self.Tick:Fire()
		end
	end)
end

function timer:Stop()
	self.IsRunning = false
end

function timer:Restart()
	self:Stop()
	task.wait()
	self:Start()
end

table.freeze(timer)

return timer
