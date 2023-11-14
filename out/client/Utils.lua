-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local UserInputService = _services.UserInputService
local Workspace = _services.Workspace
local guiInset = TS.import(script, script.Parent, "GuiInset").default
local camera = Workspace.CurrentCamera
local Utils
do
	Utils = {}
	function Utils:constructor()
	end
	function Utils:GetMouseHit(filterDescendantsInstances, filterType)
		local _exp = UserInputService:GetMouseLocation()
		local _vector2 = Vector2.new(0, guiInset)
		local mouseLocation = _exp - _vector2
		local rayData = camera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y, 1)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = filterType or Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances or { camera }
		local terrainHit = Workspace:Raycast(rayData.Origin, rayData.Direction * 10000, raycastParams)
		return terrainHit
	end
	function Utils:RaycastBottom(position, filterDescendantsInstances, filterType)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = filterType or Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances or { camera }
		local result = Workspace:Raycast(position, Vector3.new(0, -100000000, 0), raycastParams)
		return result
	end
end
return {
	default = Utils,
}
