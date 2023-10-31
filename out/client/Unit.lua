-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ReplicatedFirst = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ReplicatedFirst
local UnitData
do
	UnitData = setmetatable({}, {
		__tostring = function()
			return "UnitData"
		end,
	})
	UnitData.__index = UnitData
	function UnitData.new(...)
		local self = setmetatable({}, UnitData)
		return self:constructor(...) or self
	end
	function UnitData:constructor()
	end
end
local Unit
do
	Unit = setmetatable({}, {
		__tostring = function()
			return "Unit"
		end,
	})
	Unit.__index = Unit
	function Unit.new(...)
		local self = setmetatable({}, Unit)
		return self:constructor(...) or self
	end
	function Unit:constructor(unitId, unitName, position)
		self.unitId = unitId
		self.position = position
		self.unitName = unitName
		self.model = ReplicatedFirst.Units[unitName]:Clone()
		self:UpdatePosition()
	end
	function Unit:UpdatePosition()
		self.model:PivotTo(CFrame.new(self.position))
	end
	function Unit:Destroy()
	end
end
return {
	UnitData = UnitData,
	default = Unit,
}
