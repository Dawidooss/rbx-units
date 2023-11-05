-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local RunService = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").RunService
local Movement = TS.import(script, script.Parent, "Movement").default
local UnitsManager = TS.import(script, script.Parent, "Units", "UnitsManager").default
local Input = TS.import(script, script.Parent, "Input").default
local Selection = TS.import(script, script.Parent, "Units", "Selection").default
local Admin = TS.import(script, script.Parent, "Admin").default
local UnitsAction = TS.import(script, script.Parent, "Units", "UnitsAction").default
Selection:Init()
UnitsManager:Init()
Movement:Init()
Input:Init()
Admin:Init()
UnitsAction:Init()
RunService.RenderStepped:Connect(function(deltaTime)
	Movement:Update(deltaTime)
end)
