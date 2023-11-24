-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Store = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Store").default
local Players = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
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
	end
	function PlayersStore:Add(playerData)
		local _cache = self.cache
		local _arg0 = tostring(playerData.player.UserId)
		local _playerData = playerData
		_cache[_arg0] = _playerData
		return playerData
	end
	function PlayersStore:Serialize(playerData, buffer)
		local _condition = buffer
		if not buffer then
			_condition = BitBuffer()
		end
		buffer = _condition
		buffer.writeUInt32(playerData.player.UserId)
		buffer.writeString(playerData.teamId)
		return buffer
	end
	function PlayersStore:Deserialize(buffer)
		local playerId = buffer.readUInt32()
		local player = Players:GetPlayerByUserId(playerId)
		return {
			player = player,
			teamId = buffer.readString(),
		}
	end
end
return {
	default = PlayersStore,
}
