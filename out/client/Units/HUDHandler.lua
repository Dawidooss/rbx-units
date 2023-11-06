-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local UnitsAction = TS.import(script, script.Parent, "UnitsAction").default
local LineFormation = TS.import(script, script.Parent, "Formations", "LineFormation").default
local SquareFormation = TS.import(script, script.Parent, "Formations", "SquareFormation").default
local CircleFormation = TS.import(script, script.Parent, "Formations", "CircleFormation").default
local HUD = TS.import(script, script.Parent, "HUD").default
local HUDHandler
do
	HUDHandler = {}
	function HUDHandler:constructor()
	end
	function HUDHandler:Init()
		HUD.gui.Formations.Line.MouseButton1Click:Connect(function()
			return UnitsAction:SetFormation(LineFormation.new())
		end)
		HUD.gui.Formations.Square.MouseButton1Click:Connect(function()
			return UnitsAction:SetFormation(SquareFormation.new())
		end)
		HUD.gui.Formations.Circle.MouseButton1Click:Connect(function()
			return UnitsAction:SetFormation(CircleFormation.new())
		end)
	end
end
return {
	default = HUDHandler,
}
