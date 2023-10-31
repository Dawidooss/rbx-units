-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
local Unit = TS.import(script, script.Parent, "Unit").default
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local HttpService = _services.HttpService
local Workspace = _services.Workspace
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
	function UnitsManager:SelectUnitsAt(min, max)
		local selectedUnits = {}
		if max then
			-- select units at bounds
			local _units = UnitsManager.units
			local _arg0 = function(unit)
				if unit.position.X >= min.X and (unit.position.X <= max.X and (unit.position.Y >= min.Y and (unit.position.Y <= max.Y and (unit.position.Z >= min.Z and unit.position.Z <= max.Z)))) then
					local _selectedUnits = selectedUnits
					local _unit = unit
					table.insert(_selectedUnits, _unit)
				end
			end
			for _k, _v in _units do
				_arg0(_v, _k, _units)
			end
		else
			local closestUnit
			local closestUnitDistance = math.huge
			-- select unit at position
			for _, unit in UnitsManager.units do
				local _position = unit.position
				local _min = min
				local distance = (_position - _min).Magnitude
				if distance <= 2 and distance < closestUnitDistance then
					closestUnit = unit
					closestUnitDistance = distance
				end
			end
			if closestUnit then
				local _selectedUnits = selectedUnits
				local _closestUnit = closestUnit
				table.insert(_selectedUnits, _closestUnit)
			end
		end
	end
	UnitsManager.units = {}
	UnitsManager.cache = Instance.new("Folder", Workspace)
	UnitsManager.selectedUnits = {}
end
return {
	default = UnitsManager,
}
