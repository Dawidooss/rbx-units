-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local GameStore = TS.import(script, script.Parent.Parent, "DataStore", "GameStore").default
local Replicator = TS.import(script, script.Parent.Parent, "DataStore", "Replicator").default
local Unit = TS.import(script, script.Parent.Parent, "Units", "Unit").default
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local bit = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "bit")
local replicator = Replicator:Get()
local gameStore = GameStore:Get()
local unitsStore = gameStore:GetStore("UnitsStore")
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
		replicator:Connect("unit-created", function(buffer)
			local unitData = unitsStore:Deserialize(buffer)
			local _cache = unitsStore.cache
			local _id = unitData.id
			if _cache[_id] ~= nil then
				return nil
			end
			local unit = Unit.new(gameStore, unitData.id, unitData.name, unitData.position, unitData.playerId, unitData.path)
			unitsStore:Add(unit)
		end)
		replicator:Connect("unit-removed", function(buffer)
			local unitId = bit:FromBits(buffer.readBits(12))
			unitsStore:Remove(unitId)
		end)
		replicator:Connect("unit-movement", function(buffer)
			local unitId = bit:FromBits(buffer.readBits(12))
			local position = Vector3.new(bit:FromBits(buffer.readBits(10)), 10, bit:FromBits(buffer.readBits(10)))
			local path = unitsStore:DeserializePath(buffer)
			local unit = unitsStore.cache[unitId]
			if not unit then
				-- TODO: error? fetch-all
				return nil
			end
			local fakeQueue = ReplicationQueue.new()
			unit:UpdatePosition(position)
			unit.movement:MoveAlongPath(path, fakeQueue)
		end)
		replicator:Connect("update-unit-heal", function(buffer)
			local unitId = bit:FromBits(buffer.readBits(12))
			local health = bit:FromBits(buffer.readBits(7))
			local unit = unitsStore.cache[unitId]
			if not unit then
				-- TODO: error? fetch-all
				return nil
			end
			unit.health = health
			unit:UpdateVisuals()
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
