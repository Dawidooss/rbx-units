-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local Store
do
	Store = {}
	function Store:constructor(gameStore, max)
		self.name = "Store"
		self.cache = {}
		self.freeIds = {}
		self.max = 0
		self.gameStore = gameStore
		self.max = max
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < max) then
					break
				end
				local _freeIds = self.freeIds
				local _i = i
				table.insert(_freeIds, _i)
			end
		end
	end
	function Store:OverrideData(buffer)
		self:Clear()
		while buffer.readBits(1)[1] == 1 do
			local data = self:Deserialize(buffer)
			self:Add(data)
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
		local _freeIds = self.freeIds
		local _key_1 = key
		table.insert(_freeIds, _key_1)
	end
	function Store:Clear()
		table.clear(self.cache)
	end
	function Store:Add(value)
		local _cache = self.cache
		local _id = value.id
		local _value = value
		_cache[_id] = _value
		local _freeIds = self.freeIds
		local _arg0 = function(v)
			return v == value.id
		end
		-- ▼ ReadonlyArray.find ▼
		local _result
		for _i, _v in _freeIds do
			if _arg0(_v, _i - 1, _freeIds) == true then
				_result = _v
				break
			end
		end
		-- ▲ ReadonlyArray.find ▲
		local i = _result
		if i ~= 0 and (i == i and i) then
			table.remove(self.freeIds, i + 1)
		end
		return value
	end
end
return {
	default = Store,
}
