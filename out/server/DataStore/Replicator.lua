-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
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
			["chunked-data"] = function(player, data)
				local responseQueue = ReplicationQueue.new()
				local replicationQueue = ReplicationQueue.new()
				ReplicationQueue:Divide(data, function(key, buffer)
					local _arg0 = self.connections[key]
					local _arg1 = "Connection " .. (key .. " missing in ServerReplicator")
					assert(_arg0, _arg1)
					self.connections[key](player, buffer, responseQueue, replicationQueue)
				end)
				if replicationQueue:DumpString() ~= "" then
					-- is not empty
					self:ReplicateExcept(player, replicationQueue)
				end
				return { responseQueue:DumpString() }
			end,
		})
	end
	function Replicator:Replicate(player, queue)
		Network:FireClient(player, "chunked-data", queue:DumpString())
	end
	function Replicator:ReplicateExcept(player, queue)
		Network:FireOtherClients(player, "chunked-data", queue:DumpString())
	end
	function Replicator:ReplicateAll(queue)
		Network:FireAllClients("chunked-data", queue:DumpString())
	end
	function Replicator:Connect(key, callback)
		self.connections[key] = callback
	end
	function Replicator:Get()
		return Replicator.instance or Replicator.new()
	end
end
return {
	default = Replicator,
}
