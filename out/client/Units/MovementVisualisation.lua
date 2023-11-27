-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ReplicatedFirst = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ReplicatedFirst
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
		self.unitMovement = unitMovement
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
	end
	function MovementVisualisation:SetPath()
	end
	function MovementVisualisation:Clear()
		self.visualisation.Positions:ClearAllChildren()
	end
end
return {
	default = MovementVisualisation,
}
