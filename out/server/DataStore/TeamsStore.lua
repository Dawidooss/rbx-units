-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local TeamsStoreBase = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "TeamStoreBase").default
local ServerReplicator = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "Replicator").default
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local bit = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "bit")
local replicator = ServerReplicator:Get()
local TeamsStore
do
	local super = TeamsStoreBase
	TeamsStore = setmetatable({}, {
		__tostring = function()
			return "TeamsStore"
		end,
		__index = super,
	})
	TeamsStore.__index = TeamsStore
	function TeamsStore.new(...)
		local self = setmetatable({}, TeamsStore)
		return self:constructor(...) or self
	end
	function TeamsStore:constructor(gameStore)
		super.constructor(self, gameStore)
	end
	function TeamsStore:Add(teamData, queue)
		super.Add(self, teamData)
		local queuePassed = not not queue
		local _condition = queue
		if not queue then
			_condition = ReplicationQueue.new()
		end
		queue = _condition
		queue:Add("team-created", function(buffer)
			return self:Serialize(teamData, buffer)
		end)
		if not queuePassed then
			replicator:ReplicateAll(queue)
		end
		return teamData
	end
	function TeamsStore:Remove(teamId, queue)
		super.Remove(self, teamId)
		local queuePassed = not not queue
		local _condition = queue
		if not queue then
			_condition = ReplicationQueue.new()
		end
		queue = _condition
		queue:Add("team-removed", function(buffer)
			buffer.writeBits(unpack(bit:ToBits(teamId, 4)))
			return buffer
		end)
		if not queuePassed then
			replicator:ReplicateAll(queue)
		end
	end
end
return {
	default = TeamsStore,
}
