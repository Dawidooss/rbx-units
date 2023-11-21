-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local TeamsStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "TeamStore").default
local ClientTeamsStore
do
	local super = TeamsStore
	ClientTeamsStore = setmetatable({}, {
		__tostring = function()
			return "ClientTeamsStore"
		end,
		__index = super,
	})
	ClientTeamsStore.__index = ClientTeamsStore
	function ClientTeamsStore.new(...)
		local self = setmetatable({}, ClientTeamsStore)
		return self:constructor(...) or self
	end
	function ClientTeamsStore:constructor(gameStore)
		super.constructor(self, gameStore)
		self.replicator = gameStore.replicator
		self.replicator:Connect("team-added", function(serializedTeamData)
			local teamData = TeamsStore:DeserializeTeamData(serializedTeamData)
			self:AddTeam(teamData)
		end)
	end
end
return {
	default = ClientTeamsStore,
}
