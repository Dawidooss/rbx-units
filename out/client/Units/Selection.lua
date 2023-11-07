-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ContextActionService = _services.ContextActionService
local Players = _services.Players
local RunService = _services.RunService
local UserInputService = _services.UserInputService
local Workspace = _services.Workspace
local guiInset = TS.import(script, script.Parent.Parent, "GuiInset").default
local UnitsManager = TS.import(script, script.Parent, "UnitsManager").default
local Input = TS.import(script, script.Parent.Parent, "Input").default
local HUD = TS.import(script, script.Parent, "HUD").default
local SelectionType = TS.import(script, script.Parent, "Selectable").SelectionType
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera
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
local Selection
do
	Selection = {}
	function Selection:constructor()
	end
	function Selection:Init()
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
	function Selection:FindHoveringUnits()
		local units = {}
		if Selection.selectionType == SelectionMethod.Box then
			for _, unit in UnitsManager:GetUnits() do
				local pivot = unit.model:GetPivot()
				local screenPosition = (camera:WorldToScreenPoint(pivot.Position))
				if screenPosition.X >= HUD.gui.SelectionBox.Position.X.Offset - math.abs(HUD.gui.SelectionBox.Size.X.Offset / 2) and (screenPosition.X <= HUD.gui.SelectionBox.Position.X.Offset + math.abs(HUD.gui.SelectionBox.Size.X.Offset / 2) and (screenPosition.Y >= HUD.gui.SelectionBox.Position.Y.Offset - math.abs(HUD.gui.SelectionBox.Size.Y.Offset / 2) and screenPosition.Y <= HUD.gui.SelectionBox.Position.Y.Offset + math.abs(HUD.gui.SelectionBox.Size.Y.Offset / 2))) then
					if unit.group then
						table.clear(units)
						local _group = unit.group
						units[_group] = true
						break
					end
					units[unit] = true
				end
			end
		elseif Selection.selectionType == SelectionMethod.Single then
			local mouseLocation = UserInputService:GetMouseLocation()
			local mouseRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
			local result = Workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 10000)
			if not result or not result.Instance then
				return units
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
				return units
			end
			local _arg0 = unit.group or unit
			units[_arg0] = true
		end
		return units
	end
	function Selection:Update()
		local _exp = UserInputService:GetMouseLocation()
		local _vector2 = Vector2.new(0, guiInset)
		local mouseLocation = _exp - _vector2
		local hoveringUnits = Selection:FindHoveringUnits()
		local boxSize = Selection.boxCornerPosition - mouseLocation
		local _boxCornerPosition = Selection.boxCornerPosition
		local _arg0 = boxSize / 2
		local middle = _boxCornerPosition - _arg0
		-- define if curently is box selecting or selecting single unit by just hovering
		Selection.selectionType = if boxSize.Magnitude > 3 and Selection.holding then SelectionMethod.Box else SelectionMethod.Single
		HUD.gui.SelectionBox.Visible = Selection.selectionType == SelectionMethod.Box and Selection.holding
		-- update selectionBox ui wether
		if Selection.selectionType == SelectionMethod.Box then
			Selection.selectionType = if boxSize.Magnitude > 3 then SelectionMethod.Box else SelectionMethod.Single
			Selection.boxSize = boxSize
			HUD.gui.SelectionBox.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)
			HUD.gui.SelectionBox.Position = UDim2.fromOffset(middle.X, middle.Y)
		end
		HUD.gui.SelectionBox.Visible = Selection.selectionType == SelectionMethod.Box
		-- unhover old units
		local _hoveringUnits = Selection.hoveringUnits
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
		Selection.hoveringUnits = hoveringUnits
	end
	function Selection:ClearSelectedUnits()
		for unit in Selection.selectedUnits do
			unit:Select(SelectionType.None)
		end
		table.clear(Selection.selectedUnits)
	end
	function Selection:SelectUnits(units)
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
			unit:Select(SelectionType.Selected)
			Selection.selectedUnits[unit] = true
		end
	end
	function Selection:DeselectUnits(units)
		local _units = units
		local _arg0 = function(unit)
			unit:Select(SelectionType.None)
			local _selectedUnits = Selection.selectedUnits
			local _unit = unit
			-- ▼ Set.delete ▼
			local _valueExisted = _selectedUnits[_unit] ~= nil
			_selectedUnits[_unit] = nil
			-- ▲ Set.delete ▲
			local unitIndex = _valueExisted
		end
		for _v in _units do
			_arg0(_v, _v, _units)
		end
	end
	Selection.selectionType = SelectionMethod.None
	Selection.boxCornerPosition = Vector2.new()
	Selection.boxSize = Vector2.new()
	Selection.hoveringUnits = {}
	Selection.selectedUnits = {}
end
return {
	SelectionMethod = SelectionMethod,
	default = Selection,
}
