-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Workspace = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Workspace
local Formation = TS.import(script, script.Parent, "Formation").default
local Utils = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Utils").default
local SquareFormation
do
	local super = Formation
	SquareFormation = setmetatable({}, {
		__tostring = function()
			return "SquareFormation"
		end,
		__index = super,
	})
	SquareFormation.__index = SquareFormation
	function SquareFormation.new(...)
		local self = setmetatable({}, SquareFormation)
		return self:constructor(...) or self
	end
	function SquareFormation:constructor()
		super.constructor(self, "NormalAction")
		self.circle.Middle.Transparency = 1
	end
	function SquareFormation:GetCFramesInFormation(units, mainCFrame, spread)
		local cframes = {}
		local _fn = math
		local _fn_1 = math
		-- ▼ ReadonlySet.size ▼
		local _size = 0
		for _ in units do
			_size += 1
		end
		-- ▲ ReadonlySet.size ▲
		local unitsPerRow = _fn.ceil(_fn_1.sqrt(_size))
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
				local _size_1 = 0
				for _ in units do
					_size_1 += 1
				end
				-- ▲ ReadonlySet.size ▲
				if not (_exp < _size_1) then
					break
				end
				local row = math.floor(i / unitsPerRow)
				local rowPosition = math.pow(-1, i) * math.ceil((i - row * unitsPerRow) / 2)
				local offset = CFrame.new(rowPosition * spread, 0, row * spread)
				local cframe = mainCFrame * offset
				local _fn_2 = Utils
				local _position = cframe.Position
				local _vector3 = Vector3.new(0, 10, 0)
				local groundPositionResult = _fn_2:RaycastBottom(_position + _vector3, { Workspace.TerrainParts }, Enum.RaycastFilterType.Include)
				if not groundPositionResult then
					continue
				end
				local orientation = { cframe:ToOrientation() }
				local _cFrame = CFrame.new(groundPositionResult.Position)
				local _arg0 = CFrame.Angles(orientation[1], orientation[2], orientation[3])
				local finalCFrame = _cFrame * _arg0
				table.insert(cframes, finalCFrame)
			end
		end
		return cframes
	end
end
return {
	default = SquareFormation,
}
