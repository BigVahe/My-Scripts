-- Inputs --
local UIS = game:GetService("UserInputService")
local plr = game.Players.LocalPlayer :: Player
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid") :: Humanoid
local ropeInput = Enum.UserInputType.MouseButton1
local unropeInput = Enum.KeyCode.Space
local createRope_E = script.Parent:WaitForChild("createRope") :: RemoteEvent
local mouse = plr:GetMouse()
local connect 
local IsRoping

UIS.InputBegan:Connect(function(i, g)
	if g then return end
	
	if i.UserInputType == ropeInput then
		if IsRoping then return end
		createRope_E:FireServer(mouse.Hit, i.UserInputType)
		IsRoping = true
		checkHum()
	elseif i.KeyCode == unropeInput then 
		createRope_E:FireServer(nil, Enum.KeyCode.Space)
		IsRoping = false
	end
end)



----------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------



-- Rope Creator --
local createRope_E = script.Parent.createRope :: RemoteEvent
local rope = {}
local attach0
local attach1
local part
local beam
local angle
local offset

local function propel(hrp:Part)
	local vel = hrp.AssemblyLinearVelocity
	local dir = vel.Unit
	local maxBoost = 0.47
	
	if vel.Magnitude <= 50 then return end
	
	hrp.AssemblyLinearVelocity += (dir * vel) * maxBoost
end

createRope_E.OnServerEvent:Connect(function(plr:Player, mousePos:CFrame, input)
	
	local char = plr.Character
	local hum = char.Humanoid :: Humanoid
	
	if not hum then return end
	
	local hrp = char.HumanoidRootPart :: Part
	local alignOrientation = hrp:WaitForChild("AlignOrientation")
	
	if input == Enum.KeyCode.Space then
		if not rope[char] then return end
		hum.PlatformStand = false
		alignOrientation.Enabled = false
		attach1:Destroy()
		part:Destroy()
		beam:Destroy()
		rope[char] = nil
		propel(hrp)
		return
			
	elseif input == Enum.UserInputType.MouseButton1 and rope[char] then
		return
	end
	
	local lenght = (mousePos.Position - hrp.Position).Magnitude
	if lenght > 150 then return end
	
	part = Instance.new("Part")
	part.Anchored = true
	part.Position = mousePos.Position
	part.Size = Vector3.one
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 1
	part.Parent = workspace
	
	attach0 = Instance.new("Attachment")
	attach0.Parent = part

	attach1 = Instance.new("Attachment")
	attach1.Parent = hrp
	
	rope[char] = Instance.new("SpringConstraint")
	rope[char].Name = "rope"
	rope[char].Attachment1 = attach1
	rope[char].Attachment0 = attach0
	rope[char].Coils = 0
	rope[char].LimitsEnabled = true
	rope[char].MaxLength = lenght
	rope[char].Thickness = 0.3
	rope[char].Color = BrickColor.new("White")
	rope[char].Parent = workspace
	hum.PlatformStand = true
	
	task.spawn(function()
		while true do
			task.wait(0.15)
			if rope[char] then
				offset = (part.Position - hrp.Position).Unit
				alignOrientation.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + hrp.AssemblyLinearVelocity.Unit, offset)
				alignOrientation.Enabled = true
			else
				
				break
			end
		end
	end)
	
	beam = Instance.new("Beam")
	beam.Attachment1 = attach1
	beam.Attachment0 = attach0
	beam.LightEmission = 1
	beam.Transparency = NumberSequence.new(0)
	beam.FaceCamera = true
	beam.Width0 = 0.13
	beam.Width1 = 0.2
	beam.Parent = workspace
end)
