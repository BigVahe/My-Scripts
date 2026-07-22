-- Room Genator Module --
local generator = {}
--{{Modules}}--
local SS = game:GetService("ServerStorage")
local roomInfo = require(SS.Generator.RoomInfo)
--{{Variables}}--
generator.random = Random.new()
local roomF = workspace.roomTemp
local lastTurn = nil
print()

generator.GeneratedTable = {}

function generator.Randomizer(prevRoom)
	local totalWeight = 0
	for i, info in pairs(roomInfo) do
		totalWeight += info.Weight
	end
	
	local randomWeight = generator.random:NextNumber(0.1, totalWeight)
	local currentWeight = 0
	local randomRoom = nil
	for i, info in pairs(roomInfo) do
		currentWeight += info.Weight
		if randomWeight <= currentWeight then
			randomRoom = workspace.roomTemp[i]
			break
		end
	end

	local direction = roomInfo[randomRoom.Name]["Direction"]
	local hasStairs = roomInfo[randomRoom.Name]["Stairs"]
	local prevHadStairs = roomInfo[prevRoom.Name]["Stairs"]
	
	if (randomRoom.Name == prevRoom.Name)
		or (hasStairs and prevHadStairs)
		or (direction and direction == lastTurn)
	then
		return generator.Randomizer(prevRoom)
	else
		if direction then
			lastTurn = direction
		end
	end
	return randomRoom
end

function generator.generate(prevRoom)
	local randomRoom = generator.Randomizer(prevRoom)
	local newroom = randomRoom:Clone()
	newroom.PrimaryPart = newroom.Entry
	newroom.Parent = workspace
	
	local setPrimCf = newroom:PivotTo(prevRoom.Exit.CFrame * CFrame.new(0, 0, -2))
	
	return newroom
end

return generator



----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------



-- and one of the puzzle for a random room --
--{{Tables}}
local codeTable = {}
local puzzle = script.Parent:WaitForChild("Puzzle")
local puzzleT = puzzle:GetChildren()
local puzzleCode = {0, 0, 0}
--
local colors = {
	Color3.fromRGB(230, 50, 10),
	Color3.fromRGB(40, 200, 100),
	Color3.fromRGB(0, 100, 255)
}

--{{Events}}
local destroyToolEvent:BindableEvent = script:WaitForChild("DeleteTool")

--{{Numbers}}
local R, G, B = 1, 2, 3

--{{Parts}}
local gate = script.Parent:WaitForChild("Gate")
local note = script.Parent:WaitForChild("Note")

local function check()
	
	for i, num in ipairs(puzzleCode) do
		puzzleCode[i] = puzzle["KeyCode"..i].R.Value
	end
	
	for i, num in ipairs(codeTable) do
		if codeTable[i] ~= puzzleCode[i] then
			break
		else
			if i == #codeTable then
				gate.Transparency = 1
				gate.CanCollide = false
				destroyToolEvent:Fire(note)
				
			end
		end
	end
	
end

local function generateCode()
	for i = 1, 3 do
		local random = math.random(1, 3)
		table.insert(codeTable, random)
	end
	note.Handle.SurfaceGui.TextLabel.Text = codeTable[1]..codeTable[2]..codeTable[3]
end

local function currentCode()
	for i, key:Part in pairs(puzzle:GetChildren()) do
		local debounce = false
		local currentIndex = 1
		key.ClickDetector.MouseClick:Connect(function()
			if debounce then return end
			debounce = true
			
			if currentIndex > #colors then
				currentIndex = 1

				key.Color = colors[currentIndex]
				key.R.Value = currentIndex
			else
	
				key.Color = colors[currentIndex]
				key.R.Value = currentIndex
				currentIndex += 1
			end
			
			check()
			task.wait(.4)
			debounce = false
		end)
	end
end

--{{Calls}}
currentCode()
generateCode()
