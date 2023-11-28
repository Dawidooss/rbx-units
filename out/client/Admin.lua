-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local HttpService = _services.HttpService
local Players = _services.Players
local Input = TS.import(script, script.Parent, "Input").default
local Utils = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Utils").default
local ClientGameStore = TS.import(script, script.Parent, "DataStore", "ClientGameStore").default
local Unit = TS.import(script, script.Parent, "Units", "Unit").default
local ClientReplicator = TS.import(script, script.Parent, "DataStore", "ClientReplicator").default
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local player = Players.LocalPlayer
local gameStore = ClientGameStore:Get()
local unitsStore = gameStore:GetStore("UnitsStore")
local replicator = ClientReplicator:Get()
local Admin
do
	Admin = {}
	function Admin:constructor()
	end
	function Admin:Init()
		Input:Bind(Enum.KeyCode.F, Enum.UserInputState.End, function()
			return self:SpawnUnit()
		end)
	end
	function Admin:SpawnUnit()
		local mouseHitResult = Utils:GetMouseHit({ unitsStore.folder })
		local _result = mouseHitResult
		if _result ~= nil then
			_result = _result.Position
		end
		if _result then
			local unitData = {
				id = HttpService:GenerateGUID(false),
				type = "Dummy",
				position = mouseHitResult.Position,
				playerId = player.UserId,
				path = {},
			}
			local clientUnitData = unitData
			clientUnitData.instance = Unit.new(unitData)
			unitsStore:Add(clientUnitData)
			local queue = ReplicationQueue.new()
			queue:Add("create-unit", function(buffer)
				unitsStore:Serialize(unitData, buffer)
			end)
			print("a")
			replicator:Replicate(queue)
			print("b")
		end
	end
end
return {
	default = Admin,
}
