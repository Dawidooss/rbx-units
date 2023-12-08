-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Sedes = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Sedes").Sedes
local Replicator = TS.import(script, script.Parent, "Replicator").default
local TeamsStoreBase = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "TeamStoreBase").default
local replicator = Replicator:Get()
local TeamsStore
do
	local super = TeamsStoreBase
	TeamsStore = setmetatable({}, {
		__tostring = function()
			return "TeamsStore"
		end,
		__index = super,
	})
	TeamsStore.__index = TeamsStore
	function TeamsStore.new(...)
		local self = setmetatable({}, TeamsStore)
		return self:constructor(...) or self
	end
	function TeamsStore:constructor()
		super.constructor(self)
		-- replicator.Connect("team-added", (buffer: BitBuffer) => {
		-- const teamData = this.Deserialize(buffer);
		-- if (this.cache.get(teamData.id)) return;
		-- this.Add(teamData);
		-- });
		-- replicator.Connect("team-removed", (buffer: BitBuffer) => {
		-- const teamId = bit.FromBits(buffer.readBits(4));
		-- this.Remove(teamId);
		-- });
		-- replicator.Connect(this.name, this.serializer, (data) => {
		-- this.OverrideCache(data);
		-- });
		local fetchSerializer = Sedes.Serializer.new({ { "data", Sedes.ToDict(Sedes.ToUnsigned(4), self.serializer) } })
		replicator:Connect("units-store", fetchSerializer, function(data)
			self:OverrideCache(data.data)
		end)
		TeamsStore.instance = self
	end
	function TeamsStore:Get()
		return TeamsStore.instance or TeamsStore.new()
	end
end
return {
	default = TeamsStore,
}
