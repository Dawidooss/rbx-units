-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ClientReplicator = TS.import(script, script.Parent, "Replicator").default
local PlayersStoreBase = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "PlayersStoreBase").default
local replicator = ClientReplicator:Get()
local PlayersStore
do
	local super = PlayersStoreBase
	PlayersStore = setmetatable({}, {
		__tostring = function()
			return "PlayersStore"
		end,
		__index = super,
	})
	PlayersStore.__index = PlayersStore
	function PlayersStore.new(...)
		local self = setmetatable({}, PlayersStore)
		return self:constructor(...) or self
	end
	function PlayersStore:constructor(gameStore)
		super.constructor(self, gameStore)
		replicator:Connect("player-added", function(buffer)
			local playerData = self:Deserialize(buffer)
			self:Add(playerData)
		end)
		replicator:Connect("player-removed", function(buffer)
			local playerId = buffer.readString()
			self:Remove(playerId)
		end)
	end
end
return {
	default = PlayersStore,
}
