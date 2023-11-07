-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local RunService = _services.RunService
local Workspace = _services.Workspace
local Utils = TS.import(script, script.Parent.Parent, "Utils").default
local Input = TS.import(script, script.Parent.Parent, "Input").default
local Selection = TS.import(script, script.Parent, "Selection").default
local LineFormation = TS.import(script, script.Parent, "Formations", "LineFormation").default
local camera = Workspace.CurrentCamera
local UnitsAction
do
	UnitsAction = {}
	function UnitsAction:constructor()
	end
	function UnitsAction:Init()
		local endCallback
		Input:Bind(Enum.UserInputType.MouseButton2, Enum.UserInputState.Begin, function()
			local units = Selection.selectedUnits
			endCallback = UnitsAction:GetActionCFrame(units, function(cframe, spread)
				UnitsAction:MoveUnits(units, cframe, spread)
			end)
		end)
		Input:Bind(Enum.UserInputType.MouseButton2, Enum.UserInputState.End, function()
			local _result = endCallback
			if _result ~= nil then
				_result()
			end
		end)
	end
	function UnitsAction:SetFormation(formation)
		local oldFormation = self.formationSelected
		self.formationSelected = formation
		oldFormation:Destroy()
	end
	function UnitsAction:GetActionCFrame(units, resultCallback)
		UnitsAction.units = units
		local _fn = UnitsAction.formationSelected
		-- ▼ ReadonlySet.size ▼
		local _size = 0
		for _ in units do
			_size += 1
		end
		-- ▲ ReadonlySet.size ▲
		UnitsAction.spreadLimits = _fn:GetSpreadLimits(_size)
		UnitsAction:Enable(true)
		local endCallback = function()
			resultCallback(UnitsAction.cframe, UnitsAction.spread)
			UnitsAction:Enable(false)
		end
		return endCallback
	end
	function UnitsAction:Enable(state)
		-- ▼ ReadonlySet.size ▼
		local _size = 0
		for _ in UnitsAction.units do
			_size += 1
		end
		-- ▲ ReadonlySet.size ▲
		if _size == 0 then
			return nil
		end
		if UnitsAction.enabled == state then
			return nil
		end
		if state then
			local mouseHitResult = Utils:GetMouseHit()
			if not mouseHitResult then
				return nil
			end
			UnitsAction.startPosition = mouseHitResult.Position
			RunService:BindToRenderStep("unitsAction", Enum.RenderPriority.Last.Value, function()
				return UnitsAction:Update()
			end)
		else
			RunService:UnbindFromRenderStep("unitsAction")
		end
		UnitsAction.enabled = state
	end
	function UnitsAction:Update()
		local mouseHitResult = Utils:GetMouseHit()
		if not mouseHitResult then
			return nil
		end
		local groundedMousePosition = Vector3.new(mouseHitResult.Position.X, UnitsAction.startPosition.Y, mouseHitResult.Position.Z)
		local _startPosition = UnitsAction.startPosition
		local arrowLength = (groundedMousePosition - _startPosition).Magnitude
		local spread = math.clamp(arrowLength, UnitsAction.spreadLimits[1], UnitsAction.spreadLimits[2])
		UnitsAction.spread = spread
		if UnitsAction.startPosition == mouseHitResult.Position then
			local medianPosition = Vector3.new()
			local _units = UnitsAction.units
			local _arg0 = function(unit)
				local _medianPosition = medianPosition
				local _position = unit.model:GetPivot().Position
				medianPosition = _medianPosition + _position
			end
			for _v in _units do
				_arg0(_v, _v, _units)
			end
			local _medianPosition = medianPosition
			-- ▼ ReadonlySet.size ▼
			local _size = 0
			for _ in UnitsAction.units do
				_size += 1
			end
			-- ▲ ReadonlySet.size ▲
			medianPosition = _medianPosition / _size
			local groundedMedianPosition = Vector3.new(medianPosition.X, UnitsAction.startPosition.Y, medianPosition.Z)
			local _cFrame = CFrame.new(UnitsAction.startPosition, groundedMedianPosition)
			local _arg0_1 = CFrame.Angles(0, math.pi, 0)
			UnitsAction.cframe = _cFrame * _arg0_1
		else
			UnitsAction.cframe = CFrame.new(UnitsAction.startPosition, groundedMousePosition)
		end
		local _fn = UnitsAction.formationSelected
		-- ▼ ReadonlySet.size ▼
		local _size = 0
		for _ in UnitsAction.units do
			_size += 1
		end
		-- ▲ ReadonlySet.size ▲
		_fn:VisualisePositions(_size, UnitsAction.cframe, spread)
	end
	UnitsAction.MoveUnits = TS.async(function(self, units, cframe, spread)
		local _fn = UnitsAction.formationSelected
		-- ▼ ReadonlySet.size ▼
		local _size = 0
		for _ in units do
			_size += 1
		end
		-- ▲ ReadonlySet.size ▲
		local cframes = _fn:GetCFramesInFormation(_size, cframe, spread)
		local distancesArray = {}
		for unit in units do
			local pivotPosition = unit.model:GetPivot().Position
			for _, cframe in cframes do
				local _position = cframe.Position
				local distance = (pivotPosition - _position).Magnitude
				local _distancesArray = distancesArray
				local _arg0 = { unit, distance, cframe }
				table.insert(_distancesArray, _arg0)
			end
		end
		local _distancesArray = distancesArray
		local _arg0 = function(a, b)
			return a[2] < b[2]
		end
		table.sort(_distancesArray, _arg0)
		while #distancesArray > 0 do
			local closest = distancesArray[1]
			closest[1]:Move(closest[3])
			local newDistancesArray = {}
			local _distancesArray_1 = distancesArray
			local _arg0_1 = function(v)
				if v[1] ~= closest[1] and v[3] ~= closest[3] then
					local _v = v
					table.insert(newDistancesArray, _v)
				end
			end
			for _k, _v in _distancesArray_1 do
				_arg0_1(_v, _k - 1, _distancesArray_1)
			end
			distancesArray = newDistancesArray
		end
		UnitsAction.formationSelected:Hide()
	end)
	UnitsAction.enabled = false
	UnitsAction.units = {}
	UnitsAction.formationSelected = LineFormation.new()
	UnitsAction.cframe = CFrame.new()
	UnitsAction.startPosition = Vector3.new()
	UnitsAction.spread = 0
end
return {
	default = UnitsAction,
}
