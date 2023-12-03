-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
wait(2)
local Players = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players
local GameStore = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "GameStore").default
local PlayersStore = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "PlayersStore").default
local TeamsStore = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "TeamsStore").default
local UnitsStore = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "UnitsStore").default
local UnitData = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "UnitsStoreBase").UnitData
local gameStore = GameStore:Get()
gameStore:AddStore(TeamsStore.new(gameStore))
gameStore:AddStore(PlayersStore.new(gameStore))
gameStore:AddStore(UnitsStore.new(gameStore))
local teamsStore = gameStore:GetStore("TeamsStore")
local playersStore = gameStore:GetStore("PlayersStore")
local unitsStore = gameStore:GetStore("UnitsStore")
local redTeam = teamsStore:Add({
	name = "Red",
	id = 0,
	color = Color3.new(1, 0, 0),
})
local unitId = table.remove(unitsStore.freeIds, 1)
if unitId ~= 0 and (unitId == unitId and unitId) then
	unitsStore:Add(UnitData.new(unitId, "Dummy", Vector3.new(-31, 0.5, -57), 15, {}))
end
Players.PlayerAdded:Connect(function(player)
	playersStore:Add({
		id = player.UserId,
		player = player,
		teamId = 0,
	})
	player.CharacterAdded:Connect(function(character)
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local humanoid = character:WaitForChild("Humanoid")
		humanoidRootPart.Anchored = true
		humanoid.WalkSpeed = 0
	end)
end)
