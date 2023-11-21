-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local GameStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "GameStore").default
local Replicator = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "Replicator").default
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
		self.replicator = Replicator.new(self)
		if ServerGameStore.instance then
			return nil
		end
		ServerGameStore.instance = self
	end
	function ServerGameStore:Get()
		return ServerGameStore.instance or ServerGameStore.new()
	end
end
return {
	default = ServerGameStore,
}
