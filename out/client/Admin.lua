-- Compiled with roblox-ts v2.2.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Workspace = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Workspace
local UnitsManager = TS.import(script, script.Parent, "Units", "UnitsManager").default
local Input = TS.import(script, script.Parent, "Input").default
local Utils = TS.import(script, script.Parent, "Utils").default
local Network = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Network")
local Squash = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "squash", "src")
local camera = Workspace.CurrentCamera
local Admin
do
	Admin = {}
	function Admin:constructor()
	end
	function Admin:Init()
		Input:Bind(Enum.KeyCode.F, Enum.UserInputState.End, function()
			return self:SpawnUnit()
		end)
	end
	function Admin:SpawnUnit()
		local mouseHitResult = Utils:GetMouseHit({ UnitsManager.cache })
		local _result = mouseHitResult
		if _result ~= nil then
			_result = _result.Position
		end
		if _result then
			local unitType = Squash.string.ser("Dummy")
			local position = Squash.Vector3.ser(mouseHitResult.Position)
			Network:FireServer("createUnit", unitType, position)
		end
	end
end
return {
	default = Admin,
}
