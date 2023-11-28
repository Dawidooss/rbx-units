-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local Store = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Store").default
local TeamsStore
do
	local super = Store
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
	function TeamsStore:constructor(...)
		super.constructor(self, ...)
		self.name = "TeamsStore"
	end
	function TeamsStore:Add(teamData)
		local teamId = teamData.id
		local _cache = self.cache
		local _teamData = teamData
		_cache[teamId] = _teamData
		return teamData
	end
	function TeamsStore:Serialize(teamData, buffer)
		local _condition = buffer
		if not buffer then
			_condition = BitBuffer()
		end
		buffer = _condition
		buffer.writeString(teamData.id)
		buffer.writeString(teamData.name)
		buffer.writeColor3(teamData.color)
		return buffer
	end
	function TeamsStore:Deserialize(buffer)
		return {
			id = buffer.readString(),
			name = buffer.readString(),
			color = buffer.readColor3(),
		}
	end
end
return {
	default = TeamsStore,
}
