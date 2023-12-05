-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local GameStoreBase = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "GameStoreBase").default
local ServerReplicator = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "Replicator").default
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local replicator = ServerReplicator:Get()
local GameStore
do
	local super = GameStoreBase
	GameStore = setmetatable({}, {
		__tostring = function()
			return "GameStore"
		end,
		__index = super,
	})
	GameStore.__index = GameStore
	function GameStore.new(...)
		local self = setmetatable({}, GameStore)
		return self:constructor(...) or self
	end
	function GameStore:constructor()
		super.constructor(self)
		if GameStore.instance then
			return nil
		end
		GameStore.instance = self
		replicator:Connect("fetch-all", function(player, buffer)
			local responseBuffer = BitBuffer()
			for storeName, store in self.stores do
				responseBuffer.writeString(storeName)
				store:SerializeCache(responseBuffer)
			end
			responseBuffer.dumpString()
		end)
	end
	function GameStore:Get()
		return GameStore.instance or GameStore.new()
	end
end
return {
	default = GameStore,
}
