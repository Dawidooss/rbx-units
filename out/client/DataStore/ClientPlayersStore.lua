-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local PlayersStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "PlayersStore").default
local ClientPlayersStore
do
	local super = PlayersStore
	ClientPlayersStore = setmetatable({}, {
		__tostring = function()
			return "ClientPlayersStore"
		end,
		__index = super,
	})
	ClientPlayersStore.__index = ClientPlayersStore
	function ClientPlayersStore.new(...)
		local self = setmetatable({}, ClientPlayersStore)
		return self:constructor(...) or self
	end
	function ClientPlayersStore:constructor(gameStore)
		super.constructor(self, gameStore)
		self.replicator = gameStore.replicator
		self.replicator:Connect("player-added", function(response)
			local serializedPlayerData = response.data
			local playerData = self:Deserialize(serializedPlayerData)
			self:AddPlayer(playerData)
		end)
		self.replicator:Connect("player-removed", function(response)
			local serializedPlayerId = response.data
			local playerId = serializedPlayerId
			self:RemovePlayer(playerId)
		end)
	end
end
return {
	default = ClientPlayersStore,
}
