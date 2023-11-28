-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local player = TS.import(script, script.Parent.Parent, "Instances").player
local playerGui = player:WaitForChild("PlayerGui")
local GUI
do
	GUI = setmetatable({}, {
		__tostring = function()
			return "GUI"
		end,
	})
	GUI.__index = GUI
	function GUI.new(...)
		local self = setmetatable({}, GUI)
		return self:constructor(...) or self
	end
	function GUI:constructor()
		GUI.instance = self
		self.hud = playerGui:WaitForChild("HUD")
	end
	function GUI:Get()
		return GUI.instance or GUI.new()
	end
end
return {
	default = GUI,
}
