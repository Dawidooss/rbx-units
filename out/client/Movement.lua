-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ContextActionService = _services.ContextActionService
local Players = _services.Players
local TweenService = _services.TweenService
local UserInputService = _services.UserInputService
local Workspace = _services.Workspace
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
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
	end
	function Movement:Init()
		Movement.zoomValue.Value = 1
		ContextActionService:BindActionAtPriority("movement", self.HandleInput, false, 100, Enum.KeyCode.A, Enum.KeyCode.D, Enum.KeyCode.W, Enum.KeyCode.S, Enum.KeyCode.F, Enum.KeyCode.LeftShift, Enum.UserInputType.MouseWheel, Enum.UserInputType.MouseButton2)
	end
	function Movement:Update(deltaTime)
		local mouseDelta = UserInputService:GetMouseDelta()
		if Movement.dragging then
			local _position = Movement.position
			local _arg0 = (deltaTime * Movement.moveSpeed * Movement.zoom) / 4
			local _arg0_1 = mouseDelta * _arg0
			Movement.position = _position + _arg0_1
		else
			local _position = Movement.position
			local _moveDirection = Movement.moveDirection
			local _arg0 = deltaTime * Movement.moveSpeed * (if Movement.shift then 2.5 else 1) * (Movement.zoom / 2 + 0.5)
			Movement.position = _position + (_moveDirection * _arg0)
		end
		camera.CameraType = Enum.CameraType.Scriptable
		local _cFrame = CFrame.new(Movement.position.X, Movement.zoomValue.Value * 25, Movement.position.Y)
		local _arg0 = CFrame.Angles(-math.pi / 2, 0, 0)
		camera.CFrame = _cFrame * _arg0
	end
	Movement.shift = false
	Movement.moveSpeed = 25
	Movement.zoom = 2
	Movement.position = Vector2.new()
	Movement.moveDirection = Vector2.new()
	Movement.dragging = false
	Movement.zoomValue = Instance.new("NumberValue")
	Movement.HandleInput = function(action, state, input)
		local begin = state == Enum.UserInputState.Begin
		if action == "movement" then
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				Movement.zoom = math.clamp(Movement.zoom - input.Position.Z, 1, 5)
				TweenService:Create(Movement.zoomValue, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
					Value = Movement.zoom,
				}):Play()
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				Movement.dragging = begin
				UserInputService.MouseBehavior = if begin then Enum.MouseBehavior.LockCurrentPosition else Enum.MouseBehavior.Default
			elseif input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.D then
					Movement.moveDirection = Vector2.new(if begin then 1 else 0, Movement.moveDirection.Y)
				elseif input.KeyCode == Enum.KeyCode.A then
					Movement.moveDirection = Vector2.new(if begin then -1 else 0, Movement.moveDirection.Y)
				elseif input.KeyCode == Enum.KeyCode.S then
					Movement.moveDirection = Vector2.new(Movement.moveDirection.X, if begin then 1 else 0)
				elseif input.KeyCode == Enum.KeyCode.W then
					Movement.moveDirection = Vector2.new(Movement.moveDirection.X, if begin then -1 else 0)
				elseif input.KeyCode == Enum.KeyCode.LeftShift then
					Movement.shift = begin
				end
			end
		end
	end
end
return {
	default = Movement,
}
