-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local RunService = _services.RunService
local Workspace = _services.Workspace
local Utils = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Utils").default
local LineFormation = TS.import(script, script.Parent, "Formations", "LineFormation").default
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local Input = TS.import(script, script.Parent.Parent, "Input").default
local Selection = TS.import(script, script.Parent, "Selection").default
local ClientReplicator = TS.import(script, script.Parent.Parent, "DataStore", "Replicator").default
local input = Input:Get()
local selection = Selection:Get()
local replicator = ClientReplicator:Get()
local UnitsAction
do
	UnitsAction = setmetatable({}, {
		__tostring = function()
			return "UnitsAction"
		end,
	})
	UnitsAction.__index = UnitsAction
	function UnitsAction.new(...)
		local self = setmetatable({}, UnitsAction)
		return self:constructor(...) or self
	end
	function UnitsAction:constructor()
		self.enabled = false
		self.units = {}
		self.formationSelected = LineFormation.new()
		self.spreadLimits = { 0, 0 }
		self.cframe = CFrame.new()
		self.startPosition = Vector3.new()
		self.spread = 0
		UnitsAction.instance = self
		local endCallback
		input:Bind(Enum.UserInputType.MouseButton2, Enum.UserInputState.Begin, function()
			local units = selection.selectedUnits
			-- ▼ ReadonlySet.size ▼
			local _size = 0
			for _ in units do
				_size += 1
			end
			-- ▲ ReadonlySet.size ▲
			if _size == 0 then
				return nil
			end
			endCallback = self:GetActionCFrame(units, function(cframe, spread)
				self:MoveUnits(units, cframe, spread)
				self.formationSelected:Hide()
			end)
		end)
		input:Bind(Enum.UserInputType.MouseButton2, Enum.UserInputState.End, function()
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
		self.units = units
		local _fn = self.formationSelected
		-- ▼ ReadonlySet.size ▼
		local _size = 0
		for _ in units do
			_size += 1
		end
		-- ▲ ReadonlySet.size ▲
		self.spreadLimits = _fn:GetSpreadLimits(_size)
		self:Enable(true)
		local endCallback = function()
			resultCallback(self.cframe, self.spread)
			self:Enable(false)
		end
		return endCallback
	end
	function UnitsAction:Enable(state)
		-- ▼ ReadonlySet.size ▼
		local _size = 0
		for _ in self.units do
			_size += 1
		end
		-- ▲ ReadonlySet.size ▲
		if _size == 0 then
			return nil
		end
		if self.enabled == state then
			return nil
		end
		if state then
			local mouseHitResult = Utils:GetMouseHit({ Workspace.TerrainParts, Workspace.Terrain }, Enum.RaycastFilterType.Include)
			if not mouseHitResult then
				return nil
			end
			self.startPosition = mouseHitResult.Position
			RunService:BindToRenderStep("UnitsAction", Enum.RenderPriority.Last.Value, function()
				return self:Update()
			end)
		else
			RunService:UnbindFromRenderStep("UnitsAction")
		end
		self.enabled = state
	end
	function UnitsAction:Update()
		local mouseHitResult = Utils:GetMouseHit({ Workspace.TerrainParts, Workspace.Terrain }, Enum.RaycastFilterType.Include)
		if not mouseHitResult then
			return nil
		end
		local groundedMousePosition = Vector3.new(mouseHitResult.Position.X, self.startPosition.Y, mouseHitResult.Position.Z)
		local _startPosition = self.startPosition
		local arrowLength = (groundedMousePosition - _startPosition).Magnitude
		local spread = math.clamp(arrowLength, self.spreadLimits[1], self.spreadLimits[2])
		self.spread = spread
		if self.startPosition == mouseHitResult.Position then
			local medianPosition = Vector3.new()
			local _units = self.units
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
			for _ in self.units do
				_size += 1
			end
			-- ▲ ReadonlySet.size ▲
			medianPosition = _medianPosition / _size
			local groundedMedianPosition = Vector3.new(medianPosition.X, self.startPosition.Y, medianPosition.Z)
			local _cFrame = CFrame.new(self.startPosition, groundedMedianPosition)
			local _arg0_1 = CFrame.Angles(0, math.pi, 0)
			self.cframe = _cFrame * _arg0_1
		else
			self.cframe = CFrame.new(self.startPosition, groundedMousePosition)
		end
		self.formationSelected:VisualisePositions(self.units, self.cframe, spread)
	end
	UnitsAction.MoveUnits = TS.async(function(self, units, cframe, spread)
		local cframes = self.formationSelected:GetCFramesInFormation(units, cframe, spread)
		local unitsAndCFrames = self.formationSelected:MatchUnitsToCFrames(units, cframes, cframe)
		local queue = ReplicationQueue.new()
		local promises = {}
		local _arg0 = function(targetCFrame, unit)
			local promise = unit.pathfinding:ComputePath(targetCFrame.Position)
			table.insert(promises, promise)
		end
		for _k, _v in unitsAndCFrames do
			_arg0(_v, _k, unitsAndCFrames)
		end
		local computedPaths = TS.await(TS.Promise.all(promises))
		for _, _binding in computedPaths do
			local unit = _binding[1]
			local path = _binding[2]
			unit.movement:MoveAlongPath(path, queue)
		end
		replicator:Replicate(queue)
	end)
	function UnitsAction:Get()
		return UnitsAction.instance or UnitsAction.new()
	end
end
return {
	default = UnitsAction,
}
