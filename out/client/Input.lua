-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ContextActionService = _services.ContextActionService
local UserInputService = _services.UserInputService
local Workspace = _services.Workspace
local UnitsManager = TS.import(script, script.Parent, "UnitsManager").default
local inset = TS.import(script, script.Parent, "GuiInset").default
local camera = Workspace.CurrentCamera
local Input
do
	Input = setmetatable({}, {
		__tostring = function()
			return "Input"
		end,
	})
	Input.__index = Input
	function Input.new(...)
		local self = setmetatable({}, Input)
		return self:constructor(...) or self
	end
	function Input:constructor()
	end
	function Input:Init()
		ContextActionService:BindAction("input", self.HandleInput, false, Enum.KeyCode.F, Enum.UserInputType.MouseButton1)
	end
	Input.HandleInput = function(action, state, input)
		local begin = state == Enum.UserInputState.Begin
		local _exp = UserInputService:GetMouseLocation()
		local _vector2 = Vector2.new(0, inset)
		local mousePosition = _exp - _vector2
		local rayData = camera:ScreenPointToRay(mousePosition.X, mousePosition.Y, 1)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { camera, UnitsManager.cache }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local mouseHit = Workspace:Raycast(rayData.Origin, rayData.Direction * 10000, raycastParams)
		if action == "input" then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.F and not begin then
					local _result = mouseHit
					if _result ~= nil then
						_result = _result.Position
					end
					if _result then
						UnitsManager:CreateUnit(UnitsManager:GenerateUnitId(), "Dummy", mouseHit.Position)
					end
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				local _result = mouseHit
				if _result ~= nil then
					_result = _result.Position
				end
				if _result then
					UnitsManager:SelectUnitsAt(mouseHit.Position, mouseHit.Position)
				end
			end
		end
	end
end
return {
	default = Input,
}
