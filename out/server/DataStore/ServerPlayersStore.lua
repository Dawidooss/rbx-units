-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local PlayersStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "PlayersStore").default
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local ServerReplicator = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "ServerReplicator").default
local replicator = ServerReplicator:Get()
local ServerPlayersStore
do
	local super = PlayersStore
	ServerPlayersStore = setmetatable({}, {
		__tostring = function()
			return "ServerPlayersStore"
		end,
		__index = super,
	})
	ServerPlayersStore.__index = ServerPlayersStore
	function ServerPlayersStore.new(...)
		local self = setmetatable({}, ServerPlayersStore)
		return self:constructor(...) or self
	end
	function ServerPlayersStore:constructor(gameStore)
		super.constructor(self, gameStore)
	end
	function ServerPlayersStore:Add(playerData)
		super.Add(self, playerData)
		replicator:ReplicateAll("player-added", self:Serialize(playerData))
		return playerData
	end
	function ServerPlayersStore:Remove(playerId)
		super.Remove(self, playerId)
		local buffer = BitBuffer()
		local _fn = buffer
		local _condition = tonumber(playerId)
		if not (_condition ~= 0 and (_condition == _condition and _condition)) then
			_condition = 0
		end
		_fn.writeUInt32(_condition)
		replicator:ReplicateAll("player-removed", buffer)
	end
end
return {
	default = ServerPlayersStore,
}
