-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Receiver = TS.import(script, script.Parent, "Receiver").default
local TeamsStore = TS.import(script, script.Parent, "TeamsStore").default
local GameStore
do
	GameStore = setmetatable({}, {
		__tostring = function()
			return "GameStore"
		end,
	})
	GameStore.__index = GameStore
	function GameStore.new(...)
		local self = setmetatable({}, GameStore)
		return self:constructor(...) or self
	end
	function GameStore:constructor()
		self.stores = {}
		self.receiver = Receiver.new(self)
		if GameStore.instance then
			return nil
		end
		GameStore.instance = self
		self:AddStore(TeamsStore.new(self))
		self.receiver:FetchAll()
	end
	function GameStore:AddStore(store)
		local _stores = self.stores
		local _name = store.name
		local _store = store
		_stores[_name] = _store
	end
	function GameStore:GetStore(store)
		local _stores = self.stores
		local _store = store
		return _stores[_store]
	end
	function GameStore:Get()
		return GameStore.instance or GameStore.new()
	end
end
return {
	default = GameStore,
}
