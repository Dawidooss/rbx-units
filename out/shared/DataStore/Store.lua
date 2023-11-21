-- Compiled with roblox-ts v2.2.0
local Store
do
	Store = {}
	function Store:constructor(gameStore)
		self.name = "Store"
		self.gameStore = gameStore
		self.replicator = gameStore.replicator
	end
end
return {
	default = Store,
}
