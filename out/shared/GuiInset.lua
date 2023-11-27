-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players = _services.Players
local RunService = _services.RunService
local Workspace = _services.Workspace
local default = function()
	if RunService:IsClient() then
		local player = Players.LocalPlayer
		local playerGui = player:WaitForChild("PlayerGui")
		local camera = Workspace.CurrentCamera
		local screenGui = Instance.new("ScreenGui", playerGui)
		local frame = Instance.new("Frame", screenGui)
		frame.Size = UDim2.new(1, 0, 1, 0)
		local inset = camera.ViewportSize.Y - frame.AbsoluteSize.Y
		screenGui:Destroy()
		return inset
	else
		return 0
	end
end
return {
	default = default,
}
