-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Store = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Store").default
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local UnitsStore
do
	local super = Store
	UnitsStore = setmetatable({}, {
		__tostring = function()
			return "UnitsStore"
		end,
		__index = super,
	})
	UnitsStore.__index = UnitsStore
	function UnitsStore.new(...)
		local self = setmetatable({}, UnitsStore)
		return self:constructor(...) or self
	end
	function UnitsStore:constructor(...)
		super.constructor(self, ...)
		self.name = "UnitsStore"
	end
	function UnitsStore:Add(unitData)
		local _cache = self.cache
		local _id = unitData.id
		local _unitData = unitData
		_cache[_id] = _unitData
		return unitData
	end
	function UnitsStore:Serialize(unitData, buffer)
		local _condition = buffer
		if not buffer then
			_condition = BitBuffer()
		end
		buffer = _condition
		buffer.writeString(unitData.id)
		buffer.writeString(unitData.type)
		buffer.writeVector3(unitData.position)
		buffer.writeUInt32(unitData.playerId)
		buffer.writeVector3(unitData.targetPosition)
		buffer.writeUInt32(unitData.movementStartTick)
		buffer.writeUInt32(unitData.movementEndTick)
		return buffer
	end
	function UnitsStore:Deserialize(buffer)
		return {
			id = buffer.readString(),
			type = buffer.readString(),
			position = buffer.readVector3(),
			playerId = buffer.readUInt16(),
			targetPosition = buffer.readVector3(),
			movementStartTick = buffer.readUInt16(),
			movementEndTick = buffer.readUInt16(),
		}
	end
end
return {
	default = UnitsStore,
}
