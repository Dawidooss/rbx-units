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
					print(key, data[key])
					method.Ser(data[key], buffer)
				end
				return buffer
			end
			self.methods = methods
		end
		function Serializer:ToSelected(keys)
			local methods = {}
			for _, key in keys do
				local _methods = self.methods
				local _arg0 = function(v)
					return v[1] == key
				end
				-- ▼ ReadonlyArray.find ▼
				local _result
				for _i, _v in _methods do
					if _arg0(_v, _i - 1, _methods) == true then
						_result = _v
						break
					end
				end
				-- ▲ ReadonlyArray.find ▲
				local method = _result
				if method then
					table.insert(methods, method)
				end
			end
			return Serializer.new(methods)
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
				buffer.writeUnsigned(xBits, data.X)
				buffer.writeUnsigned(yBits, data.Y)
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
					buffer.writeBits(1)
					method.Ser(value, buffer)
				end
				buffer.writeBits(0)
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
					buffer.writeBits(1)
					keyMethod.Ser(key, buffer)
					valueMethod.Ser(value, buffer)
				end
				buffer.writeBits(0)
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
