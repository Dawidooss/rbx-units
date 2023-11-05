-- Compiled with roblox-ts v2.2.0
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
		local _units = UnitsManager.units
		local _unitId = unitId
		_units[_unitId] = unit
	end
	function UnitsManager:RemoveUnit(unitId)
		local _units = UnitsManager.units
		local _unitId = unitId
		local unit = _units[_unitId]
		if not unit then
			return nil
		end
		local _units_1 = UnitsManager.units
		local _unitId_1 = unitId
		_units_1[_unitId_1] = nil
		unit:Destroy()
	end
	function UnitsManager:UpdateUnit(unitId, data)
	end
	function UnitsManager:GetUnit(unitId)
		local _units = UnitsManager.units
		local _unitId = unitId
		return _units[_unitId]
	end
	function UnitsManager:GetUnits()
		return UnitsManager.units
	end
	UnitsManager.units = {}
	UnitsManager.cache = Instance.new("Folder", Workspace)
end
return {
	default = UnitsManager,
}
