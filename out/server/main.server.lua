-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
wait(2)
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local HttpService = _services.HttpService
local Players = _services.Players
local ServerGameStore = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "ServerGameStore").default
local ServerPlayersStore = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "ServerPlayersStore").default
local ServerTeamsStore = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "ServerTeamsStore").default
local ServerUnitsStore = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "ServerUnitsStore").default
local UnitData = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "UnitsStoreBase").UnitData
local gameStore = ServerGameStore:Get()
gameStore:AddStore(ServerTeamsStore.new(gameStore))
gameStore:AddStore(ServerPlayersStore.new(gameStore))
gameStore:AddStore(ServerUnitsStore.new(gameStore))
local teamsStore = gameStore:GetStore("TeamsStore")
local playersStore = gameStore:GetStore("PlayersStore")
local unitsStore = gameStore:GetStore("UnitsStore")
local redTeamId = HttpService:GenerateGUID(false)
local redTeam = teamsStore:Add({
	name = "Red",
	id = redTeamId,
	color = Color3.new(1, 0, 0),
})
unitsStore:Add(UnitData.new(HttpService:GenerateGUID(false), "Dummy", Vector3.new(-31, 0.5, -57), 15, {}))
Players.PlayerAdded:Connect(function(player)
	playersStore:Add({
		player = player,
		teamId = redTeamId,
	})
	player.CharacterAdded:Connect(function(character)
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local humanoid = character:WaitForChild("Humanoid")
		humanoidRootPart.Anchored = true
		humanoid.WalkSpeed = 0
	end)
end)
