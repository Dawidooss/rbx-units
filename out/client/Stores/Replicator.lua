-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
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
	function Replicator:constructor(gameStore)
		self.gameStore = gameStore
	end
	function Replicator:Replicate(key, serializedData)
		local response = Network:InvokeServer(key, serializedData)[1]
		if response.error then
			if response.errorMessage == "FetchAll" then
				self:FetchAll()
			end
		end
	end
	function Replicator:Connect(key, callback)
		Network:BindEvents({
			[key] = callback,
		})
	end
	function Replicator:FetchAll()
		local response = Network:InvokeServer("FetchAll")[1]
		local _value = response.error
		local _condition = not (_value ~= 0 and (_value == _value and (_value ~= "" and _value)))
		if _condition then
			_condition = response.data
		end
		if _condition ~= 0 and (_condition == _condition and (_condition ~= "" and _condition)) then
			for _, _binding in response.data do
				local storeName = _binding[1]
				local data = _binding[2]
				local _result = self.gameStore:GetStore(storeName)
				if _result ~= nil then
					_result:OverrideData(data)
				end
			end
		end
	end
end
return {
	default = Replicator,
}
