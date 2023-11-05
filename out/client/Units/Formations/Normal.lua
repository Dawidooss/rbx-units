-- Compiled with roblox-ts v2.2.0
local Normal
do
	Normal = setmetatable({}, {
		__tostring = function()
			return "Normal"
		end,
	})
	Normal.__index = Normal
	function Normal.new(...)
		local self = setmetatable({}, Normal)
		return self:constructor(...) or self
	end
	function Normal:constructor()
	end
	function Normal:GetCFramesInFormation(size, mainCFrame, spread)
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
				local row = math.floor(i / 10)
				local rowPosition = math.pow(-1, i) * math.ceil((i - row * 10) / 2)
				local offset = CFrame.new(rowPosition * spread, 0, row * spread)
				local cframe = mainCFrame * offset
				table.insert(cframes, cframe)
			end
		end
		return cframes
	end
end
return {
	default = Normal,
}
