-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
local Unit = TS.import(script, script.Parent, "Unit").default
local UnitsManager
do
	UnitsManager = setmetatable({}, {
		__tostring = function()
			return "UnitsManager"
		end,
	})
	UnitsManager.__index = UnitsManager
	function UnitsManager.new(...)
		local self = setmetatable({}, UnitsManager)
		return self:constructor(...) or self
	end
	function UnitsManager:constructor()
	end
	function UnitsManager:Init()
		Network:BindFunctions({
			createUnit = function(unitType, unitId, position)
				return UnitsManager:CreateUnit(unitType, unitId, position)
			end,
		})
	end
	function UnitsManager:CreateUnit(unitType, unitId, position)
		local unit = Unit.new(unitId, position)
		local _units = self.units
		local _unitId = unitId
		_units[_unitId] = unit
	end
	function UnitsManager:RemoveUnit(unitId)
		local _units = self.units
		local _unitId = unitId
		local unit = _units[_unitId]
		if not unit then
			return nil
		end
		local _units_1 = self.units
		local _unitId_1 = unitId
		_units_1[_unitId_1] = nil
		unit:Destroy()
	end
	function UnitsManager:UpdateUnit(unitId, data)
	end
	UnitsManager.units = {}
end
return {
	default = UnitsManager,
}
