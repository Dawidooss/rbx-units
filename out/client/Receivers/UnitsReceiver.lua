-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ClientGameStore = TS.import(script, script.Parent.Parent, "DataStore", "ClientGameStore").default
local ClientReplicator = TS.import(script, script.Parent.Parent, "DataStore", "ClientReplicator").default
local replicator = ClientReplicator:Get()
local gameStore = ClientGameStore:Get()
local unitsStore = gameStore:GetStore("UnitsStore")
local UnitsReplicator
do
	UnitsReplicator = setmetatable({}, {
		__tostring = function()
			return "UnitsReplicator"
		end,
	})
	UnitsReplicator.__index = UnitsReplicator
	function UnitsReplicator.new(...)
		local self = setmetatable({}, UnitsReplicator)
		return self:constructor(...) or self
	end
	function UnitsReplicator:constructor()
		UnitsReplicator.instance = self
		replicator:Connect("unit-movement", function(buffer)
			local unitId = buffer.readString()
			local position = buffer.readVector3()
			local startTick = buffer.readFloat32()
			local path = {}
			while buffer.getPointerByte() ~= buffer.getByteLength() do
				local _arg0 = buffer.readVector3()
				table.insert(path, _arg0)
			end
			local unit = unitsStore.cache[unitId]
			if not unit then
				replicator:FetchAll()
			end
		end)
	end
	function UnitsReplicator:Get()
		local _condition = UnitsReplicator.instance
		if not (_condition ~= 0 and (_condition == _condition and (_condition ~= "" and _condition))) then
			_condition = UnitsReplicator.new()
		end
		return _condition
	end
end
return {
	default = UnitsReplicator,
}
