local JumpscareState = {}
JumpscareState.__index = JumpscareState

function JumpscareState.new(NPC, FSM)
	local self = setmetatable({}, JumpscareState)
	self.NPC = NPC
	self.ParentFSM = FSM
	self.State_Anim = nil
	self.Target = nil
	self.Escape_Range = 30
	
	return self
end

function JumpscareState:Enter(Info)
	
	Info.Target.HumanoidRootPart.CFrame = self.NPC.Jumpscare.CFrame + self.NPC.Jumpscare.CFrame.LookVector
	Info.Target.Humanoid.BreakJointsOnDeath = false
	Info.Target.HumanoidRootPart.Anchored = true
	self.NPC.HumanoidRootPart.Anchored = true
	
	game.ReplicatedStorage.Remotes.Jumpscare:FireClient(game.Players:GetPlayerFromCharacter(Info.Target))
	
	task.wait(1)
	Info.Target.HumanoidRootPart.Anchored = false
	Info.Target.Humanoid.Health = 0
	self.NPC.HumanoidRootPart.Anchored = false
	self.ParentFSM:ChangeState("Patrol")
end

function JumpscareState:Update(Info)
	
end

function JumpscareState:Exit()
	
end

return JumpscareState
