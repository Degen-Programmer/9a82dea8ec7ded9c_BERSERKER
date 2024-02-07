local self = {}

local rep = game:GetService("ReplicatedStorage")

local Tween = game:GetService("TweenService")
local Debris = require(rep.Packages.Debris)

local BubbleModule = require(rep.Packages.BubbleModule)
local Assets = rep.Assets
local SFX = Assets.SFX
local VFX = Assets.VFX

function self.TweenSequence(object, Keyframes)
	
	task.spawn(function()

		local ExecutionMethods = {}

		function ExecutionMethods.Express(v)

			local currentTween = Tween:Create(object, v.Info, v.PropertiesTable)
			
			currentTween:Play()
			currentTween.Completed:Wait()

		end

		for _, v in ipairs(Keyframes) do
			ExecutionMethods.Express(v)
		end
		
	end)
end

function self.RingShockwave(StartSize: number, CF: CFrame, depth: number)
	
	local Start: Vector3 = Vector3.new(StartSize, StartSize, StartSize)
	local EndSize = Vector3.new(depth, depth, depth)
	
	local SecondStartSize = Vector3.new(StartSize - 1, StartSize - 1, StartSize - 1)
	local SeconDendSize = Vector3.new(depth - 2, depth - 2, depth -2)
	
	BubbleModule.CreateBubble(CF, Start, 2, EndSize, .5)
	BubbleModule.CreateBubble(CF, SecondStartSize, 1, SeconDendSize, .5)
	
end

function self.ApplyKB(RootPart: Part, direction: Vector3, force: number)
	RootPart:ApplyImpulse(direction * force)

end


function self.CloneAndEmit(name: string, position: Vector3, duration, delaybeforeEmit)

	duration = duration or 2.5
	delaybeforeEmit = delaybeforeEmit or 0;

	local clone = VFX:FindFirstChild(name):Clone()
	clone.Parent = game.workspace
	clone.Position = position

	task.delay(delaybeforeEmit, function()
		for _, v in ipairs(clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then v:Emit(v:GetAttribute("EmitCount")) end
		end
	end)

	task.delay(duration, function()
		clone:Destroy()
	end)

	return clone
end

function self.CloneAndPlay(name: string, parent, duration)
	
	duration = duration or 2.5

	local clone = SFX:FindFirstChild(name):Clone()
	clone.Parent = parent
	clone:Play()

	task.delay(duration, function()
		clone:Destroy()
	end)

	return clone
end

--[[function self.Clone(moveset, name: string, position: Vector3, duration)

	local clone = characters:FindFirstChild(moveset).VFX:FindFirstChild(name):Clone()
	clone.Parent = game.workspace
	clone.Position = position

	return clone

end

function self.Clone(moveset, name: string, position: Vector3, duration)

	local clone = characters:FindFirstChild(moveset).VFX:FindFirstChild(name):Clone()
	clone.Parent = game.workspace
	clone.Position = position
	
	return clone
	
end]]


return self 