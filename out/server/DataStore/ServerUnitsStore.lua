-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ServerResponseBuilder = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "ServerReplicator").ServerResponseBuilder
local UnitsStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "UnitsStore").default
local Utils = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Utils").default
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local ServerReplicator = TS.import(script, game:GetService("ServerScriptService"), "DataStore", "ServerReplicator").default
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
		replicator:Connect("create-unit", function(player, data)
			local buffer = BitBuffer(data)
			local unitData = self:Deserialize(buffer)
			self:Add(unitData)
			return ServerResponseBuilder.new():Build()
		end)
	end
	function ServerUnitsStore:Add(unitData)
		super.Add(self, unitData)
		replicator:ReplicateAll("unit-created", self:Serialize(unitData))
		return unitData
	end
	function ServerUnitsStore:Remove(unitId)
		super.Remove(self, unitId)
		local buffer = BitBuffer()
		buffer.writeString(unitId)
		replicator:ReplicateAll("unit-removed", buffer)
	end
	function ServerUnitsStore:UpdateUnitPosition(unitData)
		local position = unitData.position:Lerp(unitData.targetPosition, math.clamp(Utils:Map(os.time(), unitData.movementStartTick, unitData.movementEndTick, 0, 1), 0, 1))
		unitData.position = position
		unitData.movementStartTick = os.time()
	end
end
return {
	default = ServerUnitsStore,
}
