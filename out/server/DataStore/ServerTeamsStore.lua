-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local TeamsStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "TeamStore").default
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local ServerReplicator = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "ServerReplicator").default
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
	function ServerTeamsStore:Add(teamData)
		super.Add(self, teamData)
		replicator:ReplicateAll("team-created", self:Serialize(teamData))
		return teamData
	end
	function ServerTeamsStore:Remove(teamId)
		super.Remove(self, teamId)
		local buffer = BitBuffer()
		buffer.writeString(teamId)
		replicator:ReplicateAll("team-removed", buffer)
	end
end
return {
	default = ServerTeamsStore,
}
