-- Compiled with roblox-ts v2.2.0
local UnitData
do
	UnitData = setmetatable({}, {
		__tostring = function()
			return "UnitData"
		end,
	})
	UnitData.__index = UnitData
	function UnitData.new(...)
		local self = setmetatable({}, UnitData)
		return self:constructor(...) or self
	end
	function UnitData:constructor()
	end
end
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
	function Unit:constructor(unitId, position)
		self.unitId = unitId
		self.position = position
	end
	function Unit:Destroy()
	end
end
return {
	UnitData = UnitData,
	default = Unit,
}
