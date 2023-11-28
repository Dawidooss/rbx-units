-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local ClientReplicator
do
	ClientReplicator = setmetatable({}, {
		__tostring = function()
			return "ClientReplicator"
		end,
	})
	ClientReplicator.__index = ClientReplicator
	function ClientReplicator.new(...)
		local self = setmetatable({}, ClientReplicator)
		return self:constructor(...) or self
	end
	function ClientReplicator:constructor()
		self.connections = {}
		ClientReplicator.instance = self
		Network:BindEvents({
			["chunked-data"] = function(response)
				local data = response.data
				if not (data ~= "" and data) then
					return nil
				end
				ReplicationQueue:Divide(data, function(key, buffer)
					local _arg0 = self.connections[key]
					local _arg1 = "Connection " .. (key .. " missing in ClientReplicator")
					assert(_arg0, _arg1)
					self.connections[key](buffer)
				end)
			end,
		})
	end
	ClientReplicator.Replicate = TS.async(function(self, key, queue)
		local promise = TS.Promise.new(function(resolve, reject)
			local response = Network:InvokeServer(key, queue:DumpString())
			resolve(response)
		end)
		return promise
	end)
	function ClientReplicator:Connect(key, callback)
		self.connections[key] = callback
	end
	function ClientReplicator:FetchAll()
		local response = Network:InvokeServer("fetch-all")[1]
		if not response then
			return nil
		end
		local bufferStringified = response.data
		if response.error or not (bufferStringified ~= "" and bufferStringified) then
			-- TODO notify error
			return nil
		end
		local buffer = BitBuffer(bufferStringified)
		return buffer
	end
	function ClientReplicator:Get()
		return ClientReplicator.instance or ClientReplicator.new()
	end
end
return {
	default = ClientReplicator,
}
