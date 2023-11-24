-- Compiled with roblox-ts v2.1.1
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
		while not buffer.isFinished() do
			local hasData = buffer.readBits(1)[1] == 1
			if not hasData then
				break
			end
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
			buffer.writeBits(1)
			self:Serialize(data, buffer)
		end
		buffer.writeBits(0)
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
