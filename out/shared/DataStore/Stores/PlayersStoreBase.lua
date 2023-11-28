-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Store = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Store").default
local Players = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
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
	function PlayersStoreBase:constructor(...)
		super.constructor(self, ...)
		self.name = "PlayersStore"
	end
	function PlayersStoreBase:Add(playerData)
		local _cache = self.cache
		local _arg0 = tostring(playerData.player.UserId)
		local _playerData = playerData
		_cache[_arg0] = _playerData
		return playerData
	end
	function PlayersStoreBase:Serialize(playerData, buffer)
		local _condition = buffer
		if not buffer then
			_condition = BitBuffer()
		end
		buffer = _condition
		buffer.writeString(tostring(playerData.player.UserId))
		buffer.writeString(playerData.teamId)
		return buffer
	end
	function PlayersStoreBase:Deserialize(buffer)
		local playerId = tonumber(buffer.readString())
		local player = Players:GetPlayerByUserId(playerId)
		return {
			player = player,
			teamId = buffer.readString(),
		}
	end
end
return {
	default = PlayersStoreBase,
}
