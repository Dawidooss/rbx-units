-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
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
		self.cache = {}
	end
	function TeamsStore:AddTeam(teamData)
		local teamId = teamData.id
		local _cache = self.cache
		local _teamData = teamData
		_cache[teamId] = _teamData
		return teamData
	end
	function TeamsStore:RemoveTeam(teamId)
		local _cache = self.cache
		local _teamId = teamId
		_cache[_teamId] = nil
	end
	function TeamsStore:OverrideData(serializedTeamDatas)
		table.clear(self.cache)
		for _, serializedTeamData in serializedTeamDatas do
			local teamData = self:Deserialize(serializedTeamData)
			self:AddTeam(teamData)
		end
	end
	function TeamsStore:Serialize(teamData)
		return teamData
		-- return {
		-- name: Squash.string.ser(teamData.name),
		-- id: Squash.string.ser(teamData.id),
		-- color: Squash.Color3.ser(teamData.color),
		-- };
	end
	function TeamsStore:Deserialize(serializedTeamData)
		return serializedTeamData
		-- return {
		-- name: Squash.string.des(serializedTeamData.name),
		-- id: Squash.string.des(serializedTeamData.id),
		-- color: Squash.Color3.des(serializedTeamData.color),
		-- };
	end
end
return {
	default = TeamsStore,
}
