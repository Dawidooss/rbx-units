-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
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
	function UnitsStoreBase:constructor(...)
		super.constructor(self, ...)
		self.name = "UnitsStore"
	end
	function UnitsStoreBase:Add(unitData)
		local _cache = self.cache
		local _id = unitData.id
		local _unitData = unitData
		_cache[_id] = _unitData
		return unitData
	end
	function UnitsStoreBase:SerializePath(path, buffer)
		for _, position in path do
			buffer.writeString("+")
			buffer.writeVector3(position)
		end
		buffer.writeString("-")
	end
	function UnitsStoreBase:DeserializePath(buffer)
		local path = {}
		while buffer.readString() == "+" do
			local position = buffer.readVector3()
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
		buffer.writeString(unitData.id)
		buffer.writeString(unitData.name)
		buffer.writeVector3(unitData.position)
		buffer.writeString(tostring(unitData.playerId))
		self:SerializePath(unitData.path, buffer)
		return buffer
	end
	function UnitsStoreBase:Deserialize(buffer)
		local id = buffer.readString()
		local name = buffer.readString()
		local position = buffer.readVector3()
		local playerId = tonumber(buffer.readString())
		local path = self:DeserializePath(buffer)
		local unitData = UnitData.new(id, name, position, playerId, path)
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
	function UnitData:constructor(id, name, position, playerId, path)
		self.path = {}
		self.id = id
		self.name = name
		self.position = position
		self.playerId = playerId
		if path then
			self.path = path
		end
	end
end
return {
	default = UnitsStoreBase,
	UnitData = UnitData,
}
