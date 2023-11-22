-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local TeamsStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "TeamStore").default
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
		self.replicator:Connect("team-added", function(response)
			local serializedTeamData = response.data
			local teamData = self:Deserialize(serializedTeamData)
			local _cache = self.cache
			local _id = teamData.id
			if _cache[_id] then
				return nil
			end
			self:AddTeam(teamData)
		end)
		self.replicator:Connect("team-removed", function(response)
			local serializedTeamId = response.data
			local teamId = serializedTeamId
			self:RemoveTeam(teamId)
		end)
	end
end
return {
	default = ClientTeamsStore,
}
