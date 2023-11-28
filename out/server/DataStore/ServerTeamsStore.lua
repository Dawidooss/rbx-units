-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local TeamsStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "TeamStoreBase").default
local ServerReplicator = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "ServerReplicator").default
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local replicator = ServerReplicator:Get()
local ServerTeamsStore
do
	local super = TeamsStore
	ServerTeamsStore = setmetatable({}, {
		__tostring = function()
			return "ServerTeamsStore"
		end,
		__index = super,
	})
	ServerTeamsStore.__index = ServerTeamsStore
	function ServerTeamsStore.new(...)
		local self = setmetatable({}, ServerTeamsStore)
		return self:constructor(...) or self
	end
	function ServerTeamsStore:constructor(gameStore)
		super.constructor(self, gameStore)
	end
	function ServerTeamsStore:Add(teamData, queue)
		super.Add(self, teamData)
		local queuePassed = not not queue
		local _condition = queue
		if not queue then
			_condition = ReplicationQueue.new()
		end
		queue = _condition
		queue:Add("team-created", function(buffer)
			self:Serialize(teamData, buffer)
		end)
		if not queuePassed then
			replicator:ReplicateAll(queue)
		end
		return teamData
	end
	function ServerTeamsStore:Remove(teamId, queue)
		super.Remove(self, teamId)
		local queuePassed = not not queue
		local _condition = queue
		if not queue then
			_condition = ReplicationQueue.new()
		end
		queue = _condition
		queue:Add("team-created", function(buffer)
			buffer.writeString(teamId)
		end)
		if not queuePassed then
			replicator:ReplicateAll(queue)
		end
	end
end
return {
	default = ServerTeamsStore,
}
