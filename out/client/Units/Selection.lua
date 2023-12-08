-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ContextActionService = _services.ContextActionService
local RunService = _services.RunService
local UserInputService = _services.UserInputService
local GetGuiInset = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "GuiInset").default
local Utils = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Utils").default
local SelectionType = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "types").SelectionType
local Input = TS.import(script, script.Parent.Parent, "Input").default
local _Instances = TS.import(script, script.Parent.Parent, "Instances")
local camera = _Instances.camera
local player = _Instances.player
local GUI = TS.import(script, script.Parent, "GUI").default
local UnitsStore = TS.import(script, script.Parent.Parent, "DataStore", "UnitsStore").default
local Replicator = TS.import(script, script.Parent.Parent, "DataStore", "Replicator").default
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local SelectionMethod
do
	local _inverse = {}
	SelectionMethod = setmetatable({}, {
		__index = _inverse,
	})
	SelectionMethod.Box = 0
	_inverse[0] = "Box"
	SelectionMethod.Single = 1
	_inverse[1] = "Single"
	SelectionMethod.None = 2
	_inverse[2] = "None"
end
local input = Input:Get()
local unitsStore = UnitsStore:Get()
local gui = GUI:Get()
local replicator = Replicator:Get()
local Selection
do
	Selection = setmetatable({}, {
		__tostring = function()
			return "Selection"
		end,
	})
	Selection.__index = Selection
	function Selection.new(...)
		local self = setmetatable({}, Selection)
		return self:constructor(...) or self
	end
	function Selection:constructor()
		self.boxSize = Vector2.new()
		self.holding = false
		self.hoveringUnits = {}
		self.selectedUnits = {}
		self.selectionType = SelectionMethod.None
		self.boxCornerPosition = Vector2.new()
		Selection.instance = self
		ContextActionService:BindAction("Selection", function(actionName, state, input)
			return self:SetHolding(state == Enum.UserInputState.Begin)
		end, false, Enum.UserInputType.MouseButton1)
		RunService:BindToRenderStep("Selection", Enum.RenderPriority.Last.Value + 1, function()
			return self:Update()
		end)
	end
	function Selection:SetHolding(state)
		local _exp = UserInputService:GetMouseLocation()
		local _vector2 = Vector2.new(0, GetGuiInset())
		local mouseLocation = _exp - _vector2
		self.holding = state
		self.boxCornerPosition = Vector2.new(mouseLocation.X, mouseLocation.Y)
		-- select all hovering units
		if not state then
			local shiftHold = input:IsButtonHolding(Enum.KeyCode.LeftShift)
			local ctrlHold = input:IsButtonHolding(Enum.KeyCode.LeftControl)
			if not shiftHold and not ctrlHold then
				self:ClearSelectedUnits()
			end
			if ctrlHold then
				self:DeselectUnits(self.hoveringUnits)
			else
				self:SelectUnits(self.hoveringUnits)
			end
		end
	end
	function Selection:FindHoveringUnits()
		local units = {}
		if self.selectionType == SelectionMethod.Box then
			for unitId, unit in unitsStore.cache do
				local position = unit:GetPosition()
				local screenPosition = (camera:WorldToScreenPoint(position))
				if screenPosition.X >= gui.hud.SelectionBox.Position.X.Offset - math.abs(gui.hud.SelectionBox.Size.X.Offset / 2) and (screenPosition.X <= gui.hud.SelectionBox.Position.X.Offset + math.abs(gui.hud.SelectionBox.Size.X.Offset / 2) and (screenPosition.Y >= gui.hud.SelectionBox.Position.Y.Offset - math.abs(gui.hud.SelectionBox.Size.Y.Offset / 2) and screenPosition.Y <= gui.hud.SelectionBox.Position.Y.Offset + math.abs(gui.hud.SelectionBox.Size.Y.Offset / 2))) then
					units[unit] = true
				end
			end
		elseif self.selectionType == SelectionMethod.Single then
			local result = Utils:GetMouseHit()
			if not result or not result.Instance then
				return units
			end
			local _result = result.Instance.Parent
			if _result ~= nil then
				_result = _result.Name
			end
			local unitId = tonumber(_result)
			if not (unitId ~= 0 and (unitId == unitId and unitId)) then
				return units
			end
			local unit = unitsStore.cache[unitId]
			if not unit then
				return units
			end
		end
		return units
	end
	function Selection:Update()
		local _exp = UserInputService:GetMouseLocation()
		local _vector2 = Vector2.new(0, GetGuiInset())
		local mouseLocation = _exp - _vector2
		local hoveringUnits = self:FindHoveringUnits()
		local boxSize = self.boxCornerPosition - mouseLocation
		local _boxCornerPosition = self.boxCornerPosition
		local _arg0 = boxSize / 2
		local middle = _boxCornerPosition - _arg0
		-- define if curently is box selecting or selecting single unit by just hovering
		self.selectionType = if boxSize.Magnitude > 3 and self.holding then SelectionMethod.Box else SelectionMethod.Single
		gui.hud.SelectionBox.Visible = self.selectionType == SelectionMethod.Box and self.holding
		-- update selectionBox ui wether
		if self.selectionType == SelectionMethod.Box then
			self.selectionType = if boxSize.Magnitude > 3 then SelectionMethod.Box else SelectionMethod.Single
			self.boxSize = boxSize
			gui.hud.SelectionBox.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)
			gui.hud.SelectionBox.Position = UDim2.fromOffset(middle.X, middle.Y)
		end
		gui.hud.SelectionBox.Visible = self.selectionType == SelectionMethod.Box
		-- unhover old units
		local _hoveringUnits = self.hoveringUnits
		local _arg0_1 = function(unit)
			local _condition = unit.selectionType == SelectionType.Hovering
			if _condition then
				local _unit = unit
				_condition = not (hoveringUnits[_unit] ~= nil)
			end
			if _condition then
				unit:Select(SelectionType.None)
			end
		end
		for _v in _hoveringUnits do
			_arg0_1(_v, _v, _hoveringUnits)
		end
		-- hover new units
		local _arg0_2 = function(unit)
			if unit.selectionType == SelectionType.None then
				unit:Select(SelectionType.Hovering)
			end
		end
		for _v in hoveringUnits do
			_arg0_2(_v, _v, hoveringUnits)
		end
		self.hoveringUnits = hoveringUnits
	end
	function Selection:ClearSelectedUnits()
		for unit in self.selectedUnits do
			unit:Select(SelectionType.None)
		end
		table.clear(self.selectedUnits)
	end
	function Selection:SelectUnits(units)
		local queue = ReplicationQueue.new()
		for unit in units do
			-- ▼ ReadonlySet.size ▼
			local _size = 0
			for _ in self.selectedUnits do
				_size += 1
			end
			-- ▲ ReadonlySet.size ▲
			if _size >= 100 then
				return nil
			end
			if self.selectedUnits[unit] ~= nil then
				return nil
			end
			if unit.playerId ~= player.UserId then
				continue
			end
			unit:Select(SelectionType.Selected)
			self.selectedUnits[unit] = true
		end
		replicator:Replicate(queue)
	end
	function Selection:DeselectUnits(units)
		local _units = units
		local _arg0 = function(unit)
			unit:Select(SelectionType.None)
			local _selectedUnits = self.selectedUnits
			local _unit = unit
			-- ▼ Set.delete ▼
			local _valueExisted = _selectedUnits[_unit] ~= nil
			_selectedUnits[_unit] = nil
			-- ▲ Set.delete ▲
			local deleted = _valueExisted
		end
		for _v in _units do
			_arg0(_v, _v, _units)
		end
	end
	function Selection:Get()
		return Selection.instance or Selection.new()
	end
end
return {
	SelectionMethod = SelectionMethod,
	default = Selection,
}
