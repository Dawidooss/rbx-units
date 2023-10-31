-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local RunService = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").RunService
local Movement = TS.import(script, script.Parent, "Movement").default
Movement:Init()
RunService.RenderStepped:Connect(function(deltaTime)
	Movement:Update(deltaTime)
end)
