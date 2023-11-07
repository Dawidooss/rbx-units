-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Selectable = TS.import(script, script.Parent, "Selectable").default
local Selection = TS.import(script, script.Parent, "Selection").default
local Unit = TS.import(script, script.Parent, "Unit").default
local UnitsGroup
do
	local super = Selectable
	UnitsGroup = setmetatable({}, {
		__tostring = function()
			return "UnitsGroup"
		end,
		__index = super,
	})
	UnitsGroup.__index = UnitsGroup
	function UnitsGroup.new(...)
		local self = setmetatable({}, UnitsGroup)
		return self:constructor(...) or self
	end
	function UnitsGroup:constructor(units)
		super.constructor(self)
		self.units = {}
		self.units = units
		for unit in units do
			unit.group = self
		end
	end
	function UnitsGroup:Select(selectionType)
		for unit in self.units do
			unit:Select(selectionType)
		end
	end
	function UnitsGroup:FormGroup(selectables)
		local units = {}
		for unit in selectables do
			if TS.instanceof(unit, Unit) and not unit.group then
				units[unit] = true
			end
		end
		-- ▼ ReadonlySet.size ▼
		local _size = 0
		for _ in units do
			_size += 1
		end
		-- ▲ ReadonlySet.size ▲
		if _size == 0 then
			return nil
		end
		local group = UnitsGroup.new(units)
		local groupSet = {}
		groupSet[group] = true
		Selection:ClearSelectedUnits()
		Selection:SelectUnits(groupSet)
	end
end
return {
	default = UnitsGroup,
}
