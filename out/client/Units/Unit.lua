-- Compiled with roblox-ts v2.2.0
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
		self.moving = false
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
			local modelPosition = self.model:GetPivot().Position
			local groundedTargetPosition = Vector3.new(self.data.targetPosition.X, modelPosition.Y, self.data.targetPosition.Z)
			local distanceToTargetPosition = (groundedTargetPosition - modelPosition).Magnitude
			if distanceToTargetPosition < 2 then
				-- unit reached target
				self:MoveToEnded(true)
				return nil
			else
				self.moveToTries += 1
			end
			self:MoveTo(self.data.targetPosition, self.moveToFinishedCallback)
		end)
	end
	function Unit:Select(selectionType)
		self.selectionType = selectionType
		self:UpdateVisuals()
	end
	function Unit:StartPathfinding(position)
		local _position = position
		if typeof(_position) == "Vector3" then
			self.pathfinding:Start(position)
		else
			self.pathfinding:StartWithWaypoints(position)
		end
	end
	function Unit:MoveTo(position, endCallback)
		self.moveToTries += if self.data.targetPosition == position then 1 else 0
		if self.moveToTries > 10 then
			warn("UNIT MOVE TO: " .. (self.data.id .. " couldn't get to targetCFrame due to exceed moveToTries limit"))
			self:MoveToEnded(false)
			return nil
		end
		self.moveToFinishedCallback = endCallback
		self.moving = true
		self.data.targetPosition = position
		self.data.movementStartTick = tick()
		self.model.Humanoid:MoveTo(position)
		RunService:UnbindFromRenderStep(self.data.id .. "-physics")
		RunService:BindToRenderStep(self.data.id .. "-physics", Enum.RenderPriority.First.Value, function()
			return self:UpdatePhysics()
		end)
	end
	function Unit:MoveToEnded(success)
		local _result = self.moveToFinishedCallback
		if _result ~= nil then
			_result(success)
		end
		self.moveToFinishedCallback = nil
		self.moveToTries = 0
		self.moving = false
		RunService:UnbindFromRenderStep(self.data.id .. "-physics")
	end
	function Unit:GetPosition()
		return self.model:GetPivot().Position
	end
	function Unit:UpdateVisuals()
		local selected = self.selectionType == SelectionType.Selected
		self.selectionCircle.Transparency = if self.selectionType == SelectionType.None then 1 else 0.2
		self.selectionCircle.Color = if selected then Color3.fromRGB(143, 142, 145) else Color3.fromRGB(70, 70, 70)
	end
	function Unit:UpdatePhysics()
		if self.moving then
			local _targetPosition = self.data.targetPosition
			local _position = self.model:GetPivot().Position
			local distanceToCurrentWaypoint = (_targetPosition - _position).Magnitude
			if distanceToCurrentWaypoint > 1 and self.model.Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
				-- during movement, unit stopped and didn't reached target, try to MoveTo again
				self:MoveTo(self.data.targetPosition, self.moveToFinishedCallback)
			end
		end
	end
	function Unit:Destroy()
	end
end
return {
	default = Unit,
}
