local Path = {}
Path.__index = Path

local Signal = require(script.Parent.Parent.Services.Extra.Signal)

local PFS = game:GetService("PathfindingService")
local TS = game:GetService("TweenService")

local TI = TweenInfo.new(0.5 , Enum.EasingStyle.Elastic, Enum.EasingDirection.In, 0, true)

local DebugVisualizer = require(script.Parent.Parent.Services.Extra.Debug)

--@param AgentConfig : Optional Argments for PathfindingAgent

export type Signal = typeof(Signal.new())

export type Path = {
	OnTargetReached : Signal,
	OnPathCanceled : Signal,
	PathFailed : Signal,
	WaypointReached : Signal,
	NPC : Model,
	PathConfig : {},
	Path : Path,
}

function Path.new(NPC, AgentConfig, PathType)
	local self = setmetatable({}, Path)
	self.OnTargetReached = Signal.new()
	self.OnPathCanceled = Signal.new()
	self.PathFailed = Signal.new()
	self.WaypointReached = Signal.new()
	self.Destroyed = Signal.new()
	self.NPC = NPC
	self.Path = nil
	self.Type = PathType
	self.PathVisualizers = false
	
	if AgentConfig  then
		self.PathConfig = AgentConfig
	end
	
	return self
end

function Path:ModifyAsync(Params)
	self.PathConfig = Params
end

function Path:Destroy(Cause)
	self.Destroyed:Fire(Cause)
	self.OnTargetReached:DisconnectAll()
	self.OnPathCanceled:DisconnectAll()
	self.PathFailed:DisconnectAll()
	self.WaypointReached:DisconnectAll()
	self.Destroyed:DisconnectAll()
	self.Path = nil
end

function Path:WalkTo(Target, DebuggingEnabled, from)
	if self.Type == "Patrol" then

		task.spawn(function()
			
			if self.PathConfig then
				self.Path = PFS:CreatePath(self.PathConfig)
			else
				self.Path = PFS:CreatePath()
			end
			
			if typeof(Target) == "Vector3" then
				self.Path:ComputeAsync(self.NPC.HumanoidRootPart.Position, Target)
			else
				self.Path:ComputeAsync(self.NPC.HumanoidRootPart.Position, Target.Position)
			end


			if self.Path == nil then return end

			if self.Path.Status == Enum.PathStatus.Success then
				if DebuggingEnabled then
					DebugVisualizer(self.Path:GetWaypoints(), self.NPC, "Ball")
					self.PathVisualizers = true
				end

				local Waypoints = self.Path:GetWaypoints()
				
				local Defined = nil
				
				if typeof(Target) == "Vector3" then
					Defined = Target
				else
					Defined = Target.Position
				end

				for i, waypoint in ipairs(Waypoints) do
					if self.Path == nil then self.OnPathCanceled:Fire() break end

					if i == #self.Path:GetWaypoints() or (Defined - self.NPC.HumanoidRootPart.Position).Magnitude < 3 then
						self.OnTargetReached:Fire()
						break
					elseif Target == nil then
						self.OnPathCanceled:Fire()
						break
					else
						self.NPC.Humanoid:MoveTo(waypoint.Position)
						self.NPC.Humanoid.MoveToFinished:Wait()
						self.WaypointReached:Fire(waypoint, Waypoints[i + 1])
					end
				end
			else
				self.PathFailed:Fire()
			end
		end)
	elseif self.Type == "Follow" then
		task.spawn(function()
			local DefinedVector = nil
			
			if typeof(Target) == "Vector3" then
				DefinedVector = Target
			else
				DefinedVector = Target.Position
			end
			
			if self.PathConfig then
				self.Path = PFS:CreatePath(self.PathConfig)
			else
				self.Path = PFS:CreatePath()
			end
			
			self.Path:ComputeAsync(self.NPC.HumanoidRootPart.Position, DefinedVector)
			
			if self.Path == nil then return end
			
			if self.Path.Status == Enum.PathStatus.Success then
				if DebuggingEnabled then
					DebugVisualizer(self.Path:GetWaypoints(), self.NPC, "Ball")
					self.PathVisualizers = true
				end

				local Waypoints = self.Path:GetWaypoints()

				local TargetWaypoint = Waypoints[3]

				if TargetWaypoint then
					self.NPC.Humanoid:MoveTo(TargetWaypoint.Position)
					self.NPC.Humanoid.MoveToFinished:Wait()
				end
			end
		end)
	end
end
