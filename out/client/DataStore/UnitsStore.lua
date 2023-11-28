-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Workspace = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Workspace
local Unit = TS.import(script, script.Parent.Parent, "Units", "Unit").default
local UnitsStoreBase = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "UnitsStoreBase").default
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
		self.cache = {}
		self.folder = Instance.new("Folder", Workspace)
		self.folder.Name = "UnitsCache"
	end
	function UnitsStore:Add(unit)
		super.Add(self, unit)
		return unit
	end
	function UnitsStore:Remove(unitId)
		local _cache = self.cache
		local _unitId = unitId
		local unit = _cache[_unitId]
		local _result = unit
		if _result ~= nil then
			_result:Destroy()
		end
		super.Remove(self, unitId)
	end
	function UnitsStore:Clear()
		local _cache = self.cache
		local _arg0 = function(unitData)
			unitData:Destroy()
		end
		for _k, _v in _cache do
			_arg0(_v, _k, _cache)
		end
		super.Clear(self)
	end
	function UnitsStore:OverrideData(buffer)
		self:Clear()
		while buffer.readString() == "+" do
			local unitData = self:Deserialize(buffer)
			local unit = Unit.new(self.gameStore, unitData.id, unitData.name, unitData.position, unitData.playerId, unitData.path)
			self:Add(unit)
		end
	end
end
return {
	default = UnitsStore,
}
