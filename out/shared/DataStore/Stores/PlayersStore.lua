-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Store = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Store").default
local Players = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players
local PlayersStore
do
	local super = Store
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
	function PlayersStore:constructor(...)
		super.constructor(self, ...)
		self.name = "PlayersStore"
		self.cache = {}
	end
	function PlayersStore:AddPlayer(playerData)
		local _cache = self.cache
		local _arg0 = tostring(playerData.player.UserId)
		local _playerData = playerData
		_cache[_arg0] = _playerData
		return playerData
	end
	function PlayersStore:RemovePlayer(playerId)
		local _cache = self.cache
		local _playerId = playerId
		_cache[_playerId] = nil
	end
	function PlayersStore:OverrideData(serializedPlayerDatas)
		table.clear(self.cache)
		for _, serializedPlayerData in serializedPlayerDatas do
			local playerData = self:Deserialize(serializedPlayerData)
			self:AddPlayer(playerData)
		end
	end
	function PlayersStore:Serialize(playerData)
		return {
			playerId = playerData.player.UserId,
			teamId = playerData.team.id,
		}
		-- return {
		-- playerId: Squash.int.ser(playerData.player.UserId),
		-- teamId: Squash.string.ser(playerData.team.id),
		-- };
	end
	function PlayersStore:Deserialize(serializedPlayerData)
		local playerId = serializedPlayerData.playerId
		local player = Players:GetPlayerByUserId(playerId)
		local teamId = serializedPlayerData.teamId
		local team = (self.gameStore:GetStore("TeamsStore")).cache[teamId]
		return {
			player = player,
			team = team,
		}
	end
end
return {
	default = PlayersStore,
}
