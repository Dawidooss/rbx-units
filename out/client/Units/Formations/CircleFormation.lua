-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Workspace = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Workspace
local Formation = TS.import(script, script.Parent, "Formation").default
local Utils = TS.import(script, script.Parent.Parent.Parent, "Utils").default
local camera = Workspace.CurrentCamera
local CircleFormation
do
	local super = Formation
	CircleFormation = setmetatable({}, {
		__tostring = function()
			return "CircleFormation"
		end,
		__index = super,
	})
	CircleFormation.__index = CircleFormation
	function CircleFormation.new(...)
		local self = setmetatable({}, CircleFormation)
		return self:constructor(...) or self
	end
	function CircleFormation:constructor()
		super.constructor(self, "CircularAction")
	end
	function CircleFormation:GetCFramesInFormation(units, mainCFrame, spread)
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
				local _exp = i
				-- ▼ ReadonlySet.size ▼
				local _size = 0
				for _ in units do
					_size += 1
				end
				-- ▲ ReadonlySet.size ▲
				if not (_exp < _size) then
					break
				end
				-- ▼ ReadonlySet.size ▼
				local _size_1 = 0
				for _ in units do
					_size_1 += 1
				end
				-- ▲ ReadonlySet.size ▲
				local rotation = (360 / _size_1) * i
				local _mainCFrame = mainCFrame
				local _arg0 = CFrame.Angles(0, math.rad(rotation) + math.pi, 0)
				local _cFrame = CFrame.new(0, 0, -spread)
				local cframe = _mainCFrame * _arg0 * _cFrame
				local _fn = Utils
				local _position = cframe.Position
				local _vector3 = Vector3.new(0, 10, 0)
				local groundPositionResult = _fn:RaycastBottom(_position + _vector3, { Workspace.TerrainParts }, Enum.RaycastFilterType.Include)
				if not groundPositionResult then
					continue
				end
				local orientation = { cframe:ToOrientation() }
				local _cFrame_1 = CFrame.new(groundPositionResult.Position)
				local _arg0_1 = CFrame.Angles(orientation[1], orientation[2], orientation[3])
				local finalCFrame = _cFrame_1 * _arg0_1
				table.insert(cframes, finalCFrame)
			end
		end
		return cframes
	end
	function CircleFormation:VisualisePositions(units, cframe, spread)
		if self.destroyed then
			return nil
		end
		self.circle:PivotTo(CFrame.new(cframe.Position))
		self.circle.Parent = camera
		self.circle.Middle.Size = Vector3.new(self.circle.Middle.Size.X, spread * 2, spread * 2)
	end
	function CircleFormation:GetSpreadLimits(amountOfUnits)
		local positionsUsed = 5
		local minSpread = 4
		while positionsUsed < amountOfUnits do
			minSpread += 2
			positionsUsed = math.floor((3 / 2) * minSpread)
		end
		return { minSpread, math.max(minSpread, 20) }
	end
end
return {
	default = CircleFormation,
}
