-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
local Replicator
do
	Replicator = setmetatable({}, {
		__tostring = function()
			return "Replicator"
		end,
	})
	Replicator.__index = Replicator
	function Replicator.new(...)
		local self = setmetatable({}, Replicator)
		return self:constructor(...) or self
	end
	function Replicator:constructor(gameStore)
		self.gameStore = gameStore
	end
	function Replicator:Replicate(player, key, serializedData)
		Network:FireClient(player, key, serializedData)
	end
	function Replicator:ReplicateAll(key, serializedData)
		Network:FireAllClients(key, serializedData)
	end
	function Replicator:Connect(key, callback)
		Network:BindFunctions({
			[key] = callback,
		})
	end
end
return {
	default = Replicator,
}
