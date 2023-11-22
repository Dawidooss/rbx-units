-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local HttpService = _services.HttpService
local Players = _services.Players
local Workspace = _services.Workspace
local Input = TS.import(script, script.Parent, "Input").default
local Utils = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Utils").default
local ClientGameStore = TS.import(script, script.Parent, "DataStore", "ClientGameStore").default
local Unit = TS.import(script, script.Parent, "Units", "Unit").default
local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer
local gameStore = ClientGameStore:Get()
local unitsStore = gameStore:GetStore("UnitsStore")
local playersStore = gameStore:GetStore("PlayersStore")
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
		local mouseHitResult = Utils:GetMouseHit({ unitsStore.folder })
		local _result = mouseHitResult
		if _result ~= nil then
			_result = _result.Position
		end
		if _result then
			local _object = {
				id = HttpService:GenerateGUID(false),
				type = "Dummy",
				position = mouseHitResult.Position,
			}
			local _left = "playerData"
			local _cache = playersStore.cache
			local _arg0 = tostring(player.UserId)
			_object[_left] = _cache[_arg0]
			local unitData = _object
			unitData.instance = Unit.new(unitData)
			unitsStore:AddUnit(unitData)
			gameStore.replicator:Replicate("create-unit", unitsStore:Serialize(unitData))
		end
	end
end
return {
	default = Admin,
}
