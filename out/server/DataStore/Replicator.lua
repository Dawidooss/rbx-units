-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local ServerResponseBuilder
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
				local mainResponse = ServerResponseBuilder.new()
				ReplicationQueue:Divide(data, function(key, buffer)
					local _arg0 = self.connections[key]
					local _arg1 = "Connection " .. (key .. " missing in ServerReplicator")
					assert(_arg0, _arg1)
					local replicationQueue = ReplicationQueue.new()
					local playerResponse = self.connections[key](player, buffer, replicationQueue)
					if playerResponse then
						local _value = playerResponse.data
						if _value ~= "" and _value then
							mainResponse:SetData(playerResponse.data)
						end
						local _value_1 = playerResponse.errorMessage
						if _value_1 ~= "" and _value_1 then
							mainResponse:SetError(playerResponse.errorMessage)
						end
						local _value_2 = playerResponse.status
						if _value_2 ~= "" and _value_2 then
							mainResponse:SetStatus(playerResponse.status)
						end
					end
					if replicationQueue:DumpString() == "" then
						return nil
					end
					self:ReplicateExcept(player, replicationQueue)
				end)
				return { mainResponse }
			end,
		})
	end
	function Replicator:Replicate(player, queue)
		local response = ServerResponseBuilder.new():SetData(queue:DumpString()):Build()
		Network:FireClient(player, "chunked-data", response)
	end
	function Replicator:ReplicateExcept(player, queue)
		local response = ServerResponseBuilder.new():SetData(queue:DumpString()):Build()
		Network:FireOtherClients(player, "chunked-data", response)
	end
	function Replicator:ReplicateAll(queue)
		local response = ServerResponseBuilder.new():SetData(queue:DumpString()):Build()
		Network:FireAllClients("chunked-data", response)
	end
	function Replicator:Connect(key, callback)
		self.connections[key] = callback
	end
	function Replicator:Get()
		return Replicator.instance or Replicator.new()
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
	default = Replicator,
	ServerResponseBuilder = ServerResponseBuilder,
}
