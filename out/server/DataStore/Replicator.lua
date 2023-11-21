-- Compiled with roblox-ts v2.2.0
local Replicator
do
	Replicator = setmetatable({}, {
		__tostring = function()
			return "Replicator"
		end,
	})
	Replicator.__index = Replicator
	function Replicator.new(...)
		local self = setmetatable({}, Replicator)
		return self:constructor(...) or self
	end
	function Replicator:constructor(gameStore)
		self.gameStore = gameStore
	end
end
return {
	default = Replicator,
}
