-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local UserInputService = _services.UserInputService
local Workspace = _services.Workspace
local guiInset = TS.import(script, script.Parent, "GuiInset").default
local UnitsManager = TS.import(script, script.Parent, "Units", "UnitsManager").default
local camera = Workspace.CurrentCamera
local Utils
do
	Utils = setmetatable({}, {
		__tostring = function()
			return "Utils"
		end,
	})
	Utils.__index = Utils
	function Utils.new(...)
		local self = setmetatable({}, Utils)
		return self:constructor(...) or self
	end
	function Utils:constructor()
	end
	function Utils:GetMouseHit()
		local _exp = UserInputService:GetMouseLocation()
		local _vector2 = Vector2.new(0, guiInset)
		local mouseLocation = _exp - _vector2
		local rayData = camera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y, 1)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { camera, UnitsManager.cache }
		local terrainHit = Workspace:Raycast(rayData.Origin, rayData.Direction * 10000, raycastParams)
		return terrainHit
	end
	function Utils:FixCFrame(cframe)
		local c = { cframe:GetComponents() }
		local _condition = c[1]
		if not (_condition ~= 0 and (_condition == _condition and _condition)) then
			_condition = 0
		end
		local _condition_1 = c[2]
		if not (_condition_1 ~= 0 and (_condition_1 == _condition_1 and _condition_1)) then
			_condition_1 = 0
		end
		local _condition_2 = c[3]
		if not (_condition_2 ~= 0 and (_condition_2 == _condition_2 and _condition_2)) then
			_condition_2 = 0
		end
		local _condition_3 = c[4]
		if not (_condition_3 ~= 0 and (_condition_3 == _condition_3 and _condition_3)) then
			_condition_3 = 0
		end
		local _condition_4 = c[5]
		if not (_condition_4 ~= 0 and (_condition_4 == _condition_4 and _condition_4)) then
			_condition_4 = 0
		end
		local _condition_5 = c[6]
		if not (_condition_5 ~= 0 and (_condition_5 == _condition_5 and _condition_5)) then
			_condition_5 = 0
		end
		local _condition_6 = c[7]
		if not (_condition_6 ~= 0 and (_condition_6 == _condition_6 and _condition_6)) then
			_condition_6 = 0
		end
		local _condition_7 = c[8]
		if not (_condition_7 ~= 0 and (_condition_7 == _condition_7 and _condition_7)) then
			_condition_7 = 0
		end
		local _condition_8 = c[9]
		if not (_condition_8 ~= 0 and (_condition_8 == _condition_8 and _condition_8)) then
			_condition_8 = 0
		end
		local _condition_9 = c[10]
		if not (_condition_9 ~= 0 and (_condition_9 == _condition_9 and _condition_9)) then
			_condition_9 = 0
		end
		local _condition_10 = c[11]
		if not (_condition_10 ~= 0 and (_condition_10 == _condition_10 and _condition_10)) then
			_condition_10 = 0
		end
		local _condition_11 = c[12]
		if not (_condition_11 ~= 0 and (_condition_11 == _condition_11 and _condition_11)) then
			_condition_11 = 0
		end
		return CFrame.new(_condition, _condition_1, _condition_2, _condition_3, _condition_4, _condition_5, _condition_6, _condition_7, _condition_8, _condition_9, _condition_10, _condition_11)
	end
end
return {
	default = Utils,
}
