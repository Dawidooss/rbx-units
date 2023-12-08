-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Sedes = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Sedes").Sedes
local ClientReplicator = TS.import(script, script.Parent, "Replicator").default
local PlayersStoreBase = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "PlayersStoreBase").default
local replicator = ClientReplicator:Get()
local PlayersStore
do
	local super = PlayersStoreBase
	PlayersStore = setmetatable({}, {
		__tostring = function()
			return "PlayersStore"
		end,
		__index = super,
	})
	PlayersStore.__index = PlayersStore
	function PlayersStore.new(...)
		local self = setmetatable({}, PlayersStore)
		return self:constructor(...) or self
	end
	function PlayersStore:constructor()
		super.constructor(self)
		-- replicator.Connect(
		-- "player-added",
		-- new QueueDeserializer<{
		-- player: PlayerData;
		-- }>([["player", Des.Array<PlayerData>(this.Deserialize)]], (data) => {
		-- for (const playerData of data.players) {
		-- this.Add(playerData);
		-- }
		-- }),
		-- );
		-- replicator.Connect(
		-- "players-added",
		-- new QueueDeserializer<{
		-- players: PlayerData[];
		-- test: PlayerData[];
		-- }>([["player", Des.Array<PlayerData>(this.Deserialize)]], (data) => {
		-- for (const playerData of data.players) {
		-- this.Add(playerData);
		-- }
		-- }),
		-- );
		-- replicator.Connect("player-removed", (buffer: BitBuffer) => {
		-- const playerId = tonumber(buffer.readString())!;
		-- this.Remove(playerId);
		-- });
		-- replicator.Connect(this.name, new Sedes.Serializer<{
		-- data: PlayerData[]
		-- }([
		-- ["data", Sedes.ToArray<PlayerData>(this)]
		-- ])>, (data) => {
		-- this.OverrideData(data.buffer);
		-- });
		-- replicator.Connect(
		-- this.name,
		-- new Sedes.Serializer<{
		-- data: Map<number, PlayerData>;
		-- }>([["data", Sedes.ToDict<number, PlayerData>(Sedes.ToUnsigned(20), this.serializer)]]),
		-- (data) => {
		-- this.OverrideCache(data.data);
		-- },
		-- );
		local serializer = Sedes.Serializer.new({ { "data", Sedes.ToDict(Sedes.ToUnsigned(10), self.serializer) } })
		replicator:Connect(self.name, serializer, function(data)
			self:OverrideCache(data.data)
		end)
		PlayersStore.instance = self
	end
	function PlayersStore:Get()
		return PlayersStore.instance or PlayersStore.new()
	end
end
return {
	default = PlayersStore,
}
