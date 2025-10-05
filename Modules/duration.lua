--!strict
export type Duration = {
	ns: number,
	us: number,
	ms: number,
	s: number,
	min: number,
	h: number,
	d: number,
	mo: number,
	y: number,
}

local duration: {
	TimeSinceEpoch: () -> Duration,
	FromNanoseconds: (number) -> Duration,
	FromMicroseconds: (number) -> Duration,
	FromMilliseconds: (number) -> Duration,
	FromSeconds: (number) -> Duration,
	FromMinutes: (number) -> Duration,
	FromHours: (number) -> Duration,
	FromDays: (number) -> Duration,
	FromMonths: (number) -> Duration,
	FromYears: (number) -> Duration,
} = {}

local ns_us = 1_000
local ns_ms = 1_000_000
local ns_s = 1_000_000_000
local s_min = 60
local s_hr = 60 * s_min
local s_day = 24 * s_hr
local d_mo = 30
local mo_y = 12

local function makeDur(ns: number): Duration
	local s = ns / ns_s
	local min = s / s_min
	local h = s / s_hr
	local d = s / s_day
	local mo = d / d_mo
	local y = mo / mo_y

	local obj: Duration = {
		ns = ns,
		us = ns / ns_us,
		ms = ns / ns_ms,
		s = s,
		min = min,
		h = h,
		d = d,
		mo = mo,
		y = y,
	}

	table.freeze(obj)
	return obj
end

function duration.TimeSinceEpoch(): Duration
	local secs = os.time()
	return makeDur(secs * ns_s)
end

function duration.FromNanoseconds(ns: number): Duration
	return makeDur(ns)
end

function duration.FromMicroseconds(us: number): Duration
	return makeDur(us * ns_us)
end

function duration.FromMilliseconds(ms: number): Duration
	return makeDur(ms * ns_ms)
end

function duration.FromSeconds(s: number): Duration
	return makeDur(s * ns_s)
end

function duration.FromMinutes(min: number): Duration
	return duration.FromSeconds(min * s_min)
end

function duration.FromHours(h: number): Duration
	return duration.FromMinutes(h * s_hr / s_min)
end

function duration.FromDays(d: number): Duration
	return duration.FromHours(d * (s_day / s_hr))
end

function duration.FromMonths(mo: number): Duration
	return duration.FromDays(mo * d_mo)
end

function duration.FromYears(y: number): Duration
	return duration.FromMonths(y * mo_y)
end

table.freeze(duration)
return duration


--// example script
local Duration = require(path.to.duration)

local d1 = Duration.FromSeconds(90)
print("Seconds:", d1.s)
print("Minutes:", d1.min)
print("Milliseconds:", d1.ms)

local d2 = Duration.TimeSinceEpoch()
print("Time since epoch (seconds):", d2.s)

local d3 = Duration.FromHours(2)
print("Hours:", d3.h)
print("Seconds in 2 hours:", d3.s)