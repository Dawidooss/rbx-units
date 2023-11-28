-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local TeamsStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "TeamStore").default
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local ClientReplicator = TS.import(script, script.Parent, "ClientReplicator").default
local replicator = ClientReplicator:Get()
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
		replicator:Connect("team-added", function(buffer)
			local teamData = self:Deserialize(buffer)
			local _cache = self.cache
			local _id = teamData.id
			if _cache[_id] then
				return nil
			end
			self:Add(teamData)
		end)
		replicator:Connect("team-removed", function(buffer)
			local teamId = buffer.readString()
			self:Remove(teamId)
		end)
	end
end
return {
	default = ClientTeamsStore,
}
