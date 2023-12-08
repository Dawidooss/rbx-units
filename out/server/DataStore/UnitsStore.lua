-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local UnitsStoreBase = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "UnitsStoreBase").default
local ServerReplicator = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "Replicator").default
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
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
	function UnitsStore:constructor()
		super.constructor(self)
		replicator:Connect("create-unit", self.serializer, function(player, data, response, replication)
			self:Add(data, replication)
		end)
		UnitsStore.instance = self
		-- replicator.Connect(
		-- "unit-movement",
		-- new QueueDeserializer<{
		-- unitId: number;
		-- position: Vector3;
		-- path: Vector3[];
		-- }>([
		-- ["unitId", Des.Signed(12)],
		-- ["position", Des.Custom<Vector3>(this.DeserializePosition)],
		-- ["path", Des.Array<Vector3>(this.DeserializePosition)],
		-- ]),
		-- (player, data) => {
		-- const unit = this.cache.get(data.unitId);
		-- if (!unit) return;
		-- unit.path = data.path;
		-- unit.position = data.position;
		-- // replicationQueue.Add("unit-movement", (writeBuffer) => {
		-- // 	buffer.setPointer(startPointer);
		-- // 	return writeBuffer;
		-- // });
		-- },
		-- );
		-- replicator.Connect("unit-movement",  (player: Player, buffer: BitBuffer, replicationQueue: ReplicationQueue) => {
		-- const startPointer = buffer.getPointer();
		-- const unitId = bit.FromBits(buffer.readBits(12));
		-- const position = new Vector3(bit.FromBits(buffer.readBits(10)), 10, bit.FromBits(buffer.readBits(10)));
		-- const unit = this.cache.get(unitId);
		-- const path = this.DeserializePath(buffer);
		-- const endPointer = buffer.getPointer();
		-- if (!unit) return;
		-- unit.path = path;
		-- unit.position = position;
		-- replicationQueue.Add("unit-movement", (writeBuffer) => {
		-- buffer.setPointer(startPointer);
		-- return writeBuffer;
		-- });
		-- });
		-- replicator.Connect(
		-- "update-unit-heal",
		-- (player: Player, buffer: BitBuffer, replicationQueue: ReplicationQueue) => {
		-- const unitId = bit.FromBits(buffer.readBits(12));
		-- const health = bit.FromBits(buffer.readBits(7));
		-- const unit = this.cache.get(unitId);
		-- if (!unit) return;
		-- unit.health = health;
		-- if (unit.health <= 0) {
		-- // kill
		-- replicationQueue.Add("unit-removed", (writeBuffer) => {
		-- writeBuffer.writeBits(...bit.ToBits(unitId, 12));
		-- return writeBuffer;
		-- });
		-- } else {
		-- replicationQueue.Add("update-unit-heal", (writeBuffer) => {
		-- writeBuffer.writeBits(...bit.ToBits(unitId, 12));
		-- writeBuffer.writeBits(...bit.ToBits(health, 7));
		-- return writeBuffer;
		-- });
		-- }
		-- },
		-- );
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
			return self.serializer.Ser(unitData, buffer)
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
	function UnitsStore:Get()
		return UnitsStore.instance or UnitsStore.new()
	end
end
return {
	default = UnitsStore,
}
