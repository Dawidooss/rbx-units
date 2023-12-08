-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Store = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Store").default
local Sedes = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Sedes").Sedes
local TeamsStoreBase
do
	local super = Store
	TeamsStoreBase = setmetatable({}, {
		__tostring = function()
			return "TeamsStoreBase"
		end,
		__index = super,
	})
	TeamsStoreBase.__index = TeamsStoreBase
	function TeamsStoreBase.new(...)
		local self = setmetatable({}, TeamsStoreBase)
		return self:constructor(...) or self
	end
	function TeamsStoreBase:constructor()
		self.name = "TeamsStore"
		local serializer = Sedes.Serializer.new({ { "id", Sedes.ToUnsigned(4) }, { "name", Sedes.ToString() }, { "color", Sedes.ToColor3() } })
		super.constructor(self, serializer, 128)
	end
end
return {
	default = TeamsStoreBase,
}
