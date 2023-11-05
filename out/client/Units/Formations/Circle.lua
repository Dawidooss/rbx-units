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
				local rotation = (360 / size) * i
				local _mainCFrame = mainCFrame
				local _arg0 = CFrame.Angles(0, math.rad(rotation) + math.pi, 0)
				local _cFrame = CFrame.new(0, 0, -spread)
				local cframe = _mainCFrame * _arg0 * _cFrame
				table.insert(cframes, cframe)
			end
		end
		return cframes
	end
	function Circle:VisualisePositions(units, cframe, spread)
		if self.destroyed then
			return nil
		end
		self.circle:PivotTo(CFrame.new(cframe.Position))
		self.circle.Parent = camera
		self.circle.Middle.Size = Vector3.new(self.circle.Middle.Size.X, spread * 2, spread * 2)
	end
end
return {
	default = Circle,
}
