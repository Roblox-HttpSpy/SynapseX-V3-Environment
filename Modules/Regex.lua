--!strict

export type Match = {
	Value: string,
	Position: number,
	Captures: { string },
}

local Match = {}
Match.__index = Match

function Match.new(value: string, position: number, captures: { string }): Match
	return setmetatable({
		Value = value,
		Position = position,
		Captures = captures,
	}, Match)
end

export type Regex = {
	Pattern: string,
	IsMatch: (self: Regex, text: string) -> boolean,
	Match: (self: Regex, text: string) -> Match?,
	MatchMany: (self: Regex, text: string) -> { Match },
	Replace: (self: Regex, text: string, replacement: string) -> string,
	Escape: (self: Regex, text: string) -> string,
}

local Regex = {}
Regex.__index = Regex

function Regex.new(pattern: string): Regex
	return setmetatable({ Pattern = pattern }, Regex)
end

function Regex:IsMatch(text: string): boolean
	return string.find(text, self.Pattern) ~= nil
end

function Regex:Match(text: string): Match?
	local results = { string.find(text, self.Pattern) }
	if #results == 0 then return nil end
	local startPos, endPos = results[1], results[2]
	local captures = {}
	for i = 3, #results do
		table.insert(captures, tostring(results[i]))
	end
	return Match.new(text:sub(startPos, endPos), startPos, captures)
end

function Regex:MatchMany(text: string): { Match }
	local matches = {}
	for startPos, endPos in string.gmatch(text, "()(" .. self.Pattern .. ")()") do
		local value = text:sub(startPos, endPos - 1)
		table.insert(matches, Match.new(value, startPos, {}))
	end
	return matches
end

function Regex:Replace(text: string, replacement: string): string
	return (string.gsub(text, self.Pattern, replacement))
end

function Regex:Escape(str: string): string
	local escapes = table.freeze({
		["("] = "%(",
		[")"] = "%)",
		["."] = "%.",
		["%"] = "%%",
		["+"] = "%+",
		["-"] = "%-",
		["*"] = "%*",
		["?"] = "%?",
		["["] = "%[",
		["]"] = "%]",
		["^"] = "%^",
		["$"] = "%$",
	})
	return (str:gsub(".", escapes))
end

table.freeze(Regex)
return Regex
