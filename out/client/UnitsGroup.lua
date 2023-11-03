-- Compiled with roblox-ts v2.1.1
local Formation
do
	local _inverse = {}
	Formation = setmetatable({}, {
		__index = _inverse,
	})
	Formation.Normal = 0
	_inverse[0] = "Normal"
	Formation.Line = 1
	_inverse[1] = "Line"
	Formation.Group = 2
	_inverse[2] = "Group"
end
local UnitsGroup
do
	UnitsGroup = {}
	function UnitsGroup:constructor()
	end
	function UnitsGroup:Move(units, position, formation, direction, spread)
		local groupSize = #units
		local _cFrame = CFrame.new(position)
		local _fn = CFrame
		local _condition = direction
		if not (_condition ~= 0 and (_condition == _condition and _condition)) then
			_condition = 0
		end
		local _arg0 = _fn.Angles(0, _condition, 0)
		local cframe = _cFrame * _arg0
		local _units = units
		local _arg0_1 = function(unit, index)
			local _exp = (bit32.bxor(-1, index)) * math.ceil(index / 2)
			local _condition_1 = spread
			if not (_condition_1 ~= 0 and (_condition_1 == _condition_1 and _condition_1)) then
				_condition_1 = 5
			end
			local offset = CFrame.new(_exp * _condition_1, 0, 0)
			local targetPosition = cframe * offset
			unit:Move(targetPosition)
		end
		for _k, _v in _units do
			_arg0_1(_v, _k - 1, _units)
		end
	end
end
return {
	Formation = Formation,
	default = UnitsGroup,
}
