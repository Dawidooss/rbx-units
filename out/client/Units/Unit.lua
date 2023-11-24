-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedFirst = _services.ReplicatedFirst
local RunService = _services.RunService
local Workspace = _services.Workspace
local Pathfinding = TS.import(script, script.Parent, "Pathfinding").default
local SelectionType = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "types").SelectionType
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
	function Unit:constructor(unitData)
		self.movingTo = false
		self.moveToTries = 0
		self.selectionType = SelectionType.None
		self.selectionRadius = 1.5
		self.data = unitData
		self.model = ReplicatedFirst.Units[self.data.type]:Clone()
		self.model.Name = self.data.type
		self.model:PivotTo(CFrame.new(unitData.position))
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
		self.model.Humanoid.MoveToFinished:Connect(function(reached)
			-- const groundedCurrentWaypoint = new Vector3(
			-- currentWaypoint.Position.X,
			-- this.beamAttachment.WorldPosition.Y,
			-- currentWaypoint.Position.Z,
			-- );
			local _targetPosition = self.data.targetPosition
			local _position = self.model:GetPivot().Position
			local distanceToTargetPosition = (_targetPosition - _position).Magnitude
			if distanceToTargetPosition < 1 then
				if self.pathfinding.active then
					self.pathfinding:MoveToFinished(true)
				end
				self.moveToTries = 0
				self.movingTo = false
				return nil
			else
				self.moveToTries += 1
			end
			if self.moveToTries > 10 then
				warn("UNIT MOVE TO: " .. (self.data.id .. " couldn't get to targetCFrame due to exceed moveToTries limit"))
				if self.pathfinding.active then
					self.pathfinding:MoveToFinished(false)
				end
				self.moveToTries = 0
				self.movingTo = false
				return nil
			end
			self:MoveTo(self.data.targetPosition)
		end)
	end
	function Unit:Select(selectionType)
		self.selectionType = selectionType
		self:Update()
		if selectionType == SelectionType.Selected then
			RunService:BindToRenderStep("unit-" .. (self.data.id .. "-selectionUpdate"), 1, function()
				return self:Update()
			end)
		else
			RunService:UnbindFromRenderStep("unit-" .. (self.data.id .. "-selectionUpdate"))
		end
	end
	function Unit:StartPathfinding(cframe)
		self.pathfinding:Start(cframe)
	end
	function Unit:MoveTo(position)
		self.data.targetPosition = position
		self.data.movementStartTick = tick()
		-- this.data.movementEndTick = ?????
		self.movingTo = true
		self.model.Humanoid:MoveTo(position)
	end
	function Unit:GetPosition()
		return self.model:GetPivot().Position
	end
	function Unit:Update()
		local selected = self.selectionType == SelectionType.Selected
		self.pathfinding:EnableVisualisation(selected)
		self.selectionCircle.Transparency = if self.selectionType == SelectionType.None then 1 else 0.2
		self.selectionCircle.Color = if selected then Color3.fromRGB(143, 142, 145) else Color3.fromRGB(70, 70, 70)
	end
	function Unit:UpdatePhysics()
		if self.movingTo then
			local _targetPosition = self.data.targetPosition
			local _position = self.model:GetPivot().Position
			local distanceToCurrentWaypoint = (_targetPosition - _position).Magnitude
			if distanceToCurrentWaypoint > 1 and self.model.Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
				-- during movement unit stopped and didn't reached target, try to MoveTo again
				self:MoveTo(self.data.targetPosition)
			end
		end
	end
	function Unit:Destroy()
	end
end
return {
	default = Unit,
}
