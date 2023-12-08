-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Maid = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "maid", "Maid")
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedFirst = _services.ReplicatedFirst
local Workspace = _services.Workspace
local UnitMovement = TS.import(script, script.Parent, "UnitMovement").default
local Pathfinding = TS.import(script, script.Parent, "Pathfinding").default
local SelectionType = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "types").SelectionType
local UnitData = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "UnitsStoreBase").UnitData
local Unit
do
	local super = UnitData
	Unit = setmetatable({}, {
		__tostring = function()
			return "Unit"
		end,
		__index = super,
	})
	Unit.__index = Unit
	function Unit.new(...)
		local self = setmetatable({}, Unit)
		return self:constructor(...) or self
	end
	function Unit:constructor(id, unitData)
		super.constructor(self, unitData)
		self.maid = Maid.new()
		self.selectionType = SelectionType.None
		self.selectionRadius = 1.5
		self.model = ReplicatedFirst.Units[self.name]:Clone()
		self.model.Name = self.name .. "#" .. tostring(self.id)
		self.model:PivotTo(CFrame.new(self.position))
		self.model.Parent = Workspace:WaitForChild("UnitsCache")
		-- disabling not used humanoid states to save memory
		-- this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.FallingDown, false);
		-- this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false);
		-- this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.GettingUp, false);
		-- this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Jumping, false);
		-- this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Swimming, false);
		-- this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Freefall, false);
		-- this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Flying, false);
		-- this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Landed, false);
		-- this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Running, false);
		-- this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Climbing, false);
		-- this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Seated, false);
		-- this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false);
		-- this.model.Humanoid.SetStateEnabled(Enum.HumanoidStateType.Dead, false); // Enable this in case you want to use .Died event
		self.groundAttachment = Instance.new("Attachment")
		self.groundAttachment.Parent = self.model.HumanoidRootPart
		self.groundAttachment.WorldCFrame = self.model:GetPivot()
		self.alignOrientation = Instance.new("AlignOrientation", self.model.HumanoidRootPart)
		self.alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		self.alignOrientation.Attachment0 = self.groundAttachment
		self.alignOrientation.MaxTorque = 1000000
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
		self.overheadBillboard = ReplicatedFirst.UnitOverheadBillboard:Clone()
		self.overheadBillboard.Parent = self.model.Head
		self.movement = UnitMovement.new(self)
		self.pathfinding = Pathfinding.new(self)
		self:Select(SelectionType.None)
	end
	function Unit:Select(selectionType)
		self.selectionType = selectionType
		self:UpdateVisuals()
	end
	function Unit:UpdatePosition(position)
		self.model:PivotTo(CFrame.new(position))
		self.position = position
	end
	function Unit:GetPosition()
		return self.model:GetPivot().Position
	end
	function Unit:UpdateVisuals()
		local selected = self.selectionType == SelectionType.Selected
		self.movement.visualisation:Enable(selected)
		self.overheadBillboard.Enabled = self.selectionType ~= SelectionType.None
		self.overheadBillboard.HealthBar.Bar.Size = UDim2.fromScale(math.clamp(self.health / 100, 0, 1), 1)
		self.selectionCircle.Transparency = if self.selectionType == SelectionType.None then 1 else 0.2
		self.selectionCircle.Color = if selected then Color3.fromRGB(143, 142, 145) else Color3.fromRGB(70, 70, 70)
	end
	function Unit:Destroy()
		self.maid:DoCleaning()
	end
end
return {
	default = Unit,
}
