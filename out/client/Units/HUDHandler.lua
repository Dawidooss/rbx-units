-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local UnitsAction = TS.import(script, script.Parent, "UnitsAction").default
local LineFormation = TS.import(script, script.Parent, "Formations", "LineFormation").default
local SquareFormation = TS.import(script, script.Parent, "Formations", "SquareFormation").default
local CircleFormation = TS.import(script, script.Parent, "Formations", "CircleFormation").default
local GUI = TS.import(script, script.Parent, "GUI").default
local gui = GUI:Get()
local unitsAction = UnitsAction:Get()
local HUDHandler
do
	HUDHandler = setmetatable({}, {
		__tostring = function()
			return "HUDHandler"
		end,
	})
	HUDHandler.__index = HUDHandler
	function HUDHandler.new(...)
		local self = setmetatable({}, HUDHandler)
		return self:constructor(...) or self
	end
	function HUDHandler:constructor()
		HUDHandler.instance = self
		gui.hud.Formations.Line.MouseButton1Click:Connect(function()
			return unitsAction:SetFormation(LineFormation.new())
		end)
		gui.hud.Formations.Square.MouseButton1Click:Connect(function()
			return unitsAction:SetFormation(SquareFormation.new())
		end)
		gui.hud.Formations.Circle.MouseButton1Click:Connect(function()
			return unitsAction:SetFormation(CircleFormation.new())
		end)
	end
	function HUDHandler:Get()
		local _condition = HUDHandler.instance
		if not (_condition ~= 0 and (_condition == _condition and (_condition ~= "" and _condition))) then
			_condition = HUDHandler.new()
		end
		return _condition
	end
end
return {
	default = HUDHandler,
}
