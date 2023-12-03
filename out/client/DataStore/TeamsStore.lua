-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local Replicator = TS.import(script, script.Parent, "Replicator").default
local TeamsStoreBase = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "TeamStoreBase").default
local bit = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "bit")
local replicator = Replicator:Get()
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
			local teamId = bit:FromBits(buffer.readBits(4))
			self:Remove(teamId)
		end)
	end
end
return {
	default = TeamsStore,
}
