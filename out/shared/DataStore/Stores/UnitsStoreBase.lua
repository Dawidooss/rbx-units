-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local bit = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "bit")
local Store = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Store").default
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local UnitData
local UnitsStoreBase
do
	local super = Store
	UnitsStoreBase = setmetatable({}, {
		__tostring = function()
			return "UnitsStoreBase"
		end,
		__index = super,
	})
	UnitsStoreBase.__index = UnitsStoreBase
	function UnitsStoreBase.new(...)
		local self = setmetatable({}, UnitsStoreBase)
		return self:constructor(...) or self
	end
	function UnitsStoreBase:constructor(gameStore)
		super.constructor(self, gameStore, 4096)
		self.name = "UnitsStore"
	end
	function UnitsStoreBase:SerializePath(path, buffer)
		for _, position in path do
			buffer.writeBits(1)
			buffer.writeBits(unpack(bit:ToBits(math.floor(position.X), 10)))
			buffer.writeBits(unpack(bit:ToBits(math.floor(position.Z), 10)))
		end
		buffer.writeBits(0)
	end
	function UnitsStoreBase:DeserializePath(buffer)
		local path = {}
		while buffer.readBits(1)[1] == 1 do
			local position = Vector3.new(bit:FromBits(buffer.readBits(10)), 10, bit:FromBits(buffer.readBits(10)))
			table.insert(path, position)
		end
		return path
	end
	function UnitsStoreBase:Serialize(unitData, buffer)
		local _condition = buffer
		if not buffer then
			_condition = BitBuffer()
		end
		buffer = _condition
		buffer.writeBits(unpack(bit:ToBits(unitData.id, 12)))
		buffer.writeBits(unpack(bit:ToBits(math.floor(unitData.position.X), 10)))
		buffer.writeBits(unpack(bit:ToBits(math.floor(unitData.position.Z), 10)))
		self:SerializePath(unitData.path, buffer)
		buffer.writeBits(unpack(bit:ToBits(unitData.health, 7)))
		buffer.writeString(tostring(unitData.playerId))
		buffer.writeString(unitData.name)
		return buffer
	end
	function UnitsStoreBase:Deserialize(buffer)
		local id = bit:FromBits(buffer.readBits(12))
		local position = Vector3.new(bit:FromBits(buffer.readBits(10)), 10, bit:FromBits(buffer.readBits(10)))
		local path = self:DeserializePath(buffer)
		local health = bit:FromBits(buffer.readBits(7))
		local playerId = tonumber(buffer.readString())
		local name = buffer.readString()
		local unitData = UnitData.new(id, name, position, playerId, path, health)
		return unitData
	end
end
do
	UnitData = setmetatable({}, {
		__tostring = function()
			return "UnitData"
		end,
	})
	UnitData.__index = UnitData
	function UnitData.new(...)
		local self = setmetatable({}, UnitData)
		return self:constructor(...) or self
	end
	function UnitData:constructor(id, name, position, playerId, path, health)
		self.id = id
		self.name = name
		self.position = position
		self.playerId = playerId
		local _condition = health
		if not (_condition ~= 0 and (_condition == _condition and _condition)) then
			_condition = 100
		end
		self.health = _condition
		self.path = path or {}
	end
end
return {
	default = UnitsStoreBase,
	UnitData = UnitData,
}
