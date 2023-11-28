-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local PathfindingService = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").PathfindingService
local agentParams = {
	AgentCanJump = false,
	WaypointSpacing = math.huge,
	AgentRadius = 4,
}
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
	Pathfinding.ComputePath = TS.async(function(self, position)
		local promise = TS.Promise.new(function(resolve, reject)
			self.path:ComputeAsync(self.unit:GetPosition(), position)
			if self.path.Status ~= Enum.PathStatus.Success and self.path.Status ~= Enum.PathStatus.ClosestNoPath then
				return reject()
			end
			local path = {}
			local waypoints = self.path:GetWaypoints()
			table.remove(waypoints, 1)
			for _, waypoint in waypoints do
				local _path = path
				local _position = waypoint.Position
				table.insert(_path, _position)
			end
			resolve({ self.unit, path })
		end)
		return promise
	end)
end
return {
	default = Pathfinding,
}
