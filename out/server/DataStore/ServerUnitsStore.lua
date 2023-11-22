-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ServerResponseBuilder = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "ServerReplicator").ServerResponseBuilder
local UnitsStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "UnitsStore").default
local Utils = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Utils").default
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
		self.replicator = gameStore.replicator
		self.replicator:Connect("create-unit", function(player, serializedUnitData)
			local unitData = self:Deserialize(serializedUnitData)
			self:AddUnit(unitData)
			return ServerResponseBuilder.new():Build()
		end)
	end
	function ServerUnitsStore:AddUnit(unitData)
		super.AddUnit(self, unitData)
		self.replicator:ReplicateAll("unit-created", self:Serialize(unitData))
		return unitData
	end
	function ServerUnitsStore:RemoveUnit(unitId)
		super.RemoveUnit(self, unitId)
		self.replicator:ReplicateAll("unit-removed", unitId)
	end
	function ServerUnitsStore:UpdateUnitPosition(unitData)
		local position = unitData.position:Lerp(unitData.targetPosition, math.clamp(Utils:Map(tick(), unitData.movementStartTick, unitData.movementEndTick, 0, 1), 0, 1))
		unitData.position = position
		unitData.movementStartTick = tick()
	end
end
return {
	default = ServerUnitsStore,
}
