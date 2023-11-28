-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local PlayersStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "PlayersStore").default
local ServerReplicator = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "ServerReplicator").default
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
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
	function ServerPlayersStore:Add(playerData, queue)
		super.Add(self, playerData)
		local queuePassed = not not queue
		local _condition = queue
		if not queue then
			_condition = ReplicationQueue.new()
		end
		queue = _condition
		queue:Add("player-added", function(buffer)
			self:Serialize(playerData, buffer)
		end)
		if not queuePassed then
			replicator:ReplicateAll(queue)
		end
		return playerData
	end
	function ServerPlayersStore:Remove(playerId, queue)
		super.Remove(self, playerId)
		local queuePassed = not not queue
		local _condition = queue
		if not queue then
			_condition = ReplicationQueue.new()
		end
		queue = _condition
		queue:Add("player-added", function(buffer)
			local _fn = buffer
			local _condition_1 = tonumber(playerId)
			if not (_condition_1 ~= 0 and (_condition_1 == _condition_1 and _condition_1)) then
				_condition_1 = 0
			end
			_fn.writeUInt32(_condition_1)
		end)
		if not queuePassed then
			replicator:ReplicateAll(queue)
		end
	end
end
return {
	default = ServerPlayersStore,
}
