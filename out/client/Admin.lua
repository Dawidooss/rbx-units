-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Utils = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "Utils").default
local ReplicationQueue = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "ReplicationQueue").default
local Input = TS.import(script, script.Parent, "Input").default
local ClientReplicator = TS.import(script, script.Parent, "DataStore", "Replicator").default
local Unit = TS.import(script, script.Parent, "Units", "Unit").default
local UnitsStore = TS.import(script, script.Parent, "DataStore", "UnitsStore").default
local player = TS.import(script, script.Parent, "Instances").player
local input = Input:Get()
local replicator = ClientReplicator:Get()
local unitsStore = UnitsStore:Get()
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
		local x = false
		-- input.Bind(Enum.KeyCode.F, Enum.UserInputState.End, () => this.SpawnUnit());
		input:Bind(Enum.KeyCode.F, Enum.UserInputState.Begin, function()
			x = true
		end)
		input:Bind(Enum.KeyCode.F, Enum.UserInputState.End, function()
			x = false
		end)
		spawn(function()
			while { wait(0.05) } do
				if x then
					self:SpawnUnit()
				end
			end
		end)
	end
	function Admin:SpawnUnit()
		local mouseHitResult = Utils:GetMouseHit({ unitsStore.folder })
		local _result = mouseHitResult
		if _result ~= nil then
			_result = _result.Position
		end
		if _result then
			local name = "Dummy"
			local position = mouseHitResult.Position
			local unitId = table.remove(unitsStore.freeIds, 1)
			if not (unitId ~= 0 and (unitId == unitId and unitId)) then
				return nil
			end
			local unit = Unit.new(unitId, {
				id = unitId,
				position = position,
				name = name,
				playerId = player.UserId,
				path = {},
				health = 100,
			})
			unitsStore:Add(unit)
			local queue = ReplicationQueue.new()
			queue:Add("create-unit", unitsStore.serializer.Ser(unit))
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
