-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local UserInputService = _services.UserInputService
local Workspace = _services.Workspace
local guiInset = TS.import(script, script.Parent, "GuiInset").default
local UnitsManager = TS.import(script, script.Parent, "UnitsManager").default
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
end
return {
	default = Utils,
}
