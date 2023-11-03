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
		local loopCount = 0
		local positions = UnitsGroup:GetPositionsInFormation(#units, position, formation, direction, spread)
		local distancesArray = {}
		local _units = units
		local _arg0 = function(unit, index)
			loopCount += 1
			local _arg0_1 = function(position)
				loopCount += 1
				local _position = unit.model:GetPivot().Position
				local _position_1 = position
				local distance = (_position - _position_1).Magnitude
				local _distancesArray = distancesArray
				local _arg0_2 = { unit, distance, position }
				table.insert(_distancesArray, _arg0_2)
			end
			for _k, _v in positions do
				_arg0_1(_v, _k - 1, positions)
			end
		end
		for _k, _v in _units do
			_arg0(_v, _k - 1, _units)
		end
		local _distancesArray = distancesArray
		local _arg0_1 = function(a, b)
			return a[2] < b[2]
		end
		table.sort(_distancesArray, _arg0_1)
		while #distancesArray > 0 do
			loopCount += 1
			local closest = distancesArray[1]
			closest[1]:Move(closest[3])
			local newDistancesArray = {}
			local _distancesArray_1 = distancesArray
			local _arg0_2 = function(v)
				loopCount += 1
				if v[1] ~= closest[1] and v[3] ~= closest[3] then
					local _v = v
					table.insert(newDistancesArray, _v)
				end
			end
			for _k, _v in _distancesArray_1 do
				_arg0_2(_v, _k - 1, _distancesArray_1)
			end
			distancesArray = newDistancesArray
		end
	end
	function UnitsGroup:GetPositionsInFormation(size, position, formatiion, direction, spread)
		local positions = {}
		local _cFrame = CFrame.new(position)
		local _fn = CFrame
		local _condition = direction
		if not (_condition ~= 0 and (_condition == _condition and _condition)) then
			_condition = 0
		end
		local _arg0 = _fn.Angles(0, _condition, 0)
		local cframe = _cFrame * _arg0
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < size) then
					break
				end
				local _exp = math.pow(-1, i) * math.ceil(i / 2)
				local _condition_1 = spread
				if not (_condition_1 ~= 0 and (_condition_1 == _condition_1 and _condition_1)) then
					_condition_1 = 5
				end
				local offset = CFrame.new(_exp * _condition_1, 0, 0)
				local targetPosition = cframe * offset
				local _position = targetPosition.Position
				table.insert(positions, _position)
			end
		end
		return positions
	end
end
return {
	Formation = Formation,
	default = UnitsGroup,
}
