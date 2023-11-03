-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
local Unit = TS.import(script, script.Parent, "Unit").default
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local HttpService = _services.HttpService
local Workspace = _services.Workspace
local camera = Workspace.CurrentCamera
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
		UnitsManager.cache.Name = "UnitsCache"
		Network:BindFunctions({
			createUnit = function(unitType, unitId, position)
				return UnitsManager:CreateUnit(unitType, unitId, position)
			end,
		})
	end
	function UnitsManager:GenerateUnitId()
		return HttpService:GenerateGUID(false)
	end
	function UnitsManager:CreateUnit(unitId, unitType, position)
		local unit = Unit.new(unitId, unitType, position)
		unit.model.Parent = UnitsManager.cache
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
	function UnitsManager:SelectUnits(selectedUnits)
		local _selectedUnits = self.selectedUnits
		local _arg0 = function(unit)
			unit:Select(false)
		end
		for _k, _v in _selectedUnits do
			_arg0(_v, _k - 1, _selectedUnits)
		end
		local _selectedUnits_1 = selectedUnits
		local _arg0_1 = function(unit)
			local _result = unit
			if _result ~= nil then
				_result:Select(true)
			end
		end
		for _k, _v in _selectedUnits_1 do
			_arg0_1(_v, _k - 1, _selectedUnits_1)
		end
		self.selectedUnits = selectedUnits
	end
	function UnitsManager:GetUnit(unitId)
		local _units = UnitsManager.units
		local _unitId = unitId
		return _units[_unitId]
	end
	UnitsManager.units = {}
	UnitsManager.cache = Instance.new("Folder", Workspace)
	UnitsManager.selectedUnits = {}
end
return {
	default = UnitsManager,
}
