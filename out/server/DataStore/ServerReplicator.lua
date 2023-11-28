-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
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
		ServerReplicator.instance = self
	end
	function ServerReplicator:Replicate(player, key, buffer)
		local response = ServerResponseBuilder.new():SetData(buffer.dumpString()):Build()
		Network:FireClient(player, key, response)
	end
	function ServerReplicator:ReplicateAll(key, buffer)
		local response = ServerResponseBuilder.new():SetData(buffer.dumpString()):Build()
		Network:FireAllClients(key, response)
	end
	function ServerReplicator:ReplicateExcept(player, key, buffer)
		local response = ServerResponseBuilder.new():SetData(buffer.dumpString()):Build()
		Network:FireOtherClients(player, key, response)
	end
	function ServerReplicator:Connect(key, callback)
		Network:BindFunctions({
			[key] = callback,
		})
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
