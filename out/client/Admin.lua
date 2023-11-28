-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local HttpService = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").HttpService
local Utils = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Utils").default
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local Input = TS.import(script, script.Parent, "Input").default
local ClientGameStore = TS.import(script, script.Parent, "DataStore", "GameStore").default
local ClientReplicator = TS.import(script, script.Parent, "DataStore", "Replicator").default
local Unit = TS.import(script, script.Parent, "Units", "Unit").default
local input = Input:Get()
local replicator = ClientReplicator:Get()
local gameStore = ClientGameStore:Get()
local unitsStore = gameStore:GetStore("UnitsStore")
local Admin
do
	Admin = setmetatable({}, {
		__tostring = function()
			return "Admin"
		end,
	})
	Admin.__index = Admin
	function Admin.new(...)
		local self = setmetatable({}, Admin)
		return self:constructor(...) or self
	end
	function Admin:constructor()
		Admin.instance = self
		-- let x = false;
		input:Bind(Enum.KeyCode.F, Enum.UserInputState.End, function()
			return self:SpawnUnit()
		end)
		-- input.Bind(Enum.KeyCode.F, Enum.UserInputState.Begin, () => {
		-- x = true;
		-- });
		-- input.Bind(Enum.KeyCode.F, Enum.UserInputState.End, () => {
		-- x = false;
		-- });
		-- spawn(() => {
		-- while (wait(0.05)) {
		-- if (x) {
		-- this.SpawnUnit();
		-- }
		-- }
		-- });
	end
	function Admin:SpawnUnit()
		local mouseHitResult = Utils:GetMouseHit({ unitsStore.folder })
		local _result = mouseHitResult
		if _result ~= nil then
			_result = _result.Position
		end
		if _result then
			local id = HttpService:GenerateGUID(false)
			local name = "Dummy"
			local position = mouseHitResult.Position
			local unit = Unit.new(gameStore, id, name, position)
			unitsStore:Add(unit)
			local queue = ReplicationQueue.new()
			queue:Add("create-unit", function(buffer)
				unitsStore:Serialize(unit, buffer)
			end)
			replicator:Replicate(queue)
		end
	end
	function Admin:Get()
		return Admin.instance or Admin.new()
	end
end
return {
	default = Admin,
}
