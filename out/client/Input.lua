-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local UserInputService = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").UserInputService
local KeyBinding
local Input
do
	Input = setmetatable({}, {
		__tostring = function()
			return "Input"
		end,
	})
	Input.__index = Input
	function Input.new(...)
		local self = setmetatable({}, Input)
		return self:constructor(...) or self
	end
	function Input:constructor()
		self.holdingButtons = {}
		self.binds = {}
		self.HandleInput = function(input)
			local holding = input.UserInputState == Enum.UserInputState.Begin
			local _holdingButtons = self.holdingButtons
			local _keyCode = input.KeyCode
			_holdingButtons[_keyCode] = holding
			local _binds = self.binds
			local _arg0 = function(callback, keyBinding)
				if (input.KeyCode == keyBinding.button or input.UserInputType == keyBinding.button) and input.UserInputState == keyBinding.state then
					callback()
				end
			end
			for _k, _v in _binds do
				_arg0(_v, _k, _binds)
			end
		end
		Input.instance = self
		UserInputService.InputBegan:Connect(function(input, processed)
			self.HandleInput(input)
		end)
		UserInputService.InputEnded:Connect(function(input, processed)
			self.HandleInput(input)
		end)
	end
	function Input:IsButtonHolding(button)
		local _holdingButtons = self.holdingButtons
		local _button = button
		local _condition = _holdingButtons[_button]
		if not _condition then
			_condition = false
		end
		return _condition
	end
	function Input:Bind(button, state, callback)
		local _binds = self.binds
		local _keyBinding = KeyBinding.new(button, state)
		local _callback = callback
		_binds[_keyBinding] = _callback
	end
	function Input:Get()
		return Input.instance or Input.new()
	end
end
do
	KeyBinding = setmetatable({}, {
		__tostring = function()
			return "KeyBinding"
		end,
	})
	KeyBinding.__index = KeyBinding
	function KeyBinding.new(...)
		local self = setmetatable({}, KeyBinding)
		return self:constructor(...) or self
	end
	function KeyBinding:constructor(button, state)
		self.button = button
		self.state = state
	end
end
return {
	default = Input,
	KeyBinding = KeyBinding,
}
