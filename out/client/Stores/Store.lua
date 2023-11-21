-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Signal = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "signal")
local Store
do
	Store = {}
	function Store:constructor(gameStore)
		self.name = "Store"
		self.replicable = true
		self.gameStore = gameStore
		self.receiver = gameStore.receiver
		self.dataChanged = Signal.new()
	end
	function Store:SetReplicable(replicable)
		self.replicable = replicable
	end
	function Store:DataMissmatch()
		self.receiver:FetchAll()
	end
end
return {
	default = Store,
}
