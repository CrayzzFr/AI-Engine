local DetectionService = {}

local Players = game:GetService("Players")

type RangeSettings = {
	VisionRange : number,
	VisionDetectionRange : number,
	AttackRange : number,
	EscapeRange : number
}

-- Detects if a player is in range.
function DetectionService.Detect(Origin : Part | BasePart, Mode : "Less"|"Greater", RangeSettings : RangeSettings) : () -> (boolean, Player)
		local Validated = false
		local CharFound = nil

		for i, v in Players:GetPlayers() do
			if v.Character.Humanoid.Health <= 0 then return end
			
			local Direction = (v.Character.HumanoidRootPart.Position - Origin.Position)

			local Params = RaycastParams.new()
			Params.FilterType = Enum.RaycastFilterType.Exclude
			Params.FilterDescendantsInstances = {Origin.Parent}

			local rayResult = workspace:Raycast(Origin.Position, Direction.Unit * RangeSettings.VisionRange, Params)
			
			local Dot = Direction.Unit:Dot(Origin.CFrame.LookVector)
			
			local Behind = (Dot < 0)
			
			if rayResult then
			if Mode == "Greater" then
				if not rayResult.Instance:IsDescendantOf(v.Character) and Direction.Magnitude > RangeSettings.EscapeRange then
					Validated = true
					CharFound = v.Character
					break
				end
			elseif Mode == "Less" then
				if rayResult.Instance:IsDescendantOf(v.Character) and not Behind or Behind and Direction.Magnitude <= RangeSettings.VisionDetectionRange and rayResult.Instance:IsDescendantOf(v.Character) then
					Validated = true
					CharFound = v.Character
					break
				end
			end
			end
		end

	return Validated, CharFound 
end


return DetectionService
