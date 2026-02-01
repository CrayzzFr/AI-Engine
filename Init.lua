local StateMachineCreator = require(script.StateMachine)
local StateMachine = StateMachineCreator.new()


local Patrol = require(script.States.Patrol)
local Chase = require(script.States.Chase)
local Jumpscare = require(script.States.Jumpscare)

local PatrolState = Patrol.new(workspace.Test, StateMachine, workspace.Waypoints)
local ChaseState = Chase.new(workspace.Test, StateMachine)
local JumpscareState = Jumpscare.new(workspace.Test, StateMachine)


StateMachine:AddState("Patrol", PatrolState)
StateMachine:AddState("Chase", ChaseState)
StateMachine:AddState("Jumpscare", JumpscareState)
StateMachine:SetBaseState("Patrol")

task.wait(1)

workspace.Test.HumanoidRootPart:SetNetworkOwner(nil)
StateMachine:Start()
