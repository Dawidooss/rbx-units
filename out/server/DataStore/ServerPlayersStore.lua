-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local PlayersStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "PlayersStore").default
local ServerPlayersStore
do
	local super = PlayersStore
	ServerPlayersStore = setmetatable({}, {
		__tostring = function()
			return "ServerPlayersStore"
		end,
		__index = super,
	})
	ServerPlayersStore.__index = ServerPlayersStore
	function ServerPlayersStore.new(...)
		local self = setmetatable({}, ServerPlayersStore)
		return self:constructor(...) or self
	end
	function ServerPlayersStore:constructor(gameStore)
		super.constructor(self, gameStore)
		self.replicator = gameStore.replicator
	end
	function ServerPlayersStore:AddPlayer(playerData)
		super.AddPlayer(self, playerData)
		self.replicator:ReplicateAll("player-added", self:Serialize(playerData))
		return playerData
	end
	function ServerPlayersStore:RemovePlayer(playerId)
		super.RemovePlayer(self, playerId)
		self.replicator:ReplicateAll("player-removed", playerId)
	end
end
return {
	default = ServerPlayersStore,
}
