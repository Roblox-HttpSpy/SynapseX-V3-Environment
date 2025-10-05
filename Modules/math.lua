--!strict

local cam = workspace.CurrentCamera --// cloneref this for sercuiry if you want

export type ScreenPoint = {
	Position: Vector2,
	Visible: boolean
}

function worldToScreen(points: { [any]: Vector3 | BasePart }, offset: Vector3?): { [any]: ScreenPoint }
	assert(typeof(points) == "table", "points must be a table")
	offset = offset or Vector3.zero

	local result: { [any]: ScreenPoint } = {}

	for k, v in pairs(points) do
		local pos: Vector3
		if typeof(v) == "Vector3" then
			pos = v + offset
		elseif typeof(v) == "Instance" and v:IsA("BasePart") then
			pos = v.Position + offset
		else
			continue
		end

		local screenPos, onScreen = cam:WorldToViewportPoint(pos)
		result[k] = {
			Position = Vector2.new(screenPos.X, screenPos.Y),
			Visible = onScreen
		}
	end

	return result
end

function getBoundingBox(parts: { [any]: BasePart }, orientation: CFrame?): (CFrame, Vector3)
	assert(typeof(parts) == "table", "parts must be a table")

	local min = Vector3.new(math.huge, math.huge, math.huge)
	local max = Vector3.new(-math.huge, -math.huge, -math.huge)

	for _, part in pairs(parts) do
		if part and part:IsA("BasePart") then
			local cf, size = part.CFrame, part.Size
			local half = size * 0.5
			for _, offset in ipairs({
				Vector3.new(-half.X, -half.Y, -half.Z),
				Vector3.new( half.X, -half.Y, -half.Z),
				Vector3.new(-half.X,  half.Y, -half.Z),
				Vector3.new( half.X,  half.Y, -half.Z),
				Vector3.new(-half.X, -half.Y,  half.Z),
				Vector3.new( half.X, -half.Y,  half.Z),
				Vector3.new(-half.X,  half.Y,  half.Z),
				Vector3.new( half.X,  half.Y,  half.Z),
			}) do
				local world = cf:PointToWorldSpace(offset)
				min = Vector3.new(math.min(min.X, world.X), math.min(min.Y, world.Y), math.min(min.Z, world.Z))
				max = Vector3.new(math.max(max.X, world.X), math.max(max.Y, world.Y), math.max(max.Z, world.Z))
			end
		end
	end

	local center = (min + max) / 2
	local size = max - min
	local cf = CFrame.new(center)

	if orientation and typeof(orientation) == "CFrame" then
		cf = orientation * cf
	end

	return cf, size
end

return {
	worldtoscreen = worldToScreen,
	getboundingbox = getBoundingBox
}