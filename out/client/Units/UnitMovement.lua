-- Compiled with roblox-ts v2.1.1
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local HttpService = _services.HttpService
local RunService = _services.RunService
local MovementVisualisation = TS.import(script, script.Parent, "MovementVisualisation").default
local agentParams = {
	AgentCanJump = false,
	WaypointSpacing = math.huge,
	AgentRadius = 4,
}
local UnitMovement
do
	UnitMovement = setmetatable({}, {
		__tostring = function()
			return "UnitMovement"
		end,
	})
	UnitMovement.__index = UnitMovement
	function UnitMovement.new(...)
		local self = setmetatable({}, UnitMovement)
		return self:constructor(...) or self
	end
	function UnitMovement:constructor(unit)
		self.moving = false
		self.path = {}
		self.moveToTries = 0
		self.unit = unit
		self.visualisation = MovementVisualisation.new(self)
	end
	UnitMovement.Move = TS.async(function(self, path)
		local pathId = HttpService:GenerateGUID(false)
		self.pathId = pathId
		self.path = path
		self.moving = true
		-- this.visualisation.Update();
		while self.moving and (self.pathId == pathId and #self.path > 0) do
			local success = TS.await(self:MoveTo(self.path[1]))
			if not success then
				return nil
			end
			table.remove(self.path, 1)
		end
	end)
	UnitMovement.MoveTo = TS.async(function(self, position)
		self.moving = true
		self.movingTo = position
		print(3)
		local promise = TS.Promise.new(function(resolve, reject)
			-- orientation to position
			local orientation = { CFrame.new(self.unit.model:GetPivot().Position, position):ToOrientation() }
			self.unit.alignOrientation.CFrame = CFrame.Angles(0, orientation[2], 0)
			self.unit.data.targetPosition = position
			self.unit.data.movementStartTick = tick()
			self:TryMoveTo(position, function(success)
				return resolve(success)
			end)
			-- this.unit.MoveTo(waypoint.Position, (success: boolean) => {
			-- if (success) {
			-- this.currentWaypointIndex += 1;
			-- this.MoveToCurrentWaypoint();
			-- } else {
			-- this.Stop(false);
			-- }
			-- });
			-- replicate to server if player is owner of this unit
			-- if (this.unit.data.playerId === Players.LocalPlayer.UserId) {
			-- const buffer = BitBuffer();
			-- buffer.writeString(this.unit.data.id);
			-- buffer.writeVector3(waypoint.Position);
			-- buffer.writeFloat32(tick());
			-- const response = replicator.Replicate("move-unit", buffer.dumpString())[0] as ServerResponse;
			-- if (response.error) {
			-- this.unit.model.PivotTo(currentPosition);
			-- this.Stop(false);
			-- }
			-- }
		end)
		return promise
	end)
	function UnitMovement:TryMoveTo(position, endCallback)
		self.moveToTries += 1
		if self.moveToTries > 10 then
			warn("UNIT MOVE TO: " .. (self.unit.data.id .. " couldn't get to targetPosition due to exceed moveToTries limit"))
			local _result = endCallback
			if _result ~= nil then
				_result(false)
			end
			return nil
		end
		self.unit.model.Humanoid:MoveTo(position)
		wait(1)
		local conn
		conn = RunService.Heartbeat:Connect(function()
			local _position = position
			local _arg0 = self.unit:GetPosition()
			local distance = (_position - _arg0).Magnitude
			if distance <= 2 then
				conn:Disconnect()
				local _result = endCallback
				if _result ~= nil then
					_result(true)
				end
			elseif self.unit.model.Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
				conn:Disconnect()
				self:TryMoveTo(position, endCallback)
			end
		end)
		self.unit.maid:GiveTask(conn)
	end
end
return {
	default = UnitMovement,
}
