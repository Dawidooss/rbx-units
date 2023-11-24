-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players = _services.Players
local Workspace = _services.Workspace
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera
local HUD
do
	HUD = setmetatable({}, {
		__tostring = function()
			return "HUD"
		end,
	})
	HUD.__index = HUD
	function HUD.new(...)
		local self = setmetatable({}, HUD)
		return self:constructor(...) or self
	end
	function HUD:constructor()
		HUD.instance = self
		self.gui = playerGui:WaitForChild("HUD")
	end
	function HUD:Get()
		return HUD.instance or HUD.new()
	end
end
return {
	default = HUD,
}
