-- Compiled with roblox-ts v2.1.1
local GameStoreBase
do
	GameStoreBase = {}
	function GameStoreBase:constructor()
		self.stores = {}
	end
	function GameStoreBase:AddStore(store)
		local _stores = self.stores
		local _name = store.name
		local _store = store
		_stores[_name] = _store
	end
	function GameStoreBase:GetStore(store)
		local _stores = self.stores
		local _store = store
		return _stores[_store]
	end
end
return {
	default = GameStoreBase,
}
