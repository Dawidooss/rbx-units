-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
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
	function ClientReplicator:constructor(gameStore)
		self.gameStore = gameStore
	end
	function ClientReplicator:Replicate(key, serializedData)
		local response = Network:InvokeServer(key, serializedData)
		-- if (response.error) {
		-- if (response.errorMessage === "fetch-all") {
		-- this.FetchAll();
		-- }
		-- }
		return response
	end
	function ClientReplicator:Connect(key, callback)
		Network:BindEvents({
			[key] = callback,
		})
	end
	function ClientReplicator:FetchAll()
		local response = Network:InvokeServer("fetch-all")[1]
		if not response then
			return nil
		end
		local data = response.data
		if response.error or not data then
			-- TODO notify error
			return nil
		end
		for storeName, serializedData in data do
			local _result = self.gameStore:GetStore(storeName)
			if _result ~= nil then
				_result:OverrideData(serializedData)
			end
		end
	end
end
return {
	default = ClientReplicator,
}
