-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local HttpService = _services.HttpService
local PathfindingService = _services.PathfindingService
local Players = _services.Players
local ReplicatedFirst = _services.ReplicatedFirst
local Workspace = _services.Workspace
local Utils = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Utils").default
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
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
		self.targetPosition = Vector3.new()
		self.waypoints = {}
		self.currentWaypointIndex = 0
		self.pathId = ""
		self.unit = unit
		self.path = PathfindingService:CreatePath(agentParams)
		self.visualisation = ReplicatedFirst:FindFirstChild("NormalAction"):Clone()
		self.visualisationPart = self.visualisation.Middle
		self.visualisation.Name = "PathVisualisation"
		self.visualisation.Parent = self.unit.model
		self.visualisation.Arrow:Destroy()
		self.visualisationPart.Parent = nil
		self.beamAttachment = Instance.new("Attachment")
		self.beamAttachment.Parent = self.unit.model.HumanoidRootPart
		local _exp = self.unit.model:GetPivot()
		local _arg0 = CFrame.Angles(0, math.pi, math.pi / 2)
		self.beamAttachment.WorldCFrame = _exp * _arg0
		-- this.path.Blocked.Connect((blockedWaypointIndex) => {
		-- 	wait();
		-- 	this.ComputePath();
		-- 	this.MoveToCurrentWaypoint();
		-- });
	end
	Pathfinding.StartWithWaypoints = TS.async(function(self, waypoints)
		self.targetPosition = waypoints[#waypoints - 1 + 1].Position
		self.active = true
		self:SetWaypoints(waypoints)
		self:CreateVisualisation()
		self:MoveToCurrentWaypoint()
	end)
	Pathfinding.Start = TS.async(function(self, targetPosition)
		self.targetPosition = targetPosition
		self.active = true
		TS.await(self:ComputePath())
		self:CreateVisualisation()
		self:MoveToCurrentWaypoint()
	end)
	function Pathfinding:Stop(success)
		-- if (success) {
		-- const orientation = this.targetCFrame.ToOrientation();
		-- this.unit.alignOrientation.CFrame = CFrame.Angles(0, orientation[1], 0);
		-- }
		self.active = false
		self.waypoints = {}
		self.currentWaypointIndex = 0
		self:ClearVisualisation()
	end
	function Pathfinding:MoveToFinished(success)
		if success then
			if self.currentWaypointIndex == #self.waypoints - 1 then
				self:Stop(true)
				return nil
			end
			self.currentWaypointIndex += 1
		end
	end
	function Pathfinding:SetWaypoints(waypoints)
		self.waypoints = waypoints
		self.currentWaypointIndex = 1
		self.pathId = HttpService:GenerateGUID(false)
	end
	Pathfinding.ComputePath = TS.async(function(self)
		self.path:ComputeAsync(self.unit.model:GetPivot().Position, self.targetPosition)
		if self.path.Status ~= Enum.PathStatus.Success and self.path.Status ~= Enum.PathStatus.ClosestNoPath then
			return nil
		end
		self:SetWaypoints(self.path:GetWaypoints())
	end)
	function Pathfinding:MoveToCurrentWaypoint()
		local waypoint = self.waypoints[self.currentWaypointIndex + 1]
		if not waypoint then
			self:Stop(true)
			return nil
		end
		self:UpdateVisualisation()
		local orientation = { CFrame.new(self.unit.model:GetPivot().Position, waypoint.Position):ToOrientation() }
		local currentPosition = self.unit.model:GetPivot()
		self.unit.alignOrientation.CFrame = CFrame.Angles(0, orientation[2], 0)
		self.unit:MoveTo(waypoint.Position, function(success)
			if success then
				self.currentWaypointIndex += 1
				self:MoveToCurrentWaypoint()
			else
				self:Stop(false)
			end
		end)
		-- replicate to server if player is owner of this unit
		if self.unit.data.playerId == Players.LocalPlayer.UserId then
			local buffer = BitBuffer()
			buffer.writeString(self.unit.data.id)
			buffer.writeVector3(waypoint.Position)
			buffer.writeFloat32(tick())
			local response = replicator:Replicate("move-unit", buffer.dumpString())[1]
			if response.error then
				self.unit.model:PivotTo(currentPosition)
				self:Stop(false)
			end
		end
	end
	function Pathfinding:ClearVisualisation()
		self.visualisation.Positions:ClearAllChildren()
	end
	function Pathfinding:CreateVisualisation()
		print("create visualisation")
		self:ClearVisualisation()
		if not self.active then
			return nil
		end
		local previousVisualisationAtt = self.beamAttachment
		do
			local waypointIndex = self.currentWaypointIndex
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					waypointIndex += 1
				else
					_shouldIncrement = true
				end
				if not (waypointIndex < #self.waypoints) then
					break
				end
				local waypoint = self.waypoints[waypointIndex + 1]
				local _worldPosition = previousVisualisationAtt.WorldPosition
				local _position = waypoint.Position
				local toTargetCFrameDistance = (_worldPosition - _position).Magnitude
				local visualisationPart = self.visualisationPart:Clone()
				local _fn = Utils
				local _position_1 = waypoint.Position
				local _vector3 = Vector3.new(0, 100, 0)
				local groundPositionResult = _fn:RaycastBottom(_position_1 + _vector3, { Workspace.TerrainParts }, Enum.RaycastFilterType.Include)
				if not groundPositionResult then
					continue
				end
				local _exp = groundPositionResult.Position
				local _position_2 = groundPositionResult.Position
				local _normal = groundPositionResult.Normal
				local _cFrame = CFrame.new(_exp, _position_2 + _normal)
				local _arg0 = CFrame.Angles(math.pi / 2, 0, 0)
				local cframe = _cFrame * _arg0
				visualisationPart:PivotTo(cframe)
				visualisationPart.Beam.Attachment1 = previousVisualisationAtt
				visualisationPart.Beam.TextureLength = toTargetCFrameDistance
				visualisationPart.Name = self.pathId .. ("#" .. tostring(waypointIndex))
				visualisationPart.Transparency = if waypointIndex == #self.waypoints - 1 then 0 else 1
				visualisationPart.Parent = self.visualisation.Positions
				previousVisualisationAtt = visualisationPart.Attachment
			end
		end
	end
	function Pathfinding:UpdateVisualisation()
		for _, child in self.visualisation.Positions:GetChildren() do
			if string.split(child.Name, "#")[1] ~= self.pathId then
				self:CreateVisualisation()
				return nil
			end
			local waypointIndex = tonumber(string.split(child.Name, "#")[2])
			if waypointIndex < self.currentWaypointIndex then
				child:Destroy()
				continue
			end
			local visualisationPart = child
			local _worldPosition = visualisationPart.Beam.Attachment0.WorldPosition
			local _worldPosition_1 = visualisationPart.Beam.Attachment1.WorldPosition
			local toTargetCFrameDistance = (_worldPosition - _worldPosition_1).Magnitude
			if waypointIndex == self.currentWaypointIndex then
				visualisationPart.Beam.Attachment1 = self.beamAttachment
			end
			visualisationPart.Beam.TextureLength = toTargetCFrameDistance
		end
	end
end
return {
	default = Pathfinding,
}
