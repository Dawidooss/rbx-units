-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ContextActionService = _services.ContextActionService
local Players = _services.Players
local RunService = _services.RunService
local UserInputService = _services.UserInputService
local Workspace = _services.Workspace
local guiInset = TS.import(script, script.Parent, "GuiInset").default
local UnitSelectionType = TS.import(script, script.Parent, "Unit").UnitSelectionType
local UnitsManager = TS.import(script, script.Parent, "UnitsManager").default
local Input = TS.import(script, script.Parent, "Input").default
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera
local SelectionType
do
	local _inverse = {}
	SelectionType = setmetatable({}, {
		__index = _inverse,
	})
	SelectionType.Box = 0
	_inverse[0] = "Box"
	SelectionType.Single = 1
	_inverse[1] = "Single"
	SelectionType.None = 2
	_inverse[2] = "None"
end
local Selection
do
	Selection = {}
	function Selection:constructor()
	end
	function Selection:Init()
		Selection.gui = playerGui:WaitForChild("HUD"):WaitForChild("SelectionBox")
		-- handle if LMB pressed and relesed
		ContextActionService:BindAction("selection", function(actionName, state, input)
			return Selection:SetHolding(state == Enum.UserInputState.Begin)
		end, false, Enum.UserInputType.MouseButton1)
		RunService:BindToRenderStep("Selection", Enum.RenderPriority.Last.Value + 1, function()
			return Selection:Update()
		end)
	end
	function Selection:SetHolding(state)
		local _exp = UserInputService:GetMouseLocation()
		local _vector2 = Vector2.new(0, guiInset)
		local mouseLocation = _exp - _vector2
		Selection.holding = state
		Selection.boxCornerPosition = Vector2.new(mouseLocation.X, mouseLocation.Y)
		-- select all hovering units
		if not state then
			local shiftHold = Input:IsButtonHolding(Enum.KeyCode.LeftShift)
			local ctrlHold = Input:IsButtonHolding(Enum.KeyCode.LeftControl)
			if not shiftHold and not ctrlHold then
				Selection:ClearSelectedUnits()
			end
			if ctrlHold then
				Selection:DeselectUnits(self.hoveringUnits)
			else
				Selection:SelectUnits(self.hoveringUnits)
			end
		end
	end
	function Selection:GetUnits()
		local units = {}
		if Selection.selectionType == SelectionType.Box then
			local _exp = UnitsManager:GetUnits()
			local _arg0 = function(unit)
				local pivot = unit.model:GetPivot()
				local screenPosition = (camera:WorldToScreenPoint(pivot.Position))
				if screenPosition.X >= Selection.gui.Position.X.Offset - math.abs(Selection.gui.Size.X.Offset / 2) and (screenPosition.X <= Selection.gui.Position.X.Offset + math.abs(Selection.gui.Size.X.Offset / 2) and (screenPosition.Y >= Selection.gui.Position.Y.Offset - math.abs(Selection.gui.Size.Y.Offset / 2) and screenPosition.Y <= Selection.gui.Position.Y.Offset + math.abs(Selection.gui.Size.Y.Offset / 2))) then
					local _unit = unit
					table.insert(units, _unit)
				end
			end
			for _k, _v in _exp do
				_arg0(_v, _k, _exp)
			end
		elseif Selection.selectionType == SelectionType.Single then
			local mouseLocation = UserInputService:GetMouseLocation()
			local mouseRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
			local result = Workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 10000)
			if not result or not result.Instance then
				return {}
			end
			local _fn = UnitsManager
			local _result = result.Instance.Parent
			if _result ~= nil then
				_result = _result.Name
			end
			local _condition = _result
			if not (_condition ~= "" and _condition) then
				_condition = ""
			end
			local unit = _fn:GetUnit(_condition)
			if not unit then
				return {}
			end
			table.insert(units, unit)
		end
		return units
	end
	function Selection:Update()
		local _exp = UserInputService:GetMouseLocation()
		local _vector2 = Vector2.new(0, guiInset)
		local mouseLocation = _exp - _vector2
		local hoveringUnits = Selection:GetUnits()
		local boxSize = Selection.boxCornerPosition - mouseLocation
		local _boxCornerPosition = Selection.boxCornerPosition
		local _arg0 = boxSize / 2
		local middle = _boxCornerPosition - _arg0
		-- define if curently is box selecting or selecting single unit by just hovering
		Selection.selectionType = if boxSize.Magnitude > 3 and Selection.holding then SelectionType.Box else SelectionType.Single
		Selection.gui.Visible = Selection.selectionType == SelectionType.Box and Selection.holding
		-- update selectionBox ui wether
		if Selection.selectionType == SelectionType.Box then
			Selection.selectionType = if boxSize.Magnitude > 3 then SelectionType.Box else SelectionType.Single
			Selection.boxSize = boxSize
			Selection.gui.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)
			Selection.gui.Position = UDim2.fromOffset(middle.X, middle.Y)
		end
		Selection.gui.Visible = Selection.selectionType == SelectionType.Box
		-- unhover old units
		local _hoveringUnits = Selection.hoveringUnits
		local _arg0_1 = function(unit)
			local _condition = unit.selectionType == UnitSelectionType.Hovering
			if _condition then
				local _arg0_2 = function(v)
					return v == unit
				end
				-- ▼ ReadonlyArray.find ▼
				local _result
				for _i, _v in hoveringUnits do
					if _arg0_2(_v, _i - 1, hoveringUnits) == true then
						_result = _v
						break
					end
				end
				-- ▲ ReadonlyArray.find ▲
				_condition = not _result
			end
			if _condition then
				unit:Select(UnitSelectionType.None)
			end
		end
		for _k, _v in _hoveringUnits do
			_arg0_1(_v, _k - 1, _hoveringUnits)
		end
		-- hover new units
		local _arg0_2 = function(unit)
			if unit.selectionType == UnitSelectionType.None then
				unit:Select(UnitSelectionType.Hovering)
			end
		end
		for _k, _v in hoveringUnits do
			_arg0_2(_v, _k - 1, hoveringUnits)
		end
		Selection.hoveringUnits = hoveringUnits
	end
	function Selection:ClearSelectedUnits()
		local _selectedUnits = Selection.selectedUnits
		local _arg0 = function(unit)
			unit:Select(UnitSelectionType.None)
		end
		for _k, _v in _selectedUnits do
			_arg0(_v, _k - 1, _selectedUnits)
		end
	end
	function Selection:SelectUnits(units)
		local _units = units
		local _arg0 = function(unit)
			unit:Select(UnitSelectionType.Selected)
			local _selectedUnits = Selection.selectedUnits
			local _unit = unit
			table.insert(_selectedUnits, _unit)
		end
		for _k, _v in _units do
			_arg0(_v, _k - 1, _units)
		end
	end
	function Selection:DeselectUnits(units)
		local _units = units
		local _arg0 = function(unit)
			unit:Select(UnitSelectionType.None)
			local _selectedUnits = Selection.selectedUnits
			local _arg0_1 = function(v)
				return v == unit
			end
			-- ▼ ReadonlyArray.findIndex ▼
			local _result = -1
			for _i, _v in _selectedUnits do
				if _arg0_1(_v, _i - 1, _selectedUnits) == true then
					_result = _i - 1
					break
				end
			end
			-- ▲ ReadonlyArray.findIndex ▲
			local unitIndex = _result
			if unitIndex ~= 0 and (unitIndex == unitIndex and unitIndex) then
				table.remove(Selection.selectedUnits, unitIndex + 1)
			end
		end
		for _k, _v in _units do
			_arg0(_v, _k - 1, _units)
		end
	end
	Selection.selectionType = SelectionType.None
	Selection.boxCornerPosition = Vector2.new()
	Selection.boxSize = Vector2.new()
	Selection.hoveringUnits = {}
	Selection.selectedUnits = {}
end
return {
	default = Selection,
}
