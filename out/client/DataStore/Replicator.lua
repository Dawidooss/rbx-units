-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
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
		self.replicationEnabled = false
		self.connections = {}
		Replicator.instance = self
		Network:BindEvents({
			["chunked-data"] = function(...)
				local queue = { ... }
				return function()
					if not self.replicationEnabled then
						return nil
					end
					for _, data in queue do
						local buffer = BitBuffer(data)
						local key = buffer.readString()
						self.connections[key][2](data)
					end
				end
			end,
		})
	end
	Replicator.ChunkedDataReceived = TS.async(function(self, data) end)
	Replicator.Replicate = TS.async(function(self, queue)
		local response = Network:InvokeServer("chunked-data", queue:Dump())
		-- TODO: handle response
	end)
	function Replicator:Connect(key, deserializer, callback)
		self.connections[key] = { deserializer, callback }
	end
	function Replicator:Get()
		return Replicator.instance or Replicator.new()
	end
end
return {
	default = Replicator,
}
