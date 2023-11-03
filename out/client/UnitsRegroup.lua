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
		UnitsRegroup.arrow = ReplicatedFirst:WaitForChild("MovementArrow"):Clone()
		-- handle if LMB pressed and relesed
		ContextActionService:BindAction("unitsActions", function(actionName, state, input)
			return UnitsRegroup:Enable(state == Enum.UserInputState.Begin)
		end, false, Enum.UserInputType.MouseButton2)
	end
	function UnitsRegroup:Regroup()
		print(UnitsRegroup.arrow:GetPivot().Position)
		UnitsGroup:Move(Selection.selectedUnits, UnitsRegroup.arrow:GetPivot().Position, Formation.Normal)
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
			UnitsRegroup.arrow.Parent = nil
		end
	end
	function UnitsRegroup:Update()
		local mouseHitResult = Utils:GetMouseHit()
		if not mouseHitResult then
			return nil
		end
		local groundedMousePosition = Vector3.new(mouseHitResult.Position.X, UnitsRegroup.regroupPosition.Y, mouseHitResult.Position.Z)
		local _fn = UnitsRegroup.arrow
		local _cFrame = CFrame.new(UnitsRegroup.regroupPosition)
		local _arg0 = CFrame.Angles(0, 0, -math.pi / 2)
		_fn:PivotTo(_cFrame * _arg0)
		UnitsRegroup.arrow.Parent = camera
		local _fn_1 = math
		local _regroupPosition = UnitsRegroup.regroupPosition
		local arrowLength = _fn_1.clamp((groundedMousePosition - _regroupPosition).Magnitude, 0.5, 8)
		local _cFrame_1 = CFrame.new(UnitsRegroup.regroupPosition, groundedMousePosition)
		local _cFrame_2 = CFrame.new(0, 0, -arrowLength / 2)
		local arrowMiddle = (_cFrame_1 * _cFrame_2).Position
		UnitsRegroup.arrow.Arrow:PivotTo(CFrame.new(arrowMiddle, UnitsRegroup.regroupPosition))
		UnitsRegroup.arrow.Arrow.Length.Size = Vector3.new(arrowLength, UnitsRegroup.arrow.Arrow.Length.Size.Y, UnitsRegroup.arrow.Arrow.Length.Size.Z)
		UnitsRegroup.arrow.Arrow.Length.Attachment.CFrame = CFrame.new(arrowLength / 2, 0, 0)
		UnitsRegroup.arrow.Arrow.Left:PivotTo(UnitsRegroup.arrow.Arrow.Length.Attachment.WorldCFrame)
		UnitsRegroup.arrow.Arrow.Right:PivotTo(UnitsRegroup.arrow.Arrow.Length.Attachment.WorldCFrame)
	end
	UnitsRegroup.regroupPosition = Vector3.new()
	UnitsRegroup.enabled = false
end
return {
	default = UnitsRegroup,
}
