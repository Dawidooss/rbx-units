-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local TeamsStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "TeamStore").default
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
		self.replicator:Connect("team-added", function(serializedTeamData)
			local teamData = TeamsStore:DeserializeTeamData(serializedTeamData)
			self:AddTeam(teamData)
		end)
	end
end
return {
	default = ServerTeamsStore,
}
