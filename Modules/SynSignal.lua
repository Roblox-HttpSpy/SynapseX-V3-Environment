--!strict

local function createSignal()
	local signal = {}
	signal._handlers = {}

	function signal:Connect(fn: (...any) -> ())
		local handler = {fn = fn, connected = true}
		table.insert(self._handlers, handler)
		return {
			Disconnect = function()
				handler.connected = false
			end,
		}
	end

	function signal:Wait(): ...any
		local thread = coroutine.running()
		local conn
		conn = self:Connect(function(...)
			conn.Disconnect()
			task.spawn(thread, ...)
		end)
		return coroutine.yield()
	end

	function signal:Once(fn: (...any) -> ())
		local conn
		conn = self:Connect(function(...)
			conn.Disconnect()
			fn(...)
		end)
		return conn
	end

	function signal:Fire(...)
		for _, h in ipairs(self._handlers) do
			if h.connected then
				h.fn(...)
			end
		end
	end

	function signal:DisconnectAll()
		for _, h in ipairs(self._handlers) do
			h.connected = false
		end
		self._handlers = {}
	end

	table.freeze(signal)
	return signal
end

export type SynSignal = {
	Connect: (self: SynSignal, fn: (...any) -> ()) -> { Disconnect: () -> () },
	Once: (self: SynSignal, fn: (...any) -> ()) -> { Disconnect: () -> () },
	Wait: (self: SynSignal) -> ...any,
	Fire: (self: SynSignal, ...any) -> (),
	DisconnectAll: (self: SynSignal) -> (),
}

local SynSignal = {}
SynSignal.__index = SynSignal

function SynSignal.new(): SynSignal
	local self = setmetatable(createSignal(), SynSignal)
	return self
end

table.freeze(SynSignal)
return SynSignal