-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local Store
do
	Store = {}
	function Store:constructor(gameStore)
		self.name = "Store"
		self.cache = {}
		self.gameStore = gameStore
	end
	function Store:OverrideData(buffer)
		table.clear(self.cache)
		while buffer.readString() == "+" do
			local unitData = self:Deserialize(buffer)
			self:Add(unitData)
		end
	end
	function Store:SerializeCache(buffer)
		local _condition = buffer
		if not buffer then
			_condition = BitBuffer()
		end
		buffer = _condition
		for _, data in self.cache do
			buffer.writeString("+")
			self:Serialize(data, buffer)
		end
		buffer.writeString("-")
		return buffer
	end
	function Store:Remove(key)
		local _cache = self.cache
		local _key = key
		_cache[_key] = nil
	end
end
return {
	default = Store,
}
