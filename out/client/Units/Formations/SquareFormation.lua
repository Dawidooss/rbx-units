-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Formation = TS.import(script, script.Parent, "Formation").default
local SquareFormation
do
	local super = Formation
	SquareFormation = setmetatable({}, {
		__tostring = function()
			return "SquareFormation"
		end,
		__index = super,
	})
	SquareFormation.__index = SquareFormation
	function SquareFormation.new(...)
		local self = setmetatable({}, SquareFormation)
		return self:constructor(...) or self
	end
	function SquareFormation:constructor()
		super.constructor(self, "NormalAction")
	end
	function SquareFormation:GetCFramesInFormation(unitsAmount, mainCFrame, spread)
		local cframes = {}
		local unitsPerRow = math.ceil(math.sqrt(unitsAmount))
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < unitsAmount) then
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
	default = SquareFormation,
}
