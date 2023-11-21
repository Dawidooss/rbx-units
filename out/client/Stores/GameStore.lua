-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local GameStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "GameStore").default
local Replicator = TS.import(script, script.Parent, "Replicator").default
local ClientTeamsStore = TS.import(script, script.Parent, "ClientTeamsStore").default
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
		self.replicator = Replicator.new(self)
		if ClientGameStore.instance then
			return nil
		end
		ClientGameStore.instance = self
		self:AddStore(ClientTeamsStore.new(self))
		self.replicator:FetchAll()
	end
	function ClientGameStore:Get()
		return ClientGameStore.instance or ClientGameStore.new()
	end
end
return {
	default = ClientGameStore,
}
