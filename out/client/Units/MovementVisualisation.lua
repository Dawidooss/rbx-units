-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedFirst = _services.ReplicatedFirst
local Workspace = _services.Workspace
local Utils = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Utils").default
local MovementVisualisation
do
	MovementVisualisation = setmetatable({}, {
		__tostring = function()
			return "MovementVisualisation"
		end,
	})
	MovementVisualisation.__index = MovementVisualisation
	function MovementVisualisation.new(...)
		local self = setmetatable({}, MovementVisualisation)
		return self:constructor(...) or self
	end
	function MovementVisualisation:constructor(unitMovement)
		self.enabled = false
		self.movement = unitMovement
		self.unit = unitMovement.unit
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
	end
	function MovementVisualisation:Enable(state)
		self.enabled = state
		self:Update()
	end
	function MovementVisualisation:Clear()
		self.visualisation.Positions:ClearAllChildren()
	end
	function MovementVisualisation:Update()
		self:Clear()
		if not self.enabled then
			return nil
		end
		local previousVisualisationAtt = self.beamAttachment
		do
			local pathIndex = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					pathIndex += 1
				else
					_shouldIncrement = true
				end
				if not (pathIndex < #self.movement.path) then
					break
				end
				local position = self.movement.path[pathIndex + 1]
				local length = (previousVisualisationAtt.WorldPosition - position).Magnitude
				local visualisationPart = self.visualisationPart:Clone()
				local _fn = Utils
				local _vector3 = Vector3.new(0, 100, 0)
				local groundPositionResult = _fn:RaycastBottom(position + _vector3, { Workspace.TerrainParts }, Enum.RaycastFilterType.Include)
				if not groundPositionResult then
					continue
				end
				local _exp = groundPositionResult.Position
				local _position = groundPositionResult.Position
				local _normal = groundPositionResult.Normal
				local _cFrame = CFrame.new(_exp, _position + _normal)
				local _arg0 = CFrame.Angles(math.pi / 2, 0, 0)
				local cframe = _cFrame * _arg0
				visualisationPart:PivotTo(cframe)
				visualisationPart.Beam.Attachment1 = previousVisualisationAtt
				visualisationPart.Beam.TextureLength = length
				visualisationPart.Transparency = if pathIndex == #self.movement.path - 1 then 0 else 1
				visualisationPart.Parent = self.visualisation.Positions
				previousVisualisationAtt = visualisationPart.Attachment
			end
		end
	end
end
return {
	default = MovementVisualisation,
}
