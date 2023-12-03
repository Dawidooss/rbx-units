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
		self.replicationEnabled = false
		self.connections = {}
		Replicator.instance = self
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
					local _arg0 = self.connections[key]
					local _arg1 = "Connection " .. (key .. " missing in ClientReplicator")
					assert(_arg0, _arg1)
					self.connections[key](buffer)
				end)
			end,
		})
	end
	Replicator.Replicate = TS.async(function(self, queue)
		local promise = TS.Promise.new(function(resolve, reject)
			local response = Network:InvokeServer("chunked-data", queue:DumpString())[1]
			resolve(response)
		end)
		return promise
	end)
	function Replicator:Connect(key, callback)
		self.connections[key] = callback
	end
	Replicator.FetchAll = TS.async(function(self)
		local promise = TS.Promise.new(TS.async(function(resolve, reject)
			local queue = ReplicationQueue.new()
			queue:Add("fetch-all", function(buffer)
				return buffer
			end)
			local response = TS.await(self:Replicate(queue))
			local _condition = response.error
			if not _condition then
				local _value = response.data
				_condition = not (_value ~= "" and _value)
			end
			if _condition then
				-- CRASH GAME!?!? TODO:
				reject()
				return nil
			end
			local buffer = BitBuffer(response.data)
			resolve(buffer)
		end))
		return promise
	end)
	function Replicator:Get()
		return Replicator.instance or Replicator.new()
	end
end
return {
	default = Replicator,
}
