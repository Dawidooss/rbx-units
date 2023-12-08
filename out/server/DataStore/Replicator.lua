-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
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
	function Replicator:constructor()
		self.connections = {}
		Replicator.instance = self
		Network:BindFunctions({
			["chunked-data"] = function(player, ...)
				local queue = { ... }
				local response = ReplicationQueue.new()
				local replication = ReplicationQueue.new()
				for _, data in queue do
					local buffer = BitBuffer(data)
					local key = buffer.readString()
					self.connections[key][2](player, data, response, replication)
				end
				if #replication.queue > 0 then
					self:ReplicateExcept(player, replication)
				end
				return replication:Dump()
			end,
		})
	end
	function Replicator:Replicate(player, queue)
		Network:FireClient(player, "chunked-data", queue:Dump())
	end
	function Replicator:ReplicateExcept(player, queue)
		Network:FireOtherClients(player, "chunked-data", queue:Dump())
	end
	function Replicator:ReplicateAll(queue)
		Network:FireAllClients("chunked-data", queue:Dump())
	end
	function Replicator:Connect(key, deserializer, callback)
		-- TODO: add response to callbakc
		self.connections[key] = { deserializer, callback }
	end
	function Replicator:Get()
		return Replicator.instance or Replicator.new()
	end
end
return {
	default = Replicator,
}
