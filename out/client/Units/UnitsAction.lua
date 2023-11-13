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
			-- ▼ ReadonlySet.size ▼
			local _size = 0
			for _ in units do
				_size += 1
			end
			-- ▲ ReadonlySet.size ▲
			if _size == 0 then
				return nil
			end
			endCallback = UnitsAction:GetActionCFrame(units, function(cframe, spread)
				UnitsAction:MoveUnits(units, cframe, spread)
				self.formationSelected:Hide()
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
			local mouseHitResult = Utils:GetMouseHit({ Workspace.TerrainParts, Workspace.Terrain }, Enum.RaycastFilterType.Include)
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
		local mouseHitResult = Utils:GetMouseHit({ Workspace.TerrainParts, Workspace.Terrain }, Enum.RaycastFilterType.Include)
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
				local _arg0_1 = unit:GetPosition()
				medianPosition = _medianPosition + _arg0_1
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
		UnitsAction.formationSelected:VisualisePositions(UnitsAction.units, UnitsAction.cframe, spread)
	end
	UnitsAction.MoveUnits = TS.async(function(self, units, cframe, spread)
		local cframes = UnitsAction.formationSelected:GetCFramesInFormation(units, cframe, spread)
		local unitsAndCFrames = UnitsAction.formationSelected:MatchUnitsToCFrames(units, cframes, cframe)
		for unit, cframe in unitsAndCFrames do
			unit:Move(cframe)
		end
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
