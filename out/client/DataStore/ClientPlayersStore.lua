-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local PlayersStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "PlayersStore").default
local ClientReplicator = TS.import(script, script.Parent, "ClientReplicator").default
local replicator = ClientReplicator:Get()
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
		replicator:Connect("player-added", function(buffer)
			local playerData = self:Deserialize(buffer)
			self:Add(playerData)
		end)
		replicator:Connect("player-removed", function(buffer)
			local playerId = buffer.readUInt32()
			self:Remove(tostring(playerId))
		end)
	end
end
return {
	default = ClientPlayersStore,
}
