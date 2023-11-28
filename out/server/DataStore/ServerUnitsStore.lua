-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ServerResponseBuilder = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "ServerReplicator").ServerResponseBuilder
local UnitsStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "UnitsStoreBase").default
local ServerReplicator = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "ServerReplicator").default
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local replicator = ServerReplicator:Get()
local ServerUnitsStore
do
	local super = UnitsStore
	ServerUnitsStore = setmetatable({}, {
		__tostring = function()
			return "ServerUnitsStore"
		end,
		__index = super,
	})
	ServerUnitsStore.__index = ServerUnitsStore
	function ServerUnitsStore.new(...)
		local self = setmetatable({}, ServerUnitsStore)
		return self:constructor(...) or self
	end
	function ServerUnitsStore:constructor(gameStore)
		super.constructor(self, gameStore)
		replicator:Connect("create-unit", function(player, buffer)
			local unitData = self:Deserialize(buffer)
			local queue = ReplicationQueue.new()
			self:Add(unitData, queue)
			replicator:ReplicateAll(queue)
			return ServerResponseBuilder.new():Build()
		end)
		replicator:Connect("unit-movement", function(player, buffer)
			local unitId = buffer.readString()
			local position = buffer.readVector3()
			local unit = self.cache[unitId]
			if not unit then
				return ServerResponseBuilder.new():SetError("data-missmatch"):Build()
			end
			local path = self:DeserializePath(buffer)
			unit.path = path
			unit.position = position
			local queue = ReplicationQueue.new()
			queue:Add("unit-movement", function(queueBuffer)
				queueBuffer.writeString(unitId)
				queueBuffer.writeVector3(position)
				self:SerializePath(path, queueBuffer)
			end)
			replicator:ReplicateExcept(player, queue)
			return ServerResponseBuilder.new():Build()
		end)
	end
	function ServerUnitsStore:Add(unitData, queue)
		super.Add(self, unitData)
		local queuePassed = not not queue
		local _condition = queue
		if not queue then
			_condition = ReplicationQueue.new()
		end
		queue = _condition
		queue:Add("unit-created", function(buffer)
			self:Serialize(unitData, buffer)
		end)
		if not queuePassed then
			replicator:ReplicateAll(queue)
		end
		return unitData
	end
	function ServerUnitsStore:Remove(unitId, queue)
		super.Remove(self, unitId)
		local queuePassed = not not queue
		local _condition = queue
		if not queue then
			_condition = ReplicationQueue.new()
		end
		queue = _condition
		queue:Add("unit-created", function(buffer)
			buffer.writeString(unitId)
		end)
		if not queuePassed then
			replicator:ReplicateAll(queue)
		end
	end
end
return {
	default = ServerUnitsStore,
}
