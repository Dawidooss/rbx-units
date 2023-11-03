-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ReplicatedFirst = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ReplicatedFirst
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
		self.position = position
		self.unitName = unitName
		self.model = ReplicatedFirst.Units[unitName]:Clone()
		self.model.Name = self.id
		-- selection circle
		self.selectionCircle = ReplicatedFirst:FindFirstChild("SelectionCircle"):Clone()
		self.selectionCircle.Size = Vector3.new(self.selectionCircle.Size.X, self.selectionRadius * 2, self.selectionRadius * 2)
		local _fn = self.selectionCircle
		local _exp = self.model:GetPivot()
		local _arg0 = CFrame.Angles(0, 0, math.pi / 2)
		_fn:PivotTo(_exp * _arg0)
		self.selectionCircle.Parent = self.model
		local weld = Instance.new("WeldConstraint", self.selectionCircle)
		weld.Part0 = self.selectionCircle
		weld.Part1 = self.model.HumanoidRootPart
		self:Select(UnitSelectionType.None)
		self:UpdatePosition()
	end
	function Unit:Select(selectionType)
		self.selectionCircle.Transparency = if selectionType == UnitSelectionType.None then 1 else 0.2
		-- this.selectionCircle.Highlight.Enabled = selectionType === UnitSelectionType.Selected;
		self.selectionCircle.Color = if selectionType == UnitSelectionType.Selected then Color3.fromRGB(143, 142, 145) else Color3.fromRGB(70, 70, 70)
		self.selectionType = selectionType
	end
	function Unit:UpdatePosition()
		self.model:PivotTo(CFrame.new(self.position))
	end
	function Unit:Move(targetCFrame)
		self.model.Humanoid:MoveTo(targetCFrame.Position)
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
