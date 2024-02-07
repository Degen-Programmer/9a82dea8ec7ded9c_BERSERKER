--[[
	Blood module 1.0.5 by SSolarite | 28 July 2023
	https://devforum.roblox.com/t/blood-module-item-asylum-combat-warriors-styled-blood/2456183/

		API:
			Blood.spawnDroplet(position: Vector3, velocity: Vector3, color: Color3?, puddleTransparency: number, size: number?)
				Returns a new droplet with position `position`, velocity of `velocity`, with optional color, puddle transparency and size options.
				
	Getting Started:
	Create a folder in workspace called Debris, then make 2 folders called BloodPuddles and BloodDroplets, these are where the puddles and droplets will go.
	You can modify where the droplets/puddles are placed by modifying the Settings file, it has a lot of stuff.
	
	Next, drop this module into a place like ReplicatedStorage. If you're going to use this only on the server, drop it into ServerScriptService or any other place the server can access.
	Example code:
	
	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Blood = require(ReplicatedStorage.Blood) -- in my case it's in ReplicatedStorage
	for i = 1, 50 do
		Blood.spawnDroplet(
			Vector3.new(math.random(-10, 10), 20, math.random(-10, 10)),
			Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
		)
	end
	```
	This script will spawn in 50 droplets at random positions with random velocities.
]]


local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Settings = require(script:WaitForChild("Settings"))
local PartCache = require(script:WaitForChild("PartCache"))
-- Base RNG for everything in code.
local RNG = Random.new()

local Blood = {}

-- Internal function to create a blood puddle.
function Blood:_makePuddle(
	speed: number,
	size: number?,
	cframe: CFrame,
	puddleFadeTime: number,
	color: Color3?
) 
	size = size or RNG:NextNumber(1.1, 2.6)
	color = color or Color3.fromRGB(255, 0, 0)
	
	local partCache = PartCache.new(script:WaitForChild("puddle"), 1)
	local puddle = partCache:GetPart()
	puddle.CFrame = cframe
	puddle.Color = color
	puddle.Parent = Settings.DEFAULT_PUDDLE_PARENT
	
	local sizeTweenInfo = TweenInfo.new(
		speed,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut
	)
	local sizeTween = TweenService:Create(
		puddle, 
		sizeTweenInfo,
		{
			Size = Vector3.new(size, 0.1, size),
		}
	)
	sizeTween:Play()
	task.delay(Settings.BLOOD_LIFETIME, function()
		local transparencyTween = TweenService:Create(puddle, TweenInfo.new(RNG:NextNumber(0.4, 1.2)), {
			Size = Vector3.new(0.0001, 0.0001, 0.0001),
			Transparency = 1,
		})
		transparencyTween:Play()
		transparencyTween.Completed:Connect(function()
			puddle:Destroy()
		end)
	end)
end

function Blood:_makeDroplet(color: Color3?)
	color = color or Color3.fromRGB(255, 0, 0)
	
	local partCache = PartCache.new(script:WaitForChild("droplet"), 1)
	local droplet = partCache:GetPart()
	droplet.Trail.Enabled = false
	task.delay(0.01, function()
		droplet.Trail.Enabled = true
	end)
	droplet.Size = Vector3.new(RNG:NextNumber(0.20, 0.25), RNG:NextNumber(0.20, 0.25), RNG:NextNumber(0.20, 0.25))
	droplet.Parent = Settings.DEFAULT_DROPLET_PARENT
	droplet.Color = color
	return droplet
end

function Blood.spawnDroplet(
	position: Vector3,
	velocity: Vector3,
	color: Color3?,
	puddleTransparency: number?,
	size: number?
)
	local connection
	local droplet = Blood:_makeDroplet(color)
	
	color = color or Color3.fromRGB(255, 0, 0)
	puddleTransparency = puddleTransparency or 0.5
	
	local filter = {droplet, Settings.DEFAULT_PUDDLE_PARENT, Settings.DEFAULT_DROPLET_PARENT}
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	
	for _, player in Players:GetPlayers() do
		table.insert(filter, player.Character)
	end
	for _, humanoid in workspace:GetDescendants() do
		if humanoid:IsA("Humanoid") then
			local character = humanoid.Parent
			table.insert(filter, character)
		end
	end
	raycastParams.FilterDescendantsInstances = filter
	connection = RunService.Stepped:Connect(function(_, deltaTime)
		local newPosition = position + velocity * deltaTime
		
		local raycast = workspace:Raycast(position, newPosition - position, raycastParams)
		droplet.Position = newPosition
			
		if raycast then
			droplet:Destroy()
			connection:Disconnect()
			local puddleSize = RNG:NextNumber(1.1, 2.6)
			Blood:_makePuddle(RNG:NextNumber(0.9, 1.3), size, CFrame.lookAt(raycast.Position, raycast.Position + raycast.Normal) * CFrame.Angles(math.pi / 2, 0, 0), 0.5, color)
			return
		end
		
		velocity += Vector3.new(0, Settings.GRAVITY, 0) * deltaTime
		position = newPosition
		if droplet.Position.Y < Settings.FALLEN_DROPLETS_DESTROY_HEIGHT then
			droplet:Destroy()
			return
		end
	end)
end

return {
	spawnDroplet = Blood.spawnDroplet
}