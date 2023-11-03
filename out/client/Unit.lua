-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedFirst = _services.ReplicatedFirst
local RunService = _services.RunService
local UnitSelectionType
local Unit
do
	Unit = setmetatable({}, {
		__tostring = function()
			return "Unit"
		end,
	})
	Unit.__index = Unit
	function Unit.new(...)
		local self = setmetatable({}, Unit)
		return self:constructor(...) or self
	end
	function Unit:constructor(id, unitName, position)
		self.selectionType = UnitSelectionType.None
		self.selectionRadius = 1.5
		self.id = id
		self.unitName = unitName
		self.targetPosition = position
		self.model = ReplicatedFirst.Units[unitName]:Clone()
		self.model.Name = self.id
		self.model:PivotTo(CFrame.new(position))
		-- selection circle
		self.selectionCircle = ReplicatedFirst:FindFirstChild("SelectionCircle"):Clone()
		self.selectionCircle.Size = Vector3.new(self.selectionCircle.Size.X, self.selectionRadius * 2, self.selectionRadius * 2)
		local _fn = self.selectionCircle
		local _exp = self.model:GetPivot()
		local _arg0 = CFrame.Angles(0, 0, math.pi / 2)
		_fn:PivotTo(_exp * _arg0)
		self.selectionCircle.Parent = self.model
		-- movement circle
		self.movementCircle = ReplicatedFirst:FindFirstChild("MovementCircle"):Clone()
		self.movementCircle.Beam.Attachment1 = self.selectionCircle.Attachment
		self.movementCircle.Arrow:Destroy()
		local weld = Instance.new("WeldConstraint", self.selectionCircle)
		weld.Part0 = self.selectionCircle
		weld.Part1 = self.model.HumanoidRootPart
		self:Select(UnitSelectionType.None)
	end
	function Unit:Select(selectionType)
		self.selectionType = selectionType
		self:Update()
		if selectionType == UnitSelectionType.Selected then
			RunService:BindToRenderStep("unit-" .. (self.id .. "-selectionUpdate"), 1, function()
				return self:Update()
			end)
		else
			RunService:UnbindFromRenderStep("unit-" .. (self.id .. "-selectionUpdate"))
		end
	end
	function Unit:Move(position)
		self.targetPosition = position
		self.model.Humanoid:MoveTo(position)
		self:Update()
		-- TODO REWORK IT
	end
	function Unit:Update()
		local selected = self.selectionType == UnitSelectionType.Selected
		self.selectionCircle.Transparency = if self.selectionType == UnitSelectionType.None then 1 else 0.2
		self.selectionCircle.Color = if selected then Color3.fromRGB(143, 142, 145) else Color3.fromRGB(70, 70, 70)
		local _position = self.selectionCircle.Position
		local _targetPosition = self.targetPosition
		local toTargetPositionDistance = (_position - _targetPosition).Magnitude
		local movementCircleVisible = toTargetPositionDistance > 3 and selected
		local _fn = self.movementCircle
		local _cFrame = CFrame.new(self.targetPosition, self.selectionCircle.Position)
		local _arg0 = CFrame.Angles(math.pi, -math.pi / 2, math.pi / 2)
		_fn:PivotTo(_cFrame * _arg0)
		self.movementCircle.Beam.TextureLength = toTargetPositionDistance / 2.5
		self.movementCircle.Parent = if movementCircleVisible then self.model else nil
	end
	function Unit:Destroy()
	end
end
local UnitData
do
	UnitData = setmetatable({}, {
		__tostring = function()
			return "UnitData"
		end,
	})
	UnitData.__index = UnitData
	function UnitData.new(...)
		local self = setmetatable({}, UnitData)
		return self:constructor(...) or self
	end
	function UnitData:constructor()
	end
end
do
	local _inverse = {}
	UnitSelectionType = setmetatable({}, {
		__index = _inverse,
	})
	UnitSelectionType.Selected = 0
	_inverse[0] = "Selected"
	UnitSelectionType.Hovering = 1
	_inverse[1] = "Hovering"
	UnitSelectionType.None = 2
	_inverse[2] = "None"
end
return {
	default = Unit,
	UnitData = UnitData,
	UnitSelectionType = UnitSelectionType,
}
