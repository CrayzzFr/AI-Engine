local PathFindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RNS = game:GetService("RunService")
local TS = game:GetService("TweenService")

local DetectionService = require(script.Parent.Parent.Services.DetectionService)

local Config = require(script.Parent.Parent.Services.Data.Config)
local Pathfinding = require(script.Parent.Parent.Services.Pathfinding)

local TI = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

local PatrolState = {}
PatrolState.__index = PatrolState

local Smoothing = require(script.Parent.Parent.Services.Extra.Smoothing)

function PatrolState.new(NPC, FSM, Waypoints)
	local self = setmetatable({}, PatrolState)
	self.NPC = NPC
	self.ParentFSM = FSM
	self.State_Anim = nil
	self.Waypoints = Waypoints
	self.FinishedMoving = false
	self.MovingConn = nil
	self.Current_Index = 0
	self.Range = 50
	self.Target = nil
	self.Path = nil
	
	return self
end

function PatrolState:_MoveToNextWaypoint()
	if self.ParentFSM:GetState() == "Chase" then return end
	
	if self._TargetLastPos and self.Target and self.Target.Humanoid.Health > 0 then
		print(self._TargetLastPos)
		
		local NewPath = Pathfinding.new(self.NPC, {AgentRadius = 3.5, AgentCanClimb = true}, "Patrol")
		
		NewPath:WalkTo(self.TargetLastPos, false)
		
		NewPath.OnTargetReached:Connect(function()
			if self.Path then
				self.Path:Destroy("TargetReached")
				self.Path = nil
			end
			
			self._TargetLastPos = nil
	
			self:_MoveToNextWaypoint()
		end)
	else
		if self.Current_Index >= #self.Waypoints:GetChildren() then
			self.Current_Index = 1
		else
			self.Current_Index += 1
		end

		local Waypoint = self.Waypoints:GetChildren()[self.Current_Index]

		if self._TargetLastPos then

		end

		local NewPath = Pathfinding.new(self.NPC, {AgentRadius = 3.5}, "Patrol")

		Waypoint.Color = Color3.fromRGB(255,0,0)

		self.Path = NewPath

		NewPath:WalkTo(Waypoint, true, "Patrol", false)

		NewPath.OnTargetReached:Connect(function()
			workspace[self.NPC:GetAttribute("MonsterId")]:Destroy()
			Waypoint.Color = Color3.fromRGB(255, 255, 255)
			NewPath:Destroy("TargetReached")
			self.Path = nil
			self:_MoveToNextWaypoint()
		end)

		NewPath.PathFailed:Connect(function()
			Waypoint.Color = Color3.fromRGB(255,255,255)
			self:_MoveToNextWaypoint()
		end)

		NewPath.Destroyed:Connect(function(cause)
			if cause == "TargetReached" then
				Waypoint.Color = Color3.fromRGB(255,255,255)
			else
				Waypoint.Color = Color3.fromRGB(255,255,255)

				if NewPath.PathVisualizers then
					workspace[self.NPC:GetAttribute("MonsterId")]:Destroy()
				end
			end
		end)

		NewPath.WaypointReached:Connect(function(currWaypoint, nextWP)
			if nextWP == nil then return end

			--Smoothing:SmoothlyRotate(self.NPC.HumanoidRootPart, nextWP)
		end)
	end
end


function PatrolState:Enter(Info)
	local Animator = self.NPC.Humanoid:FindFirstChild("Animator")
	local Animation = self.NPC.Animations.Patrol
	
	self.NPC.Humanoid.WalkSpeed = Config.Speeds.WalkSpeed
	
	self.State_Anim = Animator:LoadAnimation(Animation)
	self.State_Anim:Play()
	
	if self.ParentFSM:GetPreviousState() == "Chase" then
		self.TargetLastPos = Info.lastPos
		self.Target = Info.lastTarget
	end
	
	
	
	self:_MoveToNextWaypoint()
end


function PatrolState:Update(Info)
	local Valid, PlrFound = DetectionService.Detect(self.NPC.HumanoidRootPart, "Less", Config.Ranges)
	
	if Valid and PlrFound:GetAttribute("Status") == 1 and PlrFound.Humanoid.Health > 0 then
		self.Path:Destroy()
		self.ParentFSM:ChangeState("Chase", {PlrFound = PlrFound})
		game.ReplicatedStorage.Remotes.ChaseStart:FireClient(game.Players:GetPlayerFromCharacter(PlrFound), self.NPC.Name)
		return
	end
end

function PatrolState:Exit()
	if self.State_Anim.IsPlaying then
		self.State_Anim:Stop()
	end
end


return PatrolState
