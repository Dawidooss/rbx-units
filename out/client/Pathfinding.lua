-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local HttpService = _services.HttpService
local PathfindingService = _services.PathfindingService
local ReplicatedFirst = _services.ReplicatedFirst
local RunService = _services.RunService
local Workspace = _services.Workspace
local Utils = TS.import(script, script.Parent, "Utils").default
local agentParams = {
	AgentCanJump = false,
	WaypointSpacing = math.huge,
	AgentRadius = 2,
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
		self.visualisationEnabled = false
		self.targetCFrame = CFrame.new()
		self.waypoints = {}
		self.currentWaypointIndex = 0
		self.pathId = ""
		self.moveToCurrentWaypointTries = 0
		self.unit = unit
		self.agent = unit.model
		self.path = PathfindingService:CreatePath(agentParams)
		self.visualisation = ReplicatedFirst:FindFirstChild("NormalAction"):Clone()
		self.visualisationPart = self.visualisation.Middle
		self.visualisation.Name = "PathVisualisation"
		self.visualisation.Parent = self.unit.model
		self.visualisation.Arrow:Destroy()
		self.visualisationPart.Parent = nil
		self.beamAttachment = Instance.new("Attachment")
		self.beamAttachment.Parent = self.agent.HumanoidRootPart
		local _exp = self.agent:GetPivot()
		local _arg0 = CFrame.Angles(0, math.pi, math.pi / 2)
		self.beamAttachment.WorldCFrame = _exp * _arg0
		self.path.Blocked:Connect(function(blockedWaypointIndex)
			wait()
			self:ComputePath()
		end)
		self.agent.Humanoid.MoveToFinished:Connect(function(reached)
			if not self.active then
				return nil
			end
			local currentWaypoint = self.waypoints[self.currentWaypointIndex + 1]
			if not currentWaypoint then
				return nil
			end
			local groundedCurrentWaypoint = Vector3.new(currentWaypoint.Position.X, self.beamAttachment.WorldPosition.Y, currentWaypoint.Position.Z)
			local _worldPosition = self.beamAttachment.WorldPosition
			local distanceToCurrentWaypoint = (groundedCurrentWaypoint - _worldPosition).Magnitude
			if distanceToCurrentWaypoint < 1 then
				if self.currentWaypointIndex == #self.waypoints - 1 then
					self:Stop(true)
					return nil
				end
				self.currentWaypointIndex += 1
				self.moveToCurrentWaypointTries = 0
			else
				self.moveToCurrentWaypointTries += 1
			end
			self:MoveToCurrentWaypoint()
		end)
	end
	Pathfinding.Start = TS.async(function(self, targetCFrame, stopCallback)
		self.targetCFrame = targetCFrame
		self.active = true
		self.stopCallback = stopCallback
		TS.await(self:ComputePath())
		self:CreateVisualisation()
		local _result = self.loopConnection
		if _result ~= nil then
			_result:Disconnect()
		end
		self.loopConnection = RunService.RenderStepped:Connect(function()
			self:Update()
		end)
	end)
	function Pathfinding:Stop(success)
		local _result = self.stopCallback
		if _result ~= nil then
			_result(success)
		end
		-- this.agent.MoveTo(this.agent.GetPivot().Position);
		if success then
			local orientation = { self.targetCFrame:ToOrientation() }
			self.unit.alignOrientation.CFrame = CFrame.Angles(0, orientation[2], 0)
		end
		self.active = false
		self.waypoints = {}
		self.currentWaypointIndex = 0
		local _result_1 = self.loopConnection
		if _result_1 ~= nil then
			_result_1:Disconnect()
		end
		self:ClearVisualisation()
	end
	function Pathfinding:EnableVisualisation(state)
		self.visualisationEnabled = state
		self:CreateVisualisation()
	end
	Pathfinding.ComputePath = TS.async(function(self)
		local pathId = HttpService:GenerateGUID(false)
		self.pathId = pathId
		self.path:ComputeAsync(self.agent:GetPivot().Position, self.targetCFrame.Position)
		if self.path.Status ~= Enum.PathStatus.Success and self.path.Status ~= Enum.PathStatus.ClosestNoPath then
			return nil
		end
		self.moveToCurrentWaypointTries = 0
		self.waypoints = self.path:GetWaypoints()
		self.currentWaypointIndex = 1
		self.pathId = HttpService:GenerateGUID(false)
		self:MoveToCurrentWaypoint()
	end)
	function Pathfinding:MoveToCurrentWaypoint()
		if self.moveToCurrentWaypointTries > 10 then
			warn("PATHFINDING: " .. (self.agent.Name .. " couldn't get to targetCFrame due to exceed moveToCurrentWaypointTries limit"))
			self:Stop(false)
			return nil
		end
		local waypoint = self.waypoints[self.currentWaypointIndex + 1]
		if not waypoint then
			self:Stop(true)
			return nil
		end
		local orientation = { CFrame.new(self.agent:GetPivot().Position, waypoint.Position):ToOrientation() }
		self.unit.alignOrientation.CFrame = CFrame.Angles(0, orientation[2], 0)
		self.agent.Humanoid:MoveTo(waypoint.Position)
	end
	function Pathfinding:Update()
		if self.active and self.visualisationEnabled then
			self:UpdateVisualisation()
		end
		local currentWaypoint = self.waypoints[self.currentWaypointIndex + 1]
		if not currentWaypoint then
			return nil
		end
		local groundedCurrentWaypoint = Vector3.new(currentWaypoint.Position.X, self.beamAttachment.WorldPosition.Y, currentWaypoint.Position.Z)
		local _worldPosition = self.beamAttachment.WorldPosition
		local distanceToCurrentWaypoint = (groundedCurrentWaypoint - _worldPosition).Magnitude
		if distanceToCurrentWaypoint > 1 and self.agent.Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
			self.moveToCurrentWaypointTries += 1
			self:MoveToCurrentWaypoint()
		end
	end
	function Pathfinding:ClearVisualisation()
		self.visualisation.Positions:ClearAllChildren()
	end
	function Pathfinding:CreateVisualisation()
		self:ClearVisualisation()
		if not self.visualisationEnabled or not self.active then
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
