local FSM = {}
FSM.__index = FSM

local RNS = game:GetService("RunService")


function FSM.new()
	local self = setmetatable({}, FSM)
	self.Current_State = nil
	self.Previous_State = nil
	self.States = {}
	self.Current_Info_Batch = nil
	
	return self
end

function FSM:ChangeState(StateName, Info)
	if not self.States[StateName] then warn("This state doesn't exist.") return end

	if self.Current_State == nil then
		self.Current_State = StateName

		if self.States[self.Current_State].Enter then
			self.States[self.Current_State]:Enter(Info)
			self.Current_Info_Batch = Info
		else
			print(`Going into {self.Current_State} state`)
		end
	else
		if self.States[self.Current_State].Exit then
			self.States[self.Current_State]:Exit()
		else
			print(`Going out of {self.Current_State} state`)
		end
		
		local Previous_State = self.Current_State
		
		self.Previous_State = Previous_State

		self.Current_State = nil

		self.Current_State = StateName

		if self.States[self.Current_State].Enter then
			self.States[self.Current_State]:Enter(Info)
			self.Current_Info_Batch = Info
		else
			print(`Going into {self.Current_State} state`)
		end
	end
end

-- Adds a state to the state machine. You must set a base state for the machine to start
function FSM:AddState(StateName, State)
	self.States[StateName] = State
end

function FSM:GetState()
	return self.Current_State
end

function FSM:GetPreviousState()
	return self.Previous_State
end

function FSM:SetBaseState(StateName)
	self.Current_State = StateName
end


function FSM:Start()
	
	if self.Current_State == nil then 
		warn("You must set a base state for the state machine to start")
		return
	end
	
	if self.States[self.Current_State].Enter then
		self.States[self.Current_State]:Enter()
	end
	
	RNS.Heartbeat:Connect(function(dt)
		if self.States[self.Current_State].Update then
		self.States[self.Current_State]:Update(self.Current_Info_Batch)
		end
	end)
end

return FSM
