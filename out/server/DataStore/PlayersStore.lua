-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local PlayersStoreBase = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "PlayersStoreBase").default
local ServerReplicator = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "Replicator").default
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local replicator = ServerReplicator:Get()
local PlayersStore
do
	local super = PlayersStoreBase
	PlayersStore = setmetatable({}, {
		__tostring = function()
			return "PlayersStore"
		end,
		__index = super,
	})
	PlayersStore.__index = PlayersStore
	function PlayersStore.new(...)
		local self = setmetatable({}, PlayersStore)
		return self:constructor(...) or self
	end
	function PlayersStore:constructor()
		super.constructor(self)
		PlayersStore.instance = self
	end
	function PlayersStore:Add(playerData, queue)
		super.Add(self, playerData)
		local queuePassed = not not queue
		local _condition = queue
		if not queue then
			_condition = ReplicationQueue.new()
		end
		queue = _condition
		queue:Add("player-added", function(buffer)
			return self.serializer.Ser(playerData, buffer)
		end)
		if not queuePassed then
			replicator:ReplicateAll(queue)
		end
		return playerData
	end
	function PlayersStore:Remove(playerId, queue)
		super.Remove(self, playerId)
		local queuePassed = not not queue
		local _condition = queue
		if not queue then
			_condition = ReplicationQueue.new()
		end
		queue = _condition
		queue:Add("player-removed", function(buffer)
			buffer.writeString(tostring(playerId))
			return buffer
		end)
		if not queuePassed then
			replicator:ReplicateAll(queue)
		end
	end
	function PlayersStore:Get()
		return PlayersStore.instance or PlayersStore.new()
	end
end
return {
	default = PlayersStore,
}
