-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ClientReplicator = TS.import(script, script.Parent, "Replicator").default
local GameStoreBase = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "DataStore", "Stores", "GameStoreBase").default
local TeamsStore = TS.import(script, script.Parent, "TeamsStore").default
local PlayersStore = TS.import(script, script.Parent, "PlayersStore").default
local UnitsStore = TS.import(script, script.Parent, "UnitsStore").default
local replicator = ClientReplicator:Get()
local GameStore
do
	local super = GameStoreBase
	GameStore = setmetatable({}, {
		__tostring = function()
			return "GameStore"
		end,
		__index = super,
	})
	GameStore.__index = GameStore
	function GameStore.new(...)
		local self = setmetatable({}, GameStore)
		return self:constructor(...) or self
	end
	function GameStore:constructor()
		super.constructor(self)
		if GameStore.instance then
			return nil
		end
		GameStore.instance = self
		self:AddStore(TeamsStore.new(self))
		self:AddStore(PlayersStore.new(self))
		self:AddStore(UnitsStore.new(self))
		self:Init()
	end
	GameStore.Init = TS.async(function(self)
		local defaultData = TS.await(replicator:FetchAll():catch(function()
			warn("couldn't not fetch data")
			-- TODO: exit game?
		end))
		if not defaultData then
			return nil
		end
		self:OverrideAll(defaultData)
	end)
	function GameStore:OverrideAll(buffer)
		while buffer.getPointerByte() < buffer.getByteLength() do
			local storeName = buffer.readString()
			local _result = self:GetStore(storeName)
			if _result ~= nil then
				_result:OverrideData(buffer)
			end
		end
		replicator.replicationEnabled = true
	end
	function GameStore:Get()
		return GameStore.instance or GameStore.new()
	end
end
return {
	default = GameStore,
}
