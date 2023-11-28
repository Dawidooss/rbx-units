-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local GameStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "GameStoreBase").default
local _ServerReplicator = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "ServerReplicator")
local ServerReplicator = _ServerReplicator.default
local ServerResponseBuilder = _ServerReplicator.ServerResponseBuilder
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local replicator = ServerReplicator:Get()
local ServerGameStore
do
	local super = GameStore
	ServerGameStore = setmetatable({}, {
		__tostring = function()
			return "ServerGameStore"
		end,
		__index = super,
	})
	ServerGameStore.__index = ServerGameStore
	function ServerGameStore.new(...)
		local self = setmetatable({}, ServerGameStore)
		return self:constructor(...) or self
	end
	function ServerGameStore:constructor()
		super.constructor(self)
		if ServerGameStore.instance then
			return nil
		end
		ServerGameStore.instance = self
		replicator:Connect("fetch-all", function(player, buffer)
			local responseBuffer = BitBuffer()
			for storeName, store in self.stores do
				responseBuffer.writeString(storeName)
				store:SerializeCache(responseBuffer)
			end
			return ServerResponseBuilder.new():SetData(responseBuffer.dumpString()):Build()
		end)
	end
	function ServerGameStore:Get()
		return ServerGameStore.instance or ServerGameStore.new()
	end
end
return {
	default = ServerGameStore,
}
