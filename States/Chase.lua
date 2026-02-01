local ChaseState = {}
ChaseState.__index = ChaseState

local PathFindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RNS = game:GetService("RunService")
local TS = game:GetService("TweenService")

local DetectionService = require(script.Parent.Parent.Services.DetectionService)
local Config = require(script.Parent.Parent.Services.Data.Config)

local Path = require(script.Parent.Parent.Services.Pathfinding)

function ChaseState.new(NPC, FSM)
	local self = setmetatable({}, ChaseState)
	self.NPC = NPC
	self.ParentFSM = FSM
	self.State_Anim = nil
	self.Target = nil
	self.ParentFSM = FSM
	self.Initialized = false
	self.Path = nil
	self._LastPathEtime = 0
	
	return self
end

function ChaseState:_MoveToTarget()
	if self.Target == nil then 
		self.ParentFSM:ChangeState("Patrol")
		return 
	end
	
	if self._LastPathEtime == 0 then
		self._LastPathEtime = tick()	
		self.Path:WalkTo(self.Target.HumanoidRootPart, false)
	elseif tick() - self._LastPathEtime > 0.05 then
		self._LastPathEtime = tick()	

		self.Path:WalkTo(self.Target.HumanoidRootPart, false)
	end
end


function ChaseState:_CanJumpscareTarget()
	local Distance = (self.NPC.HumanoidRootPart.Position - self.Target.HumanoidRootPart.Position).Magnitude
	
	return Distance < Config.Ranges.AttackRange
end

function ChaseState:Enter(Info)
	local Animator = self.NPC.Humanoid:FindFirstChild("Animator")
	local Animation = self.NPC.Animations.Chase
	
	self.NPC.Humanoid.WalkSpeed = Config.Speeds.RunSpeed
	
	self.State_Anim = Animator:LoadAnimation(Animation)
	self.State_Anim:Play()
	self.Target = Info.PlrFound
	self.Path = Path.new(self.NPC, {AgentRadius = 3.5, AgentCanClimb = true}, "Follow")
end

function ChaseState:Update(Info)
	if self.Target.Humanoid.Health <= 0 then self.ParentFSM:ChangeState("Patrol") end
	
	local valid, plrfound = DetectionService.Detect(self.NPC.HumanoidRootPart, "Greater", Config.Ranges)
	
	if valid then
		
		game.ReplicatedStorage.Remotes.ChaseEnd:FireClient(game.Players:GetPlayerFromCharacter(self.Target), self.NPC.Name)
		self.ParentFSM:ChangeState("Patrol", {lastPos = self.Target.HumanoidRootPart.Position, lastTarget = self.Target})
		return
	elseif self:_CanJumpscareTarget() then
		game.ReplicatedStorage.Remotes.ChaseEnd:FireClient(game.Players:GetPlayerFromCharacter(self.Target), self.NPC.Name)
		self.ParentFSM:ChangeState("Jumpscare", {Target = self.Target})
		return
	else
		self:_MoveToTarget()
	end
end

function ChaseState:Exit()
	if self.State_Anim.IsPlaying then
		self.State_Anim:Stop()
		self.State_Anim = nil
	end
	
	self.Path:Destroy()
	self.Path = nil
	self.Target = nil
end

return ChaseState
