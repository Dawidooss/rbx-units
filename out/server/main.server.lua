-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
wait(2)
local Players = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players
local PlayersStore = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "PlayersStore").default
local TeamsStore = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "TeamsStore").default
local UnitsStore = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "UnitsStore").default
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
Network:BindFunctions({})
local teamsStore = TeamsStore:Get()
local playersStore = PlayersStore:Get()
local unitsStore = UnitsStore:Get()
teamsStore:Add({
	name = "Red",
	id = 0,
	color = Color3.new(1, 0, 0),
})
Players.PlayerAdded:Connect(function(player)
	playersStore:Add({
		id = player.UserId,
		teamId = 0,
	})
	player.CharacterAdded:Connect(function(character)
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local humanoid = character:WaitForChild("Humanoid")
		humanoidRootPart.Anchored = true
		humanoid.WalkSpeed = 0
	end)
end)
