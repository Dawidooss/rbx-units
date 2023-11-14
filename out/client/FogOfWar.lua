-- Compiled with roblox-ts v2.2.0
local FogMap
local FogOfWar
do
	FogOfWar = setmetatable({}, {
		__tostring = function()
			return "FogOfWar"
		end,
	})
	FogOfWar.__index = FogOfWar
	function FogOfWar.new(...)
		local self = setmetatable({}, FogOfWar)
		return self:constructor(...) or self
	end
	function FogOfWar:constructor()
		self.fogMap = FogMap.new()
		FogOfWar.instance = self
	end
	function FogOfWar:get()
		return FogOfWar.instance or FogOfWar.new()
	end
	function FogOfWar:SetMap()
	end
	function FogOfWar:Render()
		for i, fogType in self.fogMap.map do
			local coords = self.fogMap:indexToCoords(i)
		end
	end
end
local FogType
do
	local _inverse = {}
	FogType = setmetatable({}, {
		__index = _inverse,
	})
	FogType.Visible = 0
	_inverse[0] = "Visible"
	FogType.SemiVisible = 1
	_inverse[1] = "SemiVisible"
	FogType.Hidden = 2
	_inverse[2] = "Hidden"
end
do
	FogMap = setmetatable({}, {
		__tostring = function()
			return "FogMap"
		end,
	})
	FogMap.__index = FogMap
	function FogMap.new(...)
		local self = setmetatable({}, FogMap)
		return self:constructor(...) or self
	end
	function FogMap:constructor(width, map)
		self.map = map or {}
		local _condition = width
		if not (_condition ~= 0 and (_condition == _condition and _condition)) then
			_condition = 0
		end
		self.width = _condition
	end
	function FogMap:getAtCoords(x, y)
		local i = x + y * self.width
		return self.map[i]
	end
	function FogMap:indexToCoords(i)
		local y = math.floor(i / self.width)
		local x = i % self.width
		return {
			x = x,
			y = y,
		}
	end
end
return {
	default = FogOfWar,
	FogType = FogType,
	FogMap = FogMap,
}
