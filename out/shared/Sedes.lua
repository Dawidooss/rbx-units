-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local BitBuffer = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "bitbuffer", "src", "roblox")
-- Sedes = Serdes = Serializer-Deserializer
local Sedes = {}
do
	local _container = Sedes
	local Serializer
	do
		Serializer = setmetatable({}, {
			__tostring = function()
				return "Serializer"
			end,
		})
		Serializer.__index = Serializer
		function Serializer.new(...)
			local self = setmetatable({}, Serializer)
			return self:constructor(...) or self
		end
		function Serializer:constructor(methods)
			self.Des = function(buffer)
				local data = {}
				for _, _binding in self.methods do
					local key = _binding[1]
					local method = _binding[2]
					data[key] = method.Des(buffer)
				end
				return data
			end
			self.Ser = function(data, buffer)
				local _condition = buffer
				if not buffer then
					_condition = BitBuffer()
				end
				buffer = _condition
				for _, _binding in self.methods do
					local key = _binding[1]
					local method = _binding[2]
					method.Ser(data[key], buffer)
				end
				return buffer
			end
			self.methods = methods
		end
		function Serializer:SerSelected(data, selected, buffer)
			local _condition = buffer
			if not buffer then
				_condition = BitBuffer()
			end
			buffer = _condition
			for _, _binding in self.methods do
				local key = _binding[1]
				local method = _binding[2]
				if selected[key] ~= nil then
					method.Ser(data[key], buffer)
				end
			end
			return buffer
		end
	end
	_container.Serializer = Serializer
	local ToString = function()
		return {
			Des = function(buffer)
				return buffer.readString()
			end,
			Ser = function(data, buffer)
				buffer.writeString(data)
				return buffer
			end,
		}
	end
	_container.ToString = ToString
	local ToUnsigned = function(bits)
		return {
			Des = function(buffer)
				return buffer.readUnsigned(bits)
			end,
			Ser = function(data, buffer)
				buffer.writeUnsigned(bits, data)
				return buffer
			end,
		}
	end
	_container.ToUnsigned = ToUnsigned
	local ToSigned = function(bits)
		return {
			Des = function(buffer)
				return buffer.readSigned(bits)
			end,
			Ser = function(data, buffer)
				buffer.writeSigned(bits, data)
				return buffer
			end,
		}
	end
	_container.ToSigned = ToSigned
	local ToColor3 = function()
		return {
			Des = function(buffer)
				return buffer.readColor3()
			end,
			Ser = function(data, buffer)
				buffer.writeColor3(data)
				return buffer
			end,
		}
	end
	_container.ToColor3 = ToColor3
	local ToUnsignedVector2 = function(xBits, yBits)
		return {
			Des = function(buffer)
				return Vector2.new(buffer.readUnsigned(xBits), buffer.readUnsigned(yBits))
			end,
			Ser = function(data, buffer)
				buffer.writeUnsigned(10, data.X)
				buffer.writeUnsigned(10, data.Y)
				return buffer
			end,
		}
	end
	_container.ToUnsignedVector2 = ToUnsignedVector2
	local ToVector2 = function()
		return {
			Des = function(buffer)
				return buffer.readVector2()
			end,
			Ser = function(data, buffer)
				buffer.writeVector2(data)
				return buffer
			end,
		}
	end
	_container.ToVector2 = ToVector2
	local ToArray = function(method)
		return {
			Des = function(buffer)
				local arr = {}
				while buffer.readBits(1)[1] == 1 do
					local value = method.Des(buffer)
					table.insert(arr, value)
				end
				return arr
			end,
			Ser = function(data, buffer)
				for _, value in data do
					method.Ser(value, buffer)
				end
				return buffer
			end,
		}
	end
	_container.ToArray = ToArray
	local ToDict = function(keyMethod, valueMethod)
		return {
			Des = function(buffer)
				local dict = {}
				while buffer.readBits(1)[1] == 1 do
					local key = keyMethod.Des(buffer)
					local value = valueMethod.Des(buffer)
					dict[key] = value
				end
				return dict
			end,
			Ser = function(data, buffer)
				for key, value in data do
					keyMethod.Ser(key, buffer)
					valueMethod.Ser(value, buffer)
				end
				return buffer
			end,
		}
	end
	_container.ToDict = ToDict
	local ToEmpty = function()
		return {
			Des = function(buffer)
				return buffer
			end,
			Ser = function(data, buffer)
				return buffer
			end,
		}
	end
	_container.ToEmpty = ToEmpty
end
return {
	Sedes = Sedes,
}
