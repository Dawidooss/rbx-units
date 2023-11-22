-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local GameStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "GameStore").default
local ClientReplicator = TS.import(script, script.Parent, "ClientReplicator").default
local ClientTeamsStore = TS.import(script, script.Parent, "ClientTeamsStore").default
local ClientPlayersStore = TS.import(script, script.Parent, "ClientPlayersStore").default
local ClientUnitsStore = TS.import(script, script.Parent, "ClientUnitsStore").default
local ClientGameStore
do
	local super = GameStore
	ClientGameStore = setmetatable({}, {
		__tostring = function()
			return "ClientGameStore"
		end,
		__index = super,
	})
	ClientGameStore.__index = ClientGameStore
	function ClientGameStore.new(...)
		local self = setmetatable({}, ClientGameStore)
		return self:constructor(...) or self
	end
	function ClientGameStore:constructor()
		super.constructor(self)
		self.replicator = ClientReplicator.new(self)
		if ClientGameStore.instance then
			return nil
		end
		ClientGameStore.instance = self
		self:AddStore(ClientTeamsStore.new(self))
		self:AddStore(ClientPlayersStore.new(self))
		self:AddStore(ClientUnitsStore.new(self))
		self.replicator:FetchAll()
	end
	function ClientGameStore:Get()
		return ClientGameStore.instance or ClientGameStore.new()
	end
end
return {
	default = ClientGameStore,
}
