-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Store = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Store").default
local Sedes = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Sedes").Sedes
local PlayersStoreBase
do
	local super = Store
	PlayersStoreBase = setmetatable({}, {
		__tostring = function()
			return "PlayersStoreBase"
		end,
		__index = super,
	})
	PlayersStoreBase.__index = PlayersStoreBase
	function PlayersStoreBase.new(...)
		local self = setmetatable({}, PlayersStoreBase)
		return self:constructor(...) or self
	end
	function PlayersStoreBase:constructor()
		self.name = "PlayersStore"
		local serializer = Sedes.Serializer.new({ { "id", Sedes.ToUnsigned(40) }, { "teamId", Sedes.ToUnsigned(4) } })
		super.constructor(self, serializer, 128)
	end
end
return {
	default = PlayersStoreBase,
}
