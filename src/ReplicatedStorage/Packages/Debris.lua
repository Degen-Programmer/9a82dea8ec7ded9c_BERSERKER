local debrisMod = {}

type properties = {
	
	Amount: number;
	Randomness: NumberRange;
	Eruption: boolean;
	Layers: number;
	LayerStart: number;
	LayerIncrement: number;
	
}

local Tweens = game:GetService("TweenService")

function debrisMod.RadialDebris(offset: Vector3, properties: properties)
	task.spawn(function()
		
		local MinMax = properties.Randomness
		local Cached = {}
		
		for radius = properties.LayerStart, properties.Layers, properties.LayerIncrement do
			
			local Rand = math.random(1, 15)
			
			for i = 1, properties.Amount + Rand do

				local formula = i * math.pi*2 / properties.Amount + Rand;
				local Vector: Vector3 = Vector3.new(math.sin(formula) * radius, -.5, math.cos(formula) * radius) + offset

				local Debris = Instance.new("Part", workspace)
				Debris.Size = Vector3.new(0, 0, 0)
				Debris.Material = Enum.Material.Concrete
				Debris.Color = Color3.new(0.317647, 0.317647, 0.317647)
				Debris.Position = Vector;
				Debris.Anchored = true
				Debris.CanCollide = true
				Debris.CFrame = CFrame.lookAt(Debris.Position, offset + -CFrame.new(offset).UpVector * 3)
				
				local T = Tweens:Create(
					
					Debris,
					TweenInfo.new(.25),
					{Size = Vector3.new(math.random(MinMax.Min, MinMax.Max), math.random(1, 2), 1)}
					
				)

				T:Play()

				table.insert(Cached, Debris)

			end
		end
		
		task.delay(5, function()
			
			for _, v: Part in ipairs(Cached) do
					
				local T = Tweens:Create(
					v,
					TweenInfo.new(.25),
					{Size = Vector3.new(0, 0, 0)}
				)
					
				T:Play()
				task.delay(1, function() v:Destroy() end)
				
			end
		end)
	end)
end

function debrisMod.RockTrail(originPos: Vector3, endPos: Vector3, speed: number?, spaceFromOrigin , numberofRocks: number, SizeNumRange: NumberRange)

	local folder = Instance.new("Folder",workspace)
	folder.Name = "debri2"

	game:GetService("Debris"):AddItem(folder, 6)
	local tweenInfo__ = TweenInfo.new(.25)

	------MAIN

	for i=1,2 do
		task.spawn(function()			
			local endPoint
			local startPoint

			if i == 1 then
				startPoint = CFrame.new(originPos.X,0,originPos.Z) * CFrame.new(spaceFromOrigin,0,0)
				endPoint = endPos *  CFrame.new(spaceFromOrigin,0,0)
			elseif i == 2 then
				startPoint = CFrame.new(originPos.X,0,originPos.Z) * CFrame.new(-spaceFromOrigin,0,0)
				endPoint = endPos *  CFrame.new(-spaceFromOrigin,0,0)
			end


			for c= 0,1,numberofRocks  do
				
				task.wait(speed)
				
				local rockpos = startPoint:Lerp(endPoint,c)
				
				--[[local smoke = game:GetService("ReplicatedStorage").Smoke:Clone()
				smoke.Parent = folder;
				smoke.CFrame = rockpos + CFrame.new(0, 0, rockpos.Z).Position
				smoke.ParticleEmitter:Emit(smoke:GetAttribute("EmitCount"))]]
				
				local rock = Instance.new("Part")
				rock.CanCollide = true
				rock.Anchored = true
				rock.Color = Color3.new(0.317647, 0.317647, 0.317647)
				rock.Size = Vector3.new(math.random(SizeNumRange.Min, SizeNumRange.Max) / 2, math.random(SizeNumRange.Min, SizeNumRange.Max) / 2, math.random(SizeNumRange.Min, SizeNumRange.Max) / 2)
				rock.CFrame = CFrame.new(rockpos.X,-4,rockpos.Z) * CFrame.Angles(math.rad(math.random(-30,30)),math.rad(math.random(-30,30)),0)
				rock.Parent = folder
				rock.CFrame = CFrame.new(rockpos.X,-4,rockpos.Z) * CFrame.Angles(math.rad(math.random(-30,30)),math.rad(math.random(-30,30)),0)
				rock.Material = Enum.Material.Concrete

				local tweenS = game:GetService("TweenService")

				task.spawn(function()
					if i == 1 then
						tweenS:Create(rock,tweenInfo__,{CFrame = rock.CFrame * CFrame.new(0,4,0) * CFrame.Angles(0,0,math.rad(30))}):Play()	
					elseif i == 2 then
						tweenS:Create(rock,tweenInfo__,{CFrame = rock.CFrame * CFrame.new(0,4,0) * CFrame.Angles(0,0,math.rad(-30))}):Play()	
					end
					task.wait(5)
					tweenS:Create(rock,TweenInfo.new(.25),{Size = Vector3.new(0, 0, 0)}):Play()	
				end)
			end
		end)
	end
end

return debrisMod