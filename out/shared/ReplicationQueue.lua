-- Compiled with roblox-ts v2.2.0
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
		self.buffer = BitBuffer()
	end
	function ReplicationQueue:Add(key, writeCallback)
		self.buffer.writeString(key)
		writeCallback(self.buffer)
	end
	function ReplicationQueue:DumpString()
		return self.buffer.dumpString()
	end
	function ReplicationQueue:Divide(serializedBuffer, chunkCallback)
		local buffer = BitBuffer(serializedBuffer)
		while not buffer.isFinished() do
			local key = buffer.readString()
			chunkCallback(key, buffer)
		end
	end
end
return {
	default = ReplicationQueue,
}
