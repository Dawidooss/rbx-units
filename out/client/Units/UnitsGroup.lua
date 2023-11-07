-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Selectable = TS.import(script, script.Parent, "Selectable").default
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
		self.offsets = {}
		self.units = units
		local position = self:GetPosition()
		for unit in units do
			local _exp = unit.model:GetPivot()
			local _arg0 = CFrame.new(position):Inverse()
			local offset = _exp * _arg0
			self.offsets[unit] = offset
		end
	end
	function UnitsGroup:Select(selectionType)
		for unit in self.units do
			unit:Select(selectionType)
		end
		self.selectionType = selectionType
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
		return UnitsGroup.new(units)
	end
	function UnitsGroup:GetPosition()
		local position = Vector3.new()
		for unit in self.units do
			unit.group = self
			local _position = position
			local _position_1 = unit.model:GetPivot().Position
			position = _position + _position_1
		end
		local _position = position
		-- ▼ ReadonlySet.size ▼
		local _size = 0
		for _ in self.units do
			_size += 1
		end
		-- ▲ ReadonlySet.size ▲
		position = _position / _size
		return position
	end
	function UnitsGroup:Move(cframe)
		for unit in self.units do
			local offset = self.offsets[unit]
			if not offset then
				continue
			end
			unit:Move(cframe * offset)
		end
	end
end
return {
	default = UnitsGroup,
}
