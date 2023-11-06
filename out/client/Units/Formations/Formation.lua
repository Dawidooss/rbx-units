-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedFirst = _services.ReplicatedFirst
local Workspace = _services.Workspace
local camera = Workspace.CurrentCamera
local Formation
do
	Formation = {}
	function Formation:constructor(actionType)
		self.destroyed = false
		self.circle = ReplicatedFirst:WaitForChild(actionType):Clone()
		self.arrow = self.circle.Arrow
	end
	function Formation:VisualisePositions(units, cframe, spread)
		if self.destroyed then
			return nil
		end
		self.circle:PivotTo(cframe)
		self.circle.Parent = camera
		self.arrow.Parent = if spread < 2 then nil else self.circle
		local _cframe = cframe
		local _cFrame = CFrame.new(0, 0, -spread / 2)
		local arrowMiddle = (_cframe * _cFrame).Position
		self.arrow:PivotTo(CFrame.new(arrowMiddle, cframe.Position))
		self.arrow.Length.Size = Vector3.new(spread, self.arrow.Length.Size.Y, self.arrow.Length.Size.Z)
		self.arrow.Length.Attachment.CFrame = CFrame.new(spread / 2, 0, 0)
		self.arrow.Left:PivotTo(self.arrow.Length.Attachment.WorldCFrame)
		self.arrow.Right:PivotTo(self.arrow.Length.Attachment.WorldCFrame)
		-- visualise positions
		local mainCFrame = self.circle:GetPivot()
		local cframes = self:GetCFramesInFormation(#units, mainCFrame, spread)
		self.circle.Positions:ClearAllChildren()
		local _arg0 = function(cframe, i)
			if i == 0 then
				return nil
			end
			local positionPart = self.circle.Middle:Clone()
			positionPart:PivotTo(cframe)
			positionPart.Parent = self.circle.Positions
		end
		for _k, _v in cframes do
			_arg0(_v, _k - 1, cframes)
		end
	end
	function Formation:GetSpreadLimits(unitsAmount)
		return { 4, 12 }
	end
	function Formation:Hide()
		self.circle.Parent = nil
	end
	function Formation:Destroy()
		self.destroyed = true
		self.circle:Destroy()
	end
end
return {
	default = Formation,
}
