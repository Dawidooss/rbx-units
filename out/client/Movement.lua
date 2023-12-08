-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ContextActionService = _services.ContextActionService
local TweenService = _services.TweenService
local UserInputService = _services.UserInputService
local camera = TS.import(script, script.Parent, "Instances").camera
local Movement
do
	Movement = setmetatable({}, {
		__tostring = function()
			return "Movement"
		end,
	})
	Movement.__index = Movement
	function Movement.new(...)
		local self = setmetatable({}, Movement)
		return self:constructor(...) or self
	end
	function Movement:constructor()
		self.shift = false
		self.moveSpeed = 25
		self.zoom = 2
		self.position = Vector2.new()
		self.moveDirection = Vector2.new()
		self.dragging = false
		self.zoomCFrame = Instance.new("CFrameValue")
		self.HandleInput = function(action, state, input)
			local begin = state == Enum.UserInputState.Begin
			if action == "Movement" then
				if input.UserInputType == Enum.UserInputType.MouseWheel then
					self.zoom = math.clamp(self.zoom - input.Position.Z, 1, 5)
					local _fn = TweenService
					local _exp = self.zoomCFrame
					local _exp_1 = TweenInfo.new(0.2, Enum.EasingStyle.Sine)
					local _object = {}
					local _left = "Value"
					local _cFrame = CFrame.new(0, self.zoom * 25, 0)
					local _arg0 = CFrame.Angles(math.rad((5 - self.zoom) * 5), 0, 0)
					_object[_left] = _cFrame * _arg0
					_fn:Create(_exp, _exp_1, _object):Play()
				elseif input.UserInputType == Enum.UserInputType.Keyboard then
					if input.KeyCode == Enum.KeyCode.D then
						self.moveDirection = Vector2.new(if begin then 1 else 0, self.moveDirection.Y)
					elseif input.KeyCode == Enum.KeyCode.A then
						self.moveDirection = Vector2.new(if begin then -1 else 0, self.moveDirection.Y)
					elseif input.KeyCode == Enum.KeyCode.S then
						self.moveDirection = Vector2.new(self.moveDirection.X, if begin then 1 else 0)
					elseif input.KeyCode == Enum.KeyCode.W then
						self.moveDirection = Vector2.new(self.moveDirection.X, if begin then -1 else 0)
					elseif input.KeyCode == Enum.KeyCode.LeftShift then
						self.shift = begin
					end
				end
			end
		end
		Movement.instance = self
		ContextActionService:BindActionAtPriority("Movement", self.HandleInput, false, 100, Enum.KeyCode.A, Enum.KeyCode.D, Enum.KeyCode.W, Enum.KeyCode.S, Enum.KeyCode.F, Enum.KeyCode.LeftShift, Enum.UserInputType.MouseWheel)
	end
	function Movement:Update(deltaTime)
		local mouseDelta = UserInputService:GetMouseDelta()
		if self.dragging then
			local _position = self.position
			local _arg0 = (deltaTime * self.moveSpeed * self.zoom) / 4
			local _arg0_1 = mouseDelta * _arg0
			self.position = _position + _arg0_1
		else
			local _position = self.position
			local _moveDirection = self.moveDirection
			local _arg0 = deltaTime * self.moveSpeed * (if self.shift then 2.5 else 1) * (self.zoom / 2 + 0.5)
			self.position = _position + (_moveDirection * _arg0)
		end
		camera.CameraType = Enum.CameraType.Scriptable
		local _cFrame = CFrame.new(self.position.X, 0, self.position.Y)
		local _value = self.zoomCFrame.Value
		local _arg0 = CFrame.Angles(-math.pi / 2, 0, 0)
		camera.CFrame = _cFrame * _value * _arg0
	end
	function Movement:Get()
		return Movement.instance or Movement.new()
	end
end
return {
	default = Movement,
}
