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
		self.buffer = BitBuffer()
	end
	function ReplicationQueue:Add(key, writeCallback)
		self.buffer.writeString(key)
		local _result = writeCallback
		if _result ~= nil then
			_result(self.buffer)
		end
	end
	function ReplicationQueue:DumpString()
		return self.buffer.dumpString()
	end
	function ReplicationQueue:Divide(serializedBuffer, chunkCallback)
		local buffer = BitBuffer(serializedBuffer)
		-- last char is "-" so end of
		while buffer.getPointerByte() < buffer.getByteLength() do
			local key = buffer.readString()
			chunkCallback(key, buffer)
		end
	end
end
return {
	default = ReplicationQueue,
}
