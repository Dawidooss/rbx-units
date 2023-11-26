-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local HttpService = _services.HttpService
local Players = _services.Players
local ServerGameStore = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "ServerGameStore").default
local gameStore = ServerGameStore:Get()
local teamsStore = gameStore:GetStore("TeamsStore")
local playersStore = gameStore:GetStore("PlayersStore")
local redTeamId = HttpService:GenerateGUID(false)
local redTeam = teamsStore:Add({
	name = "Red",
	id = redTeamId,
	color = Color3.new(1, 0, 0),
})
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
