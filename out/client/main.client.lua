-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local RunService = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").RunService
local Movement = TS.import(script, script.Parent, "Movement").default
local Admin = TS.import(script, script.Parent, "Admin").default
local Selection = TS.import(script, script.Parent, "Units", "Selection").default
local UnitsReceiver = TS.import(script, script.Parent, "Receivers", "UnitsReceiver").default
local UnitsAction = TS.import(script, script.Parent, "Units", "UnitsAction").default
local HUDHandler = TS.import(script, script.Parent, "Units", "HUDHandler").default
local unitsReceiver = UnitsReceiver:Get()
local movement = Movement:Get()
local selection = Selection:Get()
local admin = Admin:Get()
local unitsAction = UnitsAction:Get()
local hudHandler = HUDHandler:Get()
RunService.RenderStepped:Connect(function(deltaTime)
	movement:Update(deltaTime)
end)
