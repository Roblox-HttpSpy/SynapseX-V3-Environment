--!strict
local bit = {}

local MASK = 0xFFFFFFFF
local WORD = 2 ^ 32
local HALF = 2 ^ 31

local function toUint32(x: number): number
	return (x % WORD)
end

local function toSigned32(x: number): number
	local u = toUint32(x)
	if u >= HALF then
		return u - WORD
	end
	return u
end

local function signedReturn(u: number): number
	return toSigned32(u)
end

local function foldBinary(func, ...)
	local args = table.pack(...)
	assert(args.n >= 1, "expected at least one argument")
	local acc = toUint32(args[1])
	for i = 2, args.n do
		acc = toUint32(func(acc, toUint32(args[i])))
	end
	return acc
end

function bit.badd(...: number)
	local acc = table.pack(...); assert(acc.n >= 1)
	local sum = 0
	for i = 1, acc.n do sum = (sum + toUint32(acc[i])) % WORD end
	return signedReturn(sum)
end

function bit.bsub(...: number)
	local acc = table.pack(...); assert(acc.n >= 1)
	local res = toUint32(acc[1])
	for i = 2, acc.n do res = (res - toUint32(acc[i])) % WORD end
	return signedReturn(res)
end

function bit.bmul(...: number)
	local acc = table.pack(...); assert(acc.n >= 1)
	local res = 1
	for i = 1, acc.n do res = (res * toUint32(acc[i])) % WORD end
	return signedReturn(res)
end

function bit.bdiv(...: number)
	local acc = table.pack(...); assert(acc.n >= 1)
	local res = toUint32(acc[1])
	for i = 2, acc.n do
		local d = toUint32(acc[i])
		if d == 0 then error("division by zero") end
		res = math.floor(res / d)
	end
	return signedReturn(res)
end

function bit.band(...: number)
	local acc = table.pack(...); assert(acc.n >= 1)
	local res = toUint32(acc[1])
	for i = 2, acc.n do res = (res & toUint32(acc[i])) end
	return signedReturn(res)
end

function bit.bor(...: number)
	local acc = table.pack(...); assert(acc.n >= 1)
	local res = toUint32(acc[1])
	for i = 2, acc.n do res = (res | toUint32(acc[i])) end
	return signedReturn(res)
end

function bit.bxor(...: number)
	local acc = table.pack(...); assert(acc.n >= 1)
	local res = toUint32(acc[1])
	for i = 2, acc.n do res = (res ~ toUint32(acc[i])) end
	return signedReturn(res)
end

function bit.bnot(x: number)
	return signedReturn((~toUint32(x)) & MASK)
end

function bit.lshift(value: number, n: number)
	n = n % 32
	local res = (toUint32(value) << n) & MASK
	return signedReturn(res)
end

function bit.rshift(value: number, n: number)
	n = n % 32
	local res = (toUint32(value) >> n) & MASK
	return signedReturn(res)
end

function bit.arshift(value: number, n: number)
	n = n % 32
	local s = toSigned32(value)
	local shifted = math.floor(s / (2 ^ n))
	return toSigned32(shifted)
end

function bit.rol(value: number, n: number)
	n = n % 32
	local v = toUint32(value)
	local res = ((v << n) | (v >> (32 - n))) & MASK
	return signedReturn(res)
end

function bit.ror(value: number, n: number)
	n = n % 32
	local v = toUint32(value)
	local res = ((v >> n) | (v << (32 - n))) & MASK
	return signedReturn(res)
end

function bit.bpopcount(value: number)
	local v = toUint32(value)
	local count = 0
	while v ~= 0 do
		v = v & (v - 1)
		count = count + 1
	end
	return count
end

function bit.bswap(value: number)
	local v = toUint32(value)
	local b1 = (v & 0x000000FF) << 24
	local b2 = (v & 0x0000FF00) << 8
	local b3 = (v & 0x00FF0000) >> 8
	local b4 = (v & 0xFF000000) >> 24
	return signedReturn((b1 | b2 | b3 | b4) & MASK)
end

function bit.tohex(value: number, nibbles: number?)
	local n = nibbles or 8
	local v = toUint32(value)
	local fmt = string.format("%%0%dX", n)
	return string.format(fmt, v)
end

function bit.tobit(value: number)
	return toSigned32(toUint32(value))
end

return bit