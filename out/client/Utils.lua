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
	Utils = {}
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
	function Utils:RaycastBottom(position, exclude)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		if exclude then
			raycastParams.FilterDescendantsInstances = exclude
		end
		local result = Workspace:Raycast(position, Vector3.new(0, -math.huge, 0), raycastParams)
		if not result then
			return nil
		end
		return result.Position
	end
end
return {
	default = Utils,
}
