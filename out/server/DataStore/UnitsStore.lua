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
			local startPointer = buffer.getPointer()
			local unitId = bit:FromBits(buffer.readBits(12))
			local position = Vector3.new(bit:FromBits(buffer.readBits(10)), 10, bit:FromBits(buffer.readBits(10)))
			local unit = self.cache[unitId]
			local path = self:DeserializePath(buffer)
			local endPointer = buffer.getPointer()
			if not unit then
				return nil
			end
			unit.path = path
			unit.position = position
			replicationQueue:Add("unit-movement", function(writeBuffer)
				buffer.setPointer(startPointer)
				return writeBuffer
			end)
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
