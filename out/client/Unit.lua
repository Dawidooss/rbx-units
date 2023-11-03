-- Compiled with roblox-ts v2.1.1
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
	function Unit:constructor(id, unitName, position)
		self.selected = false
		self.selectionRadius = 1.5
		self.id = id
		self.position = position
		self.unitName = unitName
		self.model = ReplicatedFirst.Units[unitName]:Clone()
		self.model.Name = self.id
		self:UpdatePosition()
	end
	function Unit:Select(state)
		if self.selected == state then
			return nil
		end
		if state then
			local selectionCircle = ReplicatedFirst:FindFirstChild("SelectionCircle"):Clone()
			selectionCircle.Size = Vector3.new(selectionCircle.Size.X, self.selectionRadius * 2, self.selectionRadius * 2)
			local _fn = selectionCircle
			local _exp = self.model:GetPivot()
			local _arg0 = CFrame.Angles(0, 0, math.pi / 2)
			_fn:PivotTo(_exp * _arg0)
			local weld = Instance.new("WeldConstraint", selectionCircle)
			weld.Part0 = selectionCircle
			weld.Part1 = self.model.HumanoidRootPart
			selectionCircle.Parent = self.model
		else
			local _result = self.model:FindFirstChild("SelectionCircle")
			if _result ~= nil then
				_result:Destroy()
			end
		end
		self.selected = state
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
