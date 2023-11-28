-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local PathfindingService = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").PathfindingService
local ClientReplicator = TS.import(script, script.Parent.Parent, "DataStore", "ClientReplicator").default
local agentParams = {
	AgentCanJump = false,
	WaypointSpacing = math.huge,
	AgentRadius = 4,
}
local replicator = ClientReplicator:Get()
local Pathfinding
do
	Pathfinding = setmetatable({}, {
		__tostring = function()
			return "Pathfinding"
		end,
	})
	Pathfinding.__index = Pathfinding
	function Pathfinding.new(...)
		local self = setmetatable({}, Pathfinding)
		return self:constructor(...) or self
	end
	function Pathfinding:constructor(unit)
		self.active = false
		self.unit = unit
		self.path = PathfindingService:CreatePath(agentParams)
	end
	function Pathfinding:ComputePath(position)
		self.path:ComputeAsync(self.unit:GetPosition(), position)
		if self.path.Status ~= Enum.PathStatus.Success and self.path.Status ~= Enum.PathStatus.ClosestNoPath then
			return {}
		end
		local path = {}
		local waypoints = self.path:GetWaypoints()
		table.remove(waypoints, 1)
		for _, waypoint in waypoints do
			local _path = path
			local _position = waypoint.Position
			table.insert(_path, _position)
		end
		return path
	end
end
return {
	default = Pathfinding,
}
