-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Store = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Store").default
local Sedes = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Sedes").Sedes
local UnitsStoreBase
do
	local super = Store
	UnitsStoreBase = setmetatable({}, {
		__tostring = function()
			return "UnitsStoreBase"
		end,
		__index = super,
	})
	UnitsStoreBase.__index = UnitsStoreBase
	function UnitsStoreBase.new(...)
		local self = setmetatable({}, UnitsStoreBase)
		return self:constructor(...) or self
	end
	function UnitsStoreBase:constructor()
		self.name = "UnitsStore"
		local serializer = Sedes.Serializer.new({ { "id", Sedes.ToUnsigned(12) }, { "position", UnitsStoreBase.SedesPosition }, { "path", Sedes.ToArray(UnitsStoreBase.SedesPosition) }, { "health", Sedes.ToUnsigned(7) }, { "playerId", Sedes.ToUnsigned(20) }, { "name", Sedes.ToString() } })
		super.constructor(self, serializer, 128)
	end
	UnitsStoreBase.SedesPosition = {
		Ser = function(data, buffer)
			print(data)
			buffer.writeUnsigned(10, math.floor(data.X))
			buffer.writeUnsigned(10, math.floor(data.Z))
			return buffer
		end,
		Des = function(buffer)
			return Vector3.new(buffer.readUnsigned(10), 10, buffer.readUnsigned(10))
		end,
	}
end
local UnitData
do
	UnitData = setmetatable({}, {
		__tostring = function()
			return "UnitData"
		end,
	})
	UnitData.__index = UnitData
	function UnitData.new(...)
		local self = setmetatable({}, UnitData)
		return self:constructor(...) or self
	end
	function UnitData:constructor(data)
		self.id = data.id
		self.name = data.name
		self.position = data.position
		self.playerId = data.playerId
		self.path = data.path
		self.health = data.health
	end
end
return {
	default = UnitsStoreBase,
	UnitData = UnitData,
}
