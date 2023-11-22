-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Store = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Store").default
local Players = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players
local Utils = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Utils").default
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
		self.cache = {}
	end
	function UnitsStore:AddUnit(unitData)
		local _cache = self.cache
		local _id = unitData.id
		local _unitData = unitData
		_cache[_id] = _unitData
		return unitData
	end
	function UnitsStore:RemoveUnit(unitId)
		local _cache = self.cache
		local _unitId = unitId
		_cache[_unitId] = nil
	end
	function UnitsStore:OverrideData(serializedUnitDatas)
		table.clear(self.cache)
		for _, serializedUnitData in serializedUnitDatas do
			local unitData = self:Deserialize(serializedUnitData)
			self:AddUnit(unitData)
		end
	end
	function UnitsStore:Serialize(unitData)
		return {
			id = unitData.id,
			type = unitData.type,
			position = unitData.position,
			playerId = unitData.playerData.player.UserId,
			targetPosition = unitData.targetPosition,
			movementStartTick = unitData.movementStartTick,
			movementEndTick = unitData.movementEndTick,
		}
	end
	function UnitsStore:Deserialize(serializedUnitData)
		local playerId = serializedUnitData.playerId
		local player = Players:GetPlayerByUserId(playerId)
		local _cache = (self.gameStore:GetStore("PlayersStore")).cache
		local _arg0 = tostring(player.UserId)
		local playerData = _cache[_arg0]
		return {
			id = serializedUnitData.id,
			type = serializedUnitData.type,
			position = serializedUnitData.position,
			playerData = playerData,
			targetPosition = serializedUnitData.targetPosition,
			movementStartTick = serializedUnitData.movementStartTick,
			movementEndTick = serializedUnitData.movementEndTick,
		}
	end
	function UnitsStore:UpdateUnitPosition(unitData)
		local position = unitData.position:Lerp(unitData.targetPosition, math.clamp(Utils:Map(tick(), unitData.movementStartTick, unitData.movementEndTick, 0, 1), 0, 1))
		unitData.position = position
		unitData.movementStartTick = tick()
	end
end
return {
	default = UnitsStore,
}
