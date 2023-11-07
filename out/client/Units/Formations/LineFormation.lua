-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Formation = TS.import(script, script.Parent, "Formation").default
local LineFormation
do
	local super = Formation
	LineFormation = setmetatable({}, {
		__tostring = function()
			return "LineFormation"
		end,
		__index = super,
	})
	LineFormation.__index = LineFormation
	function LineFormation.new(...)
		local self = setmetatable({}, LineFormation)
		return self:constructor(...) or self
	end
	function LineFormation:constructor()
		super.constructor(self, "NormalAction")
	end
	function LineFormation:GetCFramesInFormation(amountOfUnits, mainCFrame, spread)
		local cframes = {}
		local unitsPerRow = 15
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < amountOfUnits) then
					break
				end
				local row = math.floor(i / unitsPerRow)
				local rowPosition = math.pow(-1, i) * math.ceil((i - row * unitsPerRow) / 2)
				local offset = CFrame.new(rowPosition * spread, 0, row * spread)
				local cframe = mainCFrame * offset
				table.insert(cframes, cframe)
			end
		end
		return cframes
	end
end
return {
	default = LineFormation,
}
