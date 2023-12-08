-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
local ReplicationQueue
do
	ReplicationQueue = setmetatable({}, {
		__tostring = function()
			return "ReplicationQueue"
		end,
	})
	ReplicationQueue.__index = ReplicationQueue
	function ReplicationQueue.new(...)
		local self = setmetatable({}, ReplicationQueue)
		return self:constructor(...) or self
	end
	function ReplicationQueue:constructor()
		self.queue = {}
	end
	function ReplicationQueue:Add(key, writeCallback)
		local buffer = BitBuffer()
		buffer.writeString(key)
		if writeCallback then
			writeCallback(buffer)
		end
		table.insert(self.queue, buffer)
	end
	function ReplicationQueue:Dump()
		local dump = {}
		for _, buffer in self.queue do
			local _arg0 = buffer.dumpString()
			table.insert(dump, _arg0)
		end
		return dump
	end
end
return {
	default = ReplicationQueue,
}
