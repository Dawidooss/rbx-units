-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Store = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Store").default
local Players = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local bit = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "bit")
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
	function PlayersStoreBase:constructor(gameStore)
		super.constructor(self, gameStore, 128)
		self.name = "PlayersStore"
	end
	function PlayersStoreBase:Serialize(playerData, buffer)
		local _condition = buffer
		if not buffer then
			_condition = BitBuffer()
		end
		buffer = _condition
		buffer.writeString(tostring(playerData.player.UserId))
		buffer.writeBits(unpack(bit:ToBits(playerData.teamId, 4)))
		return buffer
	end
	function PlayersStoreBase:Deserialize(buffer)
		local playerId = tonumber(buffer.readString())
		local player = Players:GetPlayerByUserId(playerId)
		return {
			id = playerId,
			player = player,
			teamId = bit:FromBits(buffer.readBits(4)),
		}
	end
end
return {
	default = PlayersStoreBase,
}
