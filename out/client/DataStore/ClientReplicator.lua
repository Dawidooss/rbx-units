-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
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
		ClientReplicator.instance = self
	end
	function ClientReplicator:Replicate(key, serializedData)
		local response = Network:InvokeServer(key, serializedData)
		return response
	end
	function ClientReplicator:Connect(key, callback)
		Network:BindEvents({
			[key] = function(response)
				local bufferStringified = response.data
				local buffer = BitBuffer(bufferStringified)
				callback(buffer)
			end,
		})
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
