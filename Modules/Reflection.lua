if typeof(gethiddenproperty) ~= "function" then
	error("Executor Current Environment Doesn't have [gethiddenproperty]", 2)
end

local ReflectionService = game:GetService("ReflectionService")

--// internal helper
local function collectProperties(instance, hiddenOnly)
	if typeof(instance) ~= "Instance" then
		error("Instance expected", 2)
	end

	local result = {}
	local properties = ReflectionService:GetPropertiesOfClass(instance.ClassName)

	for _, prop in properties do
		local ok, value, isHidden = pcall(function()
			local val, hidden = gethiddenproperty(instance, prop.Name)
			return val, hidden
		end)

		if ok then
			if hiddenOnly then
				if isHidden then
					result[prop.Name] = value
				end
			else
				result[prop.Name] = value
			end
		end
	end

	return result
end

--// main
local function getproperties(instance)
	return collectProperties(instance, false)
end

local function gethiddenproperties(instance)
	return collectProperties(instance, true)
end