-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local UnitsStore = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "UnitsStore").default
local Unit = TS.import(script, script.Parent.Parent, "Units", "Unit").default
local Workspace = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Workspace
local ClientUnitsStore
do
	local super = UnitsStore
	ClientUnitsStore = setmetatable({}, {
		__tostring = function()
			return "ClientUnitsStore"
		end,
		__index = super,
	})
	ClientUnitsStore.__index = ClientUnitsStore
	function ClientUnitsStore.new(...)
		local self = setmetatable({}, ClientUnitsStore)
		return self:constructor(...) or self
	end
	function ClientUnitsStore:constructor(gameStore)
		super.constructor(self, gameStore)
		self.cache = {}
		self.folder = Instance.new("Folder", Workspace)
		self.replicator = gameStore.replicator
		self.folder.Name = "UnitsCache"
		self.replicator:Connect("unit-created", function(response)
			local serializedUnitData = response.data
			local unitData = self:Deserialize(serializedUnitData)
			local _cache = self.cache
			local _id = unitData.id
			if _cache[_id] ~= nil then
				return nil
			end
			unitData.instance = Unit.new(unitData)
			self:AddUnit(unitData)
		end)
		self.replicator:Connect("unit-removed", function(response)
			local serializedUnitId = response.data
			local unitId = serializedUnitId
			self:RemoveUnit(unitId)
		end)
	end
	function ClientUnitsStore:AddUnit(unitData)
		super.AddUnit(self, unitData)
		return unitData
	end
	function ClientUnitsStore:GetUnitsInstances()
		local instances = {}
		for _, unit in self.cache do
			local _instance = unit.instance
			table.insert(instances, _instance)
		end
		return instances
	end
	function ClientUnitsStore:OverrideData(serializedUnitDatas)
		local _cache = self.cache
		local _arg0 = function(unitData)
			unitData.instance:Destroy()
		end
		for _k, _v in _cache do
			_arg0(_v, _k, _cache)
		end
		super.OverrideData(self, serializedUnitDatas)
	end
end
return {
	default = ClientUnitsStore,
}
