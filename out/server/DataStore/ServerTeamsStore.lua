-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local TeamsStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "TeamStore").default
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
		self.replicator = gameStore.replicator
	end
	function ServerTeamsStore:AddTeam(teamData)
		super.AddTeam(self, teamData)
		self.replicator:ReplicateAll("team-created", self:Serialize(teamData))
		return teamData
	end
	function ServerTeamsStore:RemoveTeam(teamId)
		super.RemoveTeam(self, teamId)
		self.replicator:ReplicateAll("team-removed", teamId)
	end
end
return {
	default = ServerTeamsStore,
}
