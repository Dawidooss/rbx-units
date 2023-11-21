-- Compiled with roblox-ts v2.2.0
local ServerGameStore
do
	ServerGameStore = setmetatable({}, {
		__tostring = function()
			return "ServerGameStore"
		end,
	})
	ServerGameStore.__index = ServerGameStore
	function ServerGameStore.new(...)
		local self = setmetatable({}, ServerGameStore)
		return self:constructor(...) or self
	end
	function ServerGameStore:constructor()
		if ServerGameStore.instance then
			return nil
		end
		ServerGameStore.instance = self
	end
	function ServerGameStore:Get()
		return ServerGameStore.instance or ServerGameStore.new()
	end
end
return {
	default = ServerGameStore,
}
