-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ContextActionService = _services.ContextActionService
local ReplicatedFirst = _services.ReplicatedFirst
local RunService = _services.RunService
local Workspace = _services.Workspace
local Selection = TS.import(script, script.Parent, "Selection").default
local Utils = TS.import(script, script.Parent.Parent, "Utils").default
local Normal = TS.import(script, script.Parent, "Formations", "Normal").default
local camera = Workspace.CurrentCamera
local UnitsRegroup
do
	UnitsRegroup = {}
	function UnitsRegroup:constructor()
	end
	function UnitsRegroup:Init()
		UnitsRegroup.circle = ReplicatedFirst:WaitForChild("MovementCircle"):Clone()
		UnitsRegroup.arrow = UnitsRegroup.circle.Arrow
		-- handle if LMB pressed and relesed
		ContextActionService:BindAction("unitsActions", function(actionName, state, input)
			return UnitsRegroup:Enable(state == Enum.UserInputState.Begin)
		end, false, Enum.UserInputType.MouseButton2)
	end
	function UnitsRegroup:Enable(state)
		if #Selection.selectedUnits == 0 then
			return nil
		end
		if UnitsRegroup.enabled == state then
			return nil
		end
		local mouseHitResult = Utils:GetMouseHit()
		if not mouseHitResult then
			return nil
		end
		UnitsRegroup.regroupPosition = mouseHitResult.Position
		UnitsRegroup.enabled = state
		if state then
			RunService:BindToRenderStep("UnitsRegroup", Enum.RenderPriority.Last.Value, function()
				return UnitsRegroup:Update()
			end)
		else
			UnitsRegroup:MoveGroup(Selection.selectedUnits, UnitsRegroup.circle:GetPivot(), UnitsRegroup.formationSelected, UnitsRegroup.spread)
			RunService:UnbindFromRenderStep("UnitsRegroup")
			UnitsRegroup.circle.Parent = nil
		end
	end
	function UnitsRegroup:Update()
		local mouseHitResult = Utils:GetMouseHit()
		if not mouseHitResult then
			return nil
		end
		local groundedMousePosition = Vector3.new(mouseHitResult.Position.X, UnitsRegroup.regroupPosition.Y, mouseHitResult.Position.Z)
		local _regroupPosition = UnitsRegroup.regroupPosition
		local arrowLength = (groundedMousePosition - _regroupPosition).Magnitude
		local fixedArrowLength = math.clamp(arrowLength, 2, 12)
		if arrowLength > 2 then
			UnitsRegroup.circle:PivotTo(CFrame.new(UnitsRegroup.regroupPosition, mouseHitResult.Position))
		else
			local medianPosition = Vector3.new()
			local _selectedUnits = Selection.selectedUnits
			local _arg0 = function(unit)
				local _medianPosition = medianPosition
				local _position = unit.model:GetPivot().Position
				medianPosition = _medianPosition + _position
			end
			for _k, _v in _selectedUnits do
				_arg0(_v, _k - 1, _selectedUnits)
			end
			local _fn = UnitsRegroup.circle
			local _exp = UnitsRegroup.regroupPosition
			local _medianPosition = medianPosition
			local _arg0_1 = #Selection.selectedUnits
			local _cFrame = CFrame.new(_exp, _medianPosition / _arg0_1)
			local _arg0_2 = CFrame.Angles(0, math.pi, 0)
			_fn:PivotTo(_cFrame * _arg0_2)
		end
		UnitsRegroup.circle.Parent = camera
		local _cFrame = CFrame.new(UnitsRegroup.regroupPosition, groundedMousePosition)
		local _cFrame_1 = CFrame.new(0, 0, -fixedArrowLength / 2)
		local arrowMiddle = (_cFrame * _cFrame_1).Position
		UnitsRegroup.arrow.Parent = if arrowLength < 2 then nil else UnitsRegroup.circle
		UnitsRegroup.arrow:PivotTo(CFrame.new(arrowMiddle, UnitsRegroup.regroupPosition))
		UnitsRegroup.arrow.Length.Size = Vector3.new(fixedArrowLength, UnitsRegroup.arrow.Length.Size.Y, UnitsRegroup.arrow.Length.Size.Z)
		UnitsRegroup.arrow.Length.Attachment.CFrame = CFrame.new(fixedArrowLength / 2, 0, 0)
		UnitsRegroup.arrow.Left:PivotTo(UnitsRegroup.arrow.Length.Attachment.WorldCFrame)
		UnitsRegroup.arrow.Right:PivotTo(UnitsRegroup.arrow.Length.Attachment.WorldCFrame)
		UnitsRegroup.spread = fixedArrowLength
		-- visualise positions
		local mainCFrame = UnitsRegroup.circle:GetPivot()
		local cframes = UnitsRegroup.formationSelected:GetCFramesInFormation(#Selection.selectedUnits, mainCFrame, UnitsRegroup.spread)
		UnitsRegroup.circle.Positions:ClearAllChildren()
		local _arg0 = function(cframe, i)
			if i == 0 then
				return nil
			end
			local positionPart = UnitsRegroup.circle.Middle:Clone()
			positionPart:PivotTo(cframe)
			positionPart.Parent = UnitsRegroup.circle.Positions
		end
		for _k, _v in cframes do
			_arg0(_v, _k - 1, cframes)
		end
	end
	function UnitsRegroup:MoveGroup(units, cframe, formation, spread)
		local cframes = formation:GetCFramesInFormation(#units, cframe, spread)
		local distancesArray = {}
		local _units = units
		local _arg0 = function(unit)
			local _arg0_1 = function(cframe)
				local _position = unit.model:GetPivot().Position
				local _position_1 = cframe.Position
				local distance = (_position - _position_1).Magnitude
				local _distancesArray = distancesArray
				local _arg0_2 = { unit, distance, cframe }
				table.insert(_distancesArray, _arg0_2)
			end
			for _k, _v in cframes do
				_arg0_1(_v, _k - 1, cframes)
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
			local closest = distancesArray[1]
			closest[1]:Move(closest[3])
			local newDistancesArray = {}
			local _distancesArray_1 = distancesArray
			local _arg0_2 = function(v)
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
	UnitsRegroup.formationSelected = Normal.new()
	UnitsRegroup.regroupPosition = Vector3.new()
	UnitsRegroup.enabled = false
	UnitsRegroup.spread = 2
end
return {
	default = UnitsRegroup,
}
