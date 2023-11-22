-- Compiled with roblox-ts v2.1.1
local Store
do
	Store = {}
	function Store:constructor(gameStore)
		self.name = "Store"
		self.cache = {}
		self.gameStore = gameStore
		self.replicator = gameStore.replicator
	end
	function Store:SerializeCache()
		local serializedCache = {}
		for _, data in self.cache do
			local _serializedCache = serializedCache
			local _arg0 = self:Serialize(data)
			table.insert(_serializedCache, _arg0)
		end
		return serializedCache
	end
end
return {
	default = Store,
}
