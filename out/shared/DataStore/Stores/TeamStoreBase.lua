-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local Store = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Store").default
local bit = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "bit")
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
	function TeamsStoreBase:constructor(gameStore)
		super.constructor(self, gameStore, 16)
		self.name = "TeamsStore"
	end
	function TeamsStoreBase:Serialize(teamData, buffer)
		local _condition = buffer
		if not buffer then
			_condition = BitBuffer()
		end
		buffer = _condition
		buffer.writeBits(unpack(bit:ToBits(teamData.id, 4)))
		buffer.writeString(teamData.name)
		buffer.writeColor3(teamData.color)
		return buffer
	end
	function TeamsStoreBase:Deserialize(buffer)
		return {
			id = bit:FromBits(buffer.readBits(4)),
			name = buffer.readString(),
			color = buffer.readColor3(),
		}
	end
end
return {
	default = TeamsStoreBase,
}
