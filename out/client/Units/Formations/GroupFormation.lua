-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Workspace = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Workspace
local Formation = TS.import(script, script.Parent, "Formation").default
local camera = Workspace.CurrentCamera
local GroupFormation
do
	local super = Formation
	GroupFormation = setmetatable({}, {
		__tostring = function()
			return "GroupFormation"
		end,
		__index = super,
	})
	GroupFormation.__index = GroupFormation
	function GroupFormation.new(...)
		local self = setmetatable({}, GroupFormation)
		return self:constructor(...) or self
	end
	function GroupFormation:constructor(group)
		super.constructor(self, "NormalAction")
		self.group = group
	end
	function GroupFormation:GetCFramesInFormation(units, mainCFrame, spread)
		local cframes = {}
		for unit, offset in self.group.offsets do
			local _arg0 = mainCFrame * offset
			table.insert(cframes, _arg0)
		end
		return cframes
	end
	function GroupFormation:GetSpreadLimits(amountOfUnits)
		return { 0, 0 }
	end
	function GroupFormation:MatchUnitsToCFrames(units, cframes, mainCFrame)
		local map = {}
		for unit in units do
			local _mainCFrame = mainCFrame
			map[unit] = _mainCFrame
		end
		return map
	end
end
return {
	default = GroupFormation,
}
