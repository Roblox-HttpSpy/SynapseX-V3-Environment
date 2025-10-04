--!strict
export type Stopwatch = {
	IsRunning: boolean,
	Start: (self: Stopwatch) -> (),
	Stop: (self: Stopwatch) -> (),
	Restart: (self: Stopwatch) -> (),
	Reset: (self: Stopwatch) -> (),
	Elapsed: (self: Stopwatch) -> number,
}

local stopwatch = {}
stopwatch.__index = stopwatch

function stopwatch.new(): Stopwatch
	local self = setmetatable({
		IsRunning = false,
		_start = 0,
		_elapsed = 0,
	}, stopwatch)
	return self
end

function stopwatch:Start()
	if not self.IsRunning then
		self.IsRunning = true
		self._start = os.clock()
	end
end

function stopwatch:Stop()
	if self.IsRunning then
		self._elapsed += os.clock() - self._start
		self.IsRunning = false
	end
end

function stopwatch:Restart()
	self._elapsed = 0
	self._start = os.clock()
	self.IsRunning = true
end

function stopwatch:Reset()
	self._elapsed = 0
	self.IsRunning = false
end

function stopwatch:ElapsedTime(): number
	if self.IsRunning then
		return self._elapsed + (os.clock() - self._start)
	else
		return self._elapsed
	end
end

table.freeze(stopwatch)
return stopwatch