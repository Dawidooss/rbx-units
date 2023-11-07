-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedFirst = _services.ReplicatedFirst
local RunService = _services.RunService
local Pathfinding = TS.import(script, script.Parent.Parent, "Pathfinding").default
local _Selectable = TS.import(script, script.Parent, "Selectable")
local Selectable = _Selectable.default
local SelectionType = _Selectable.SelectionType
local Unit
do
	local super = Selectable
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
	function Unit:constructor(id, unitName, position)
		super.constructor(self)
		self.selectionType = SelectionType.None
		self.selectionRadius = 1.5
		self.id = id
		self.unitName = unitName
		self.model = ReplicatedFirst.Units[unitName]:Clone()
		self.model.Name = self.id
		self.model:PivotTo(CFrame.new(position))
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
		self.pathfinding = Pathfinding.new(self)
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
		self:Select(SelectionType.None)
	end
	function Unit:Select(selectionType)
		self.selectionType = selectionType
		self.pathfinding:EnableVisualisation(selectionType == SelectionType.Selected)
		self:Update()
		if selectionType == SelectionType.Selected then
			RunService:BindToRenderStep("unit-" .. (self.id .. "-selectionUpdate"), 1, function()
				return self:Update()
			end)
		else
			RunService:UnbindFromRenderStep("unit-" .. (self.id .. "-selectionUpdate"))
		end
	end
	function Unit:Move(cframe)
		self.pathfinding:Start(cframe)
		self:Update()
	end
	function Unit:Update()
		local selected = self.selectionType == SelectionType.Selected
		self.selectionCircle.Transparency = if self.selectionType == SelectionType.None then 1 else 0.2
		self.selectionCircle.Color = if selected then Color3.fromRGB(143, 142, 145) else Color3.fromRGB(70, 70, 70)
	end
	function Unit:Destroy()
	end
end
return {
	default = Unit,
}
