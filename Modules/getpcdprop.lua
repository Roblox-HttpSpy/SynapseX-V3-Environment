--!strict

--// wut ya expect?
function getpcdprop(TMesh: TriangleMeshPart): any?
	local a, b = gethiddenproperty(TMesh, "PhysicalConfigData")
	return a
end
-- NOTE: depending on your executor gethiddenproperty() this may or may not work dou to PhysicalConfigData Returning a SharedString Datatype
