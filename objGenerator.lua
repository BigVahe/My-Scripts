-- Generator Script --
local rock_Handler = require(game.ServerStorage.rock_Handler)
local obj_Stats = require(game.ServerStorage.obj_Stats)

local function random()
	local random = math.random(1, 4)
	if random == 4 then 
		return true
	end
end

local function updater(instance)
	local name = instance.Name
	local hp = obj_Stats[name].health
	local newRock = rock_Handler.new(instance, hp)
	if random() then
		newRock:Mutation(Random.new():NextInteger(1.1, 5))
	end
end

workspace.rocks.ChildAdded:Connect(function(instance)
	updater(instance)
end)

task.spawn(function()
	repeat
		local clone = game.ServerStorage.templates:GetChildren()[math.random(1, #game.ServerStorage.templates:GetChildren())]:Clone()
		if not clone:IsA("BasePart") then
			clone:PivotTo(CFrame.new(math.random(-40, 40), 6.875, math.random(-40, 40)))
		else
			clone.Position = Vector3.new(math.random(-40, 40), 2.25, math.random(-40, 40))
		end
		clone.Parent = workspace.rocks
		task.wait(4)
	until false
end)



---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

-- Module Handling --
local rock_Handler = {}
rock_Handler.__index = rock_Handler

function rock_Handler.new(instance, health)
	if not instance then  warn("no instance") return end
	if rock_Handler[instance] then warn("already exists") return end
	local self = setmetatable({}, rock_Handler)
	self.Instance = instance
	self.Health = health or 100
	self.HasMutation = false
	rock_Handler[instance] = self
	return self 
end

function rock_Handler:DestroyRock()
	if rock_Handler[self.Instance] and self then
		self.Instance:Destroy()
		rock_Handler[self.Instance] = nil
		self = nil
	end
end

function rock_Handler:Damage(dmg)
	if not self or not dmg then warn("does not exist or no dmg number") return end
	self.Health -= dmg
	print(self.Health)
	if self.Health <= 0 then self:DestroyRock() end
end

function rock_Handler:Mutation(multiplier)
	if self.HasMutation then return end
	if not multiplier then warn("add a multiplier") return end
	local R, G, B = math.random(1, 255), math.random(1, 255), math.random(1, 255)
	local R2, G2, B2 = math.random(1, 255), math.random(1, 255), math.random(1, 255)
	self.HasMutation = true
	self.Health *= multiplier
	local newH = Instance.new("Highlight") :: Highlight
	newH.OutlineColor = Color3.fromRGB(R, B, G)
	newH.FillTransparency = 0.75
	newH.FillColor = Color3.fromRGB(R2, B2, G2)
	newH.Parent = self.Instance
end

return rock_Handler
