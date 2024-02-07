
local TweenService = game:GetService("TweenService")
--[[

    works based on an object pooling system. 
    read more about object pooling here: https://en.wikipedia.org/wiki/Object_pool_pattern

    this cuts down on the amount of objects that need to be created and destroyed.
    Usage:

    local effect = Effect.new("Dash")
    effect:Deploy(position: Vector3, function(effectPart : Part)
        -- do anything you want.
    end

]]

local Effect = {}
Effect.__index = Effect;

local VFX = workspace.VFX;
local ActiveVFX = VFX.Active;
local Standby = VFX.Standby;
local Bezier = require(game.ReplicatedStorage.Packages.Bezier);

local FX = game.ReplicatedStorage.Assets.FX

function Effect.Clone(Directory: string, Effect: string, ...)

    local Clone = FX:FindFirstChild(Directory):FindFirstChild(Effect):Clone();
    Clone.Parent = workspace;

    ({...})[1](Clone)
    
end

type charge_configs = {

	trail: Part;
	target: Part;
	p0_rand: NumberRange;
	p1_rand: NumberRange;
	frequency: number;
	speed: number;
	iterations: number;
	duration: number;

}

function Effect.ChargeUp(configs: charge_configs)

	local self = configs;

	local can = true;
	local p0_rand = self.p0_rand
	local p1_rand = self.p1_rand;

	task.spawn(function()
		local function solve_bezier(tx)

			local positions = {} -- Array to store all the created positions.

			-- // Generate Bezier:

			local curve = Bezier.new({

				self.target + Vector3.new(math.random(-p0_rand, p0_rand), math.random(-p0_rand, p0_rand), math.random(-p0_rand, p0_rand)); 
				tx.Position + tx.CFrame.LookVector * math.random(-p1_rand, p1_rand) + tx.CFrame.UpVector * math.random(-p1_rand, p1_rand);
				self.target

			})

			-- Create Positions Of Bezier.

			for i = 1, self.iterations do

				local t = i / self.iterations;
				local position = curve:DeCasteljau(t);
				positions[i] = position;

			end

			tx.Position = positions[1] -- Set Position

			-- Move Along Path:

			for i = 1, #positions do

				local current = positions[i]

				local tween = TweenService:Create(tx, TweenInfo.new(0.01), {Position = current})
				tween:Play()

				task.wait(1/self.speed)

				task.spawn(function()
					if i == #positions then
						task.delay(.3, function()
							for _, v in ipairs(tx:GetDescendants()) do
								if v:IsA("ParticleEmitter") then
									v.Enabled = false;
								end
							end

							task.wait(self.destruction_time or 1.5)

							tx:Destroy()
						end)
					end
				end)
			end
		end

		task.delay(self.duration, function()
			can = false;
		end)

		-- Start spawning trails:

		while can do

			-- Starting Position

			local vector3f = self.target + Vector3.new()
			local trail_clone : Part = self.trail:Clone()

			trail_clone.Parent = workspace;
			trail_clone.Position = vector3f 
			trail_clone.Anchored = true;
			trail_clone.CanCollide = false;

			task.spawn(function()
				solve_bezier(trail_clone)
			end)

			task.wait(1/self.frequency)

		end
	end)
end

function Effect._Emit(FX)
    for _, v in ipairs(FX:GetDescendants()) do
        if v:IsA("ParticleEmitter") then
            v:Emit(v:GetAttribute("EmitCount"));
        end
    end   
end

function Effect.SetTransparency(Character, int)

    local Ignores = {"__HITBOX__", "HumanoidRootPart", "__WEAPON__", "_AURAPART"}

    for _, character_part : Part in ipairs(Character:GetDescendants()) do
        if character_part:IsA("BasePart") or character_part:IsA("MeshPart") or character_part:IsA("Part") then
            if table.find(Ignores, character_part.Name) then
            else

                character_part.Transparency = int;

            end
        end
    end 
end

function Effect.Join(Part0, Part1, Offset)
    
    local Weld = Instance.new("Motor6D")
    Weld.Parent = Part0
    Weld.Part0 = Part0
    Weld.Part1 = Part1
	Weld.C0 = Offset or CFrame.new()

    return Weld

end

function Effect.New(EffectName: string, TimeOut: number)
    
    local self = {}

    self._standby_container = Standby:FindFirstChild(EffectName);
    self._active_container = ActiveVFX:FindFirstChild(EffectName);
    self._effect = nil;
    self._duration = TimeOut

    return setmetatable(self, Effect)

end

function Effect:Deploy(position: Vector3, ...)

    task.delay(self._duration, function()
        self:Withdraw()
    end)

    self._effect = self._standby_container:GetChildren()[1];
    self._effect.Parent = self._active_container;
    self._effect.Position = position;

    ({...})[1](self._effect)

end

function Effect:Emit()
    for _, v in ipairs(self._effect:GetDescendants()) do
        if v:IsA("ParticleEmitter") then
            v:Emit(v:GetAttribute("EmitCount"));
        end
    end   

    print("emitted")
end

function Effect:Withdraw()
    
    self._effect.Parent = self._standby_container;
    self._effect.Position = Vector3.new(1000, 1000, 1000);

    print("withdrawn")

end

function Effect:Destroy()
    
end

return Effect