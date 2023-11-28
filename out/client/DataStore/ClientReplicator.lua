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
		self.replicationEnabled = false
		self.connections = {}
		ClientReplicator.instance = self
		Network:BindEvents({
			["chunked-data"] = function(response)
				if not self.replicationEnabled then
					return nil
				end
				local data = response.data
				if not (data ~= "" and data) then
					return nil
				end
				ReplicationQueue:Divide(data, function(key, buffer)
					print(key)
					local _arg0 = self.connections[key]
					local _arg1 = "Connection " .. (key .. " missing in ClientReplicator")
					assert(_arg0, _arg1)
					self.connections[key](buffer)
				end)
			end,
		})
	end
	ClientReplicator.Replicate = TS.async(function(self, queue)
		local promise = TS.Promise.new(function(resolve, reject)
			local response = Network:InvokeServer("chunked-data", queue:DumpString())[1]
			print(response)
			resolve(response)
		end)
		return promise
	end)
	function ClientReplicator:Connect(key, callback)
		self.connections[key] = callback
	end
	ClientReplicator.FetchAll = TS.async(function(self)
		local promise = TS.Promise.new(TS.async(function(resolve, reject)
			local queue = ReplicationQueue.new()
			queue:Add("fetch-all")
			local response = TS.await(self:Replicate(queue))
			local _condition = response.error
			if not _condition then
				local _value = response.data
				_condition = not (_value ~= "" and _value)
			end
			if _condition then
				-- CRASH GAME!?!? TODO
				reject()
				return nil
			end
			local buffer = BitBuffer(response.data)
			resolve(buffer)
		end))
		return promise
	end)
	function ClientReplicator:Get()
		return ClientReplicator.instance or ClientReplicator.new()
	end
end
return {
	default = ClientReplicator,
}
