-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Squash = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "squash", "src")
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
		self.name = script.Name
		self.teams = {}
	end
	function TeamsStore:AddTeam(teamData)
		local teamId = teamData.id
		local _teams = self.teams
		local _teamData = teamData
		_teams[teamId] = _teamData
	end
	function TeamsStore:OverrideData(serializedTeamDatas)
		table.clear(self.teams)
		for _, serializedTeamData in serializedTeamDatas do
			local teamData = TeamsStore:DeserializeTeamData(serializedTeamData)
			self:AddTeam(teamData)
		end
	end
	function TeamsStore:SerializeTeamData(teamData)
		return {
			name = Squash.string.ser(teamData.name),
			id = Squash.string.ser(teamData.id),
			color = Squash.Color3.ser(teamData.color),
		}
	end
	function TeamsStore:DeserializeTeamData(serializedTeamData)
		return {
			name = Squash.string.des(serializedTeamData.name),
			id = Squash.string.des(serializedTeamData.id),
			color = Squash.Color3.des(serializedTeamData.color),
		}
	end
end
return {
	default = TeamsStore,
}
