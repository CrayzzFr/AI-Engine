return function(Waypoints, NPC, Shape : Enum.PartType)
	local Folder = Instance.new("Folder")
	Folder.Name = NPC:GetAttribute("MonsterId")
	Folder.Parent = workspace
	
	for i, v in Waypoints do
		local Part = Instance.new("Part")
		
		if Shape == "Block" then
			Part.Size = Vector3.new(1,0.2,1)
		elseif Shape == "Ball" then
			Part.Size = Vector3.new(0.5,0.5,0.5)
		end

		Part.Anchored = true
		Part.CanCollide = false
		Part.Position = v.Position
		Part.Parent = Folder
		Part.Color = Color3.fromRGB(80, 223, 255)
		Part.Material = Enum.Material.Neon
		Part.Transparency = 0.2
		Part.Shape = Shape
	end
end
