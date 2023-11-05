-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Workspace = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Workspace
local Formation = TS.import(script, script.Parent, "Formation").default
local camera = Workspace.CurrentCamera
local Circle
do
	local super = Formation
	Circle = setmetatable({}, {
		__tostring = function()
			return "Circle"
		end,
		__index = super,
	})
	Circle.__index = Circle
	function Circle.new(...)
		local self = setmetatable({}, Circle)
		return self:constructor(...) or self
	end
	function Circle:constructor()
		super.constructor(self, "CircularAction")
	end
	function Circle:GetCFramesInFormation(size, mainCFrame, spread)
		local cframes = {}
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < size) then
					break
				end
				local row = math.floor(i / 10)
				local rowPosition = math.pow(-1, i) * math.ceil((i - row * 10) / 2)
				local offset = CFrame.new(rowPosition * spread, 0, row * spread)
				local cframe = mainCFrame * offset
				table.insert(cframes, cframe)
			end
		end
		return cframes
	end
	function Circle:VisualisePositions(units, cframe, spread)
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
end
return {
	default = Circle,
}
