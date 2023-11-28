-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local ServerResponseBuilder
local ServerReplicator
do
	ServerReplicator = setmetatable({}, {
		__tostring = function()
			return "ServerReplicator"
		end,
	})
	ServerReplicator.__index = ServerReplicator
	function ServerReplicator.new(...)
		local self = setmetatable({}, ServerReplicator)
		return self:constructor(...) or self
	end
	function ServerReplicator:constructor()
		self.connections = {}
		ServerReplicator.instance = self
		Network:BindFunctions({
			["chunked-data"] = function(player, data)
				print(data)
				ReplicationQueue:Divide(data, function(key, buffer)
					local _arg0 = self.connections[key]
					local _arg1 = "Connection " .. (key .. " missing in ServerReplicator")
					assert(_arg0, _arg1)
					return { self.connections[key](player, buffer) }
				end)
			end,
		})
	end
	function ServerReplicator:Replicate(player, queue)
		local response = ServerResponseBuilder.new():SetData(queue:DumpString()):Build()
		Network:FireClient(player, "chunked-data", response)
	end
	function ServerReplicator:ReplicateExcept(player, queue)
		local response = ServerResponseBuilder.new():SetData(queue:DumpString()):Build()
		Network:FireOtherClients(player, "chunked-data", response)
	end
	function ServerReplicator:ReplicateAll(queue)
		local response = ServerResponseBuilder.new():SetData(queue:DumpString()):Build()
		Network:FireAllClients("chunked-data", response)
	end
	function ServerReplicator:Connect(key, callback)
		self.connections[key] = callback
	end
	function ServerReplicator:Get()
		return ServerReplicator.instance or ServerReplicator.new()
	end
end
do
	ServerResponseBuilder = setmetatable({}, {
		__tostring = function()
			return "ServerResponseBuilder"
		end,
	})
	ServerResponseBuilder.__index = ServerResponseBuilder
	function ServerResponseBuilder.new(...)
		local self = setmetatable({}, ServerResponseBuilder)
		return self:constructor(...) or self
	end
	function ServerResponseBuilder:constructor()
		self.status = ""
		self.error = false
	end
	function ServerResponseBuilder:SetError(errorMessage)
		self.error = true
		self.errorMessage = errorMessage
		return self
	end
	function ServerResponseBuilder:SetStatus(status)
		self.status = status
		return self
	end
	function ServerResponseBuilder:SetData(data)
		self.data = data
		return self
	end
	function ServerResponseBuilder:Build()
		return {
			status = self.status,
			error = self.error,
			errorMessage = self.errorMessage,
			data = self.data,
		}
	end
end
return {
	default = ServerReplicator,
	ServerResponseBuilder = ServerResponseBuilder,
}
