-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local UnitsStoreBase = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "UnitsStoreBase").default
local ServerReplicator = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "Replicator").default
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local bit = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "bit")
local replicator = ServerReplicator:Get()
local UnitsStore
do
	local super = UnitsStoreBase
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
	function UnitsStore:constructor(gameStore)
		super.constructor(self, gameStore)
		replicator:Connect("create-unit", function(player, buffer, replicationQueue)
			local unitData = self:Deserialize(buffer)
			self:Add(unitData, replicationQueue)
		end)
		replicator:Connect("unit-movement", function(player, buffer, replicationQueue)
			debug.profilebegin("unit-movement")
			debug.profilebegin("reading-bits")
			local idBits = buffer.readBits(12)
			local xBits = buffer.readBits(10)
			local yBits = buffer.readBits(10)
			local unitId = bit:FromBits(idBits)
			local position = Vector3.new(bit:FromBits(xBits), 10, bit:FromBits(yBits))
			local unit = self.cache[unitId]
			debug.profileend()
			if not unit then
				return nil
			end
			debug.profilebegin("deserialisation")
			local path = self:DeserializePath(buffer)
			unit.path = path
			unit.position = position
			debug.profileend()
			debug.profilebegin("replication")
			replicationQueue:Add("unit-movement", function(writeBuffer)
				writeBuffer.writeBits(unpack(idBits))
				writeBuffer.writeBits(unpack(xBits))
				writeBuffer.writeBits(unpack(yBits))
				self:DeserializePath(writeBuffer)
				return writeBuffer
			end)
			debug.profileend()
			debug.profileend()
		end)
		replicator:Connect("update-unit-heal", function(player, buffer, replicationQueue)
			local unitId = bit:FromBits(buffer.readBits(12))
			local health = bit:FromBits(buffer.readBits(7))
			local unit = self.cache[unitId]
			if not unit then
				return nil
			end
			unit.health = health
			if unit.health <= 0 then
				-- kill
				replicationQueue:Add("unit-removed", function(writeBuffer)
					writeBuffer.writeBits(unpack(bit:ToBits(unitId, 12)))
					return writeBuffer
				end)
			else
				replicationQueue:Add("update-unit-heal", function(writeBuffer)
					writeBuffer.writeBits(unpack(bit:ToBits(unitId, 12)))
					writeBuffer.writeBits(unpack(bit:ToBits(health, 7)))
					return writeBuffer
				end)
			end
		end)
	end
	function UnitsStore:Add(unitData, queue)
		super.Add(self, unitData)
		local queuePassed = not not queue
		local _condition = queue
		if not queue then
			_condition = ReplicationQueue.new()
		end
		queue = _condition
		queue:Add("unit-created", function(buffer)
			return self:Serialize(unitData, buffer)
		end)
		if not queuePassed then
			replicator:ReplicateAll(queue)
		end
		return unitData
	end
	function UnitsStore:Remove(unitId, queue)
		super.Remove(self, unitId)
		local queuePassed = not not queue
		local _condition = queue
		if not queue then
			_condition = ReplicationQueue.new()
		end
		queue = _condition
		queue:Add("unit-removed", function(buffer)
			buffer.writeString(tostring(unitId))
			return buffer
		end)
		if not queuePassed then
			replicator:ReplicateAll(queue)
		end
	end
end
return {
	default = UnitsStore,
}
