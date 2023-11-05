-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Formation = TS.import(script, script.Parent, "Formation").default
local Line
do
	local super = Formation
	Line = setmetatable({}, {
		__tostring = function()
			return "Line"
		end,
		__index = super,
	})
	Line.__index = Line
	function Line.new(...)
		local self = setmetatable({}, Line)
		return self:constructor(...) or self
	end
	function Line:constructor()
		super.constructor(self, "NormalAction")
	end
	function Line:GetCFramesInFormation(size, mainCFrame, spread)
		local cframes = {}
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < size) then
					break
				end
				local rowPosition = math.pow(-1, i) * math.ceil(i / 2)
				local offset = CFrame.new(rowPosition * spread, 0, 0)
				local newCFrame = mainCFrame * offset
				table.insert(cframes, newCFrame)
			end
		end
		return cframes
	end
end
return {
	default = Line,
}
