-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Replicator = TS.import(script, script.Parent.Parent, "DataStore", "Replicator").default
local UnitsStore = TS.import(script, script.Parent.Parent, "DataStore", "UnitsStore").default
local Unit = TS.import(script, script.Parent.Parent, "Units", "Unit").default
local Sedes = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Sedes").Sedes
local replicator = Replicator:Get()
local unitsStore = UnitsStore:Get()
local UnitsReceiver
do
	UnitsReceiver = setmetatable({}, {
		__tostring = function()
			return "UnitsReceiver"
		end,
	})
	UnitsReceiver.__index = UnitsReceiver
	function UnitsReceiver.new(...)
		local self = setmetatable({}, UnitsReceiver)
		return self:constructor(...) or self
	end
	function UnitsReceiver:constructor()
		replicator:Connect("unit-created", unitsStore.serializer, function(unitData)
			local _cache = unitsStore.cache
			local _id = unitData.id
			if _cache[_id] ~= nil then
				return nil
			end
			local unit = Unit.new(unitData.id, unitData)
			unitsStore:Add(unit)
		end)
		-- replicator.Connect("unit-removed", (buffer: BitBuffer) => {
		-- const unitId = bit.FromBits(buffer.readBits(12));
		-- unitsStore.Remove(unitId);
		-- });
		-- replicator.Connect("unit-movement", (buffer: BitBuffer) => {
		-- const unitId = bit.FromBits(buffer.readBits(12));
		-- const position = new Vector3(bit.FromBits(buffer.readBits(10)), 10, bit.FromBits(buffer.readBits(10)));
		-- const path = unitsStore.DeserializePath(buffer);
		-- const unit = unitsStore.cache.get(unitId);
		-- if (!unit) {
		-- // TODO: error? fetch-all
		-- return;
		-- }
		-- const fakeQueue = new ReplicationQueue();
		-- unit.UpdatePosition(position);
		-- unit.movement.MoveAlongPath(path, fakeQueue);
		-- });
		-- replicator.Connect("update-unit-heal", (buffer: BitBuffer) => {
		-- const unitId = bit.FromBits(buffer.readBits(12));
		-- const health = bit.FromBits(buffer.readBits(7));
		-- const unit = unitsStore.cache.get(unitId);
		-- if (!unit) {
		-- // TODO: error? fetch-all
		-- return;
		-- }
		-- unit.health = health;
		-- unit.UpdateVisuals();
		-- });
		-- fetching connection
		local fetchSerializer = Sedes.Serializer.new({ { "data", Sedes.ToDict(Sedes.ToUnsigned(12), unitsStore.serializer) } })
		replicator:Connect("units-store", fetchSerializer, function(data)
			local newCache = {}
			for unitId, unitData in data.data do
				local _unit = Unit.new(unitId, unitData)
				newCache[unitId] = _unit
			end
			unitsStore:OverrideCache(newCache)
		end)
		UnitsReceiver.instance = self
	end
	function UnitsReceiver:Get()
		local _condition = UnitsReceiver.instance
		if not (_condition ~= 0 and (_condition == _condition and (_condition ~= "" and _condition))) then
			_condition = UnitsReceiver.new()
		end
		return _condition
	end
end
return {
	default = UnitsReceiver,
}
