-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ContextActionService = _services.ContextActionService
local ReplicatedFirst = _services.ReplicatedFirst
local RunService = _services.RunService
local Workspace = _services.Workspace
local Selection = TS.import(script, script.Parent, "Selection").default
local Utils = TS.import(script, script.Parent, "Utils").default
local _UnitsGroup = TS.import(script, script.Parent, "UnitsGroup")
local UnitsGroup = _UnitsGroup.default
local Formation = _UnitsGroup.Formation
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
	function UnitsRegroup:Regroup()
		UnitsGroup:Move(Selection.selectedUnits, UnitsRegroup.circle:GetPivot().Position, Formation.Normal, UnitsRegroup.rotation, UnitsRegroup.spread)
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
			UnitsRegroup:Regroup()
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
		local _fn = UnitsRegroup.circle
		local _cFrame = CFrame.new(UnitsRegroup.regroupPosition)
		local _arg0 = CFrame.Angles(0, 0, -math.pi / 2)
		_fn:PivotTo(_cFrame * _arg0)
		UnitsRegroup.circle.Parent = camera
		local _regroupPosition = UnitsRegroup.regroupPosition
		local arrowLength = (groundedMousePosition - _regroupPosition).Magnitude
		local fixedArrowLength = math.clamp(arrowLength, 4, 12)
		local _cFrame_1 = CFrame.new(UnitsRegroup.regroupPosition, groundedMousePosition)
		local _cFrame_2 = CFrame.new(0, 0, -fixedArrowLength / 2)
		local arrowMiddle = (_cFrame_1 * _cFrame_2).Position
		UnitsRegroup.arrow.Parent = if arrowLength < 3 then nil else UnitsRegroup.circle
		UnitsRegroup.arrow:PivotTo(CFrame.new(arrowMiddle, UnitsRegroup.regroupPosition))
		UnitsRegroup.arrow.Length.Size = Vector3.new(fixedArrowLength, UnitsRegroup.arrow.Length.Size.Y, UnitsRegroup.arrow.Length.Size.Z)
		UnitsRegroup.arrow.Length.Attachment.CFrame = CFrame.new(fixedArrowLength / 2, 0, 0)
		UnitsRegroup.arrow.Left:PivotTo(UnitsRegroup.arrow.Length.Attachment.WorldCFrame)
		UnitsRegroup.arrow.Right:PivotTo(UnitsRegroup.arrow.Length.Attachment.WorldCFrame)
		UnitsRegroup.rotation = (select(2, CFrame.new(UnitsRegroup.regroupPosition, groundedMousePosition):ToOrientation()))
		UnitsRegroup.spread = fixedArrowLength
		-- visualise positions
		local positions = UnitsGroup:GetPositionsInFormation(#Selection.selectedUnits, UnitsRegroup.circle:GetPivot().Position, Formation.Normal, UnitsRegroup.rotation, UnitsRegroup.spread)
		UnitsRegroup.circle.Positions:ClearAllChildren()
		local _arg0_1 = function(position, i)
			if i == 0 then
				return nil
			end
			local positionPart = UnitsRegroup.circle.Middle:Clone()
			local _fn_1 = positionPart
			local _cFrame_3 = CFrame.new(position)
			local _arg0_2 = CFrame.Angles(0, 0, math.pi / 2)
			_fn_1:PivotTo(_cFrame_3 * _arg0_2)
			positionPart.Parent = UnitsRegroup.circle.Positions
		end
		for _k, _v in positions do
			_arg0_1(_v, _k - 1, positions)
		end
	end
	UnitsRegroup.regroupPosition = Vector3.new()
	UnitsRegroup.enabled = false
	UnitsRegroup.rotation = 0
	UnitsRegroup.spread = 2
end
return {
	default = UnitsRegroup,
}
