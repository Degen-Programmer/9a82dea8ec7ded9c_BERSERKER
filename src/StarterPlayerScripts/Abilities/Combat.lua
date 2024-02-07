local Combat = {}
local plr = game.Players.LocalPlayer;
local Effects = require(script.Parent.Parent.Utilities.Effects)

local rep = game:GetService("ReplicatedStorage")
local tweenservice = game:GetService("TweenService")
local camera = require(script.Parent.Parent.Utilities.Camera)

local FX = rep.Assets.FX.Combat;
local Animations = rep.Assets.Animations;
local Auras = rep.Assets.Auras;

--local DeathEffects = rep.Assets.FX.DeathEffects;

function Combat.LoadAura(kwargs : {})

    local Player : Player = kwargs.Subject;
    local Aura : string = kwargs.Aura;

    local Folder : Folder = Auras:FindFirstChild(Aura)
    if not Folder then return end

    for _, v in ipairs(Player.Character:GetChildren()) do

        local char_part : string = v;

        if Folder:FindFirstChild(char_part.Name) then
            
            local aura_part = Folder:FindFirstChild(char_part.Name)
            local clone_part : Part = aura_part:Clone();

            clone_part.Parent = char_part;
            clone_part.CFrame = char_part.CFrame;

            local wc : WeldConstraint = Instance.new("WeldConstraint")
            wc.Parent = clone_part;
            wc.Part0 = char_part;
            wc.Part1 = clone_part;

            clone_part.Name = "_AURAPART"
            

        end
    end
end

function Combat.RemoveAura(kwargs : {})

    local Player : Player = kwargs.Subject;

    for _, v in ipairs(Player.Character:GetDescendants()) do
       if v.Name == "_AURAPART" then
            v:Destroy()
       end 
    end

    print("REMOVED AURA.")
    
end

local RunnerThread = nil;
local UIS = game:GetService("UserInputService")

function Combat.LockOn(kwargs)
    
    local Opponent = kwargs.Opponent;
    local Request = kwargs.Request;

    if Request == "LockOn" then

        local character = plr.Character;
        local OpponentHRP = Opponent.HumanoidRootPart;

        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter;

        local function UpdateCam()

            local hrpPos, dummyPos = character.HumanoidRootPart.CFrame.Position, OpponentHRP.Position
            local CFam = CFrame.new(hrpPos, Vector3.new(dummyPos.X, hrpPos.Y, dummyPos.Z))
            local CamCFam = CFam * CFrame.new(3, 2.5, 5) 
    
            workspace.CurrentCamera.CFrame = CamCFam
            
        end

        RunnerThread =  game:GetService("RunService").RenderStepped:Connect(function() -- // Switch to BindRenderStep LATER!
            UpdateCam()
        end)

    elseif Request == "LockOff" then
        
         print("Locking Off")
         RunnerThread:Disconnect();
         UIS.MouseBehavior = Enum.MouseBehavior.Default;

    end
end

function Combat.Cooldown(kwargs)

    print("GOT")

    --[[local Player = kwargs.Player;
    local Character = Player.Character;
    local Root = Character.HumanoidRootPart
    local Humanoid = Character.Humanoid;

    -- // go from 0 ---> 0.99

    local Root = Player.PlayerGui:WaitForChild("Root");
    local Main = Root.HUD.Ability;

    if kwargs.M1 then
        Main = Root.HUD.Parry;
    else
        Main = Root.HUD.Ability;
    end

    local CD = Main:FindFirstChild("Cooldown");
    CD.Offset = Vector2.new(0, 0);

    tweenservice:Create(Main.Icon, TweenInfo.new(0.25), {Size = UDim2.new(0.65, 0, 0.65, 0), ImageTransparency = 1;}):Play()

    task.delay(kwargs.Cooldown, function()
        tweenservice:Create(Main.Icon, TweenInfo.new(0.25), {Size = UDim2.new(0.597, 0, 0.582, 0), ImageTransparency = 0;}):Play()
    end)

    if Player == plr then

        tweenservice:Create(CD, TweenInfo.new(kwargs.Cooldown), {Offset = Vector2.new(0, 0.99)}):Play()

    end]]
end

function Combat.Reset(kwargs)

   --[[ local Player = kwargs.Player;
    local Character = Player.Character;
    local Root = Character.HumanoidRootPart
    local Humanoid = Character.Humanoid;

    local Root = Player.PlayerGui:WaitForChild("Root");
    local Main = Root.HUD.Ability;

    Main:Destroy();

    local new_HUD = game.ReplicatedStorage.UI.HUD:Clone()
    new_HUD.Parent = Root;]]

end

function Combat.M1(kwargs)

    local Player = kwargs.Player;
    local Character = Player.Character;
    local Root = Character.HumanoidRootPart
    local Humanoid = Character.Humanoid;

    if kwargs.Power ~= 0 then
        -- Root.AssemblyLinearVelocity += Root.CFrame.LookVector * 235;
    end

    -- // Make shield:

    local highlight = Instance.new("Highlight")
    highlight.Parent = Character;
    highlight.FillTransparency = 1;
    highlight.OutlineColor = Color3.new(0, 0, 0);
    highlight.OutlineTransparency = 0;
    highlight.FillColor = Color3.new(1, 1, 1);

    local Sound : Sound = FX.SFX.M1:Clone();
    Sound.Parent = Root;
    Sound:Play()

    Effects.Clone("Combat", "Shield", function(Shield : Part)
        
        Shield.Parent = workspace;

        Effects.Join(Root, Shield, CFrame.new(0, 0, 0));
        Effects._Emit(Shield)

        task.delay(2, function()
            Shield:Destroy();
            Sound:Destroy()
        end)
    end)
    --Root:ApplyImpulse(Root.CFrame.LookVector * 600)

    -- // tweenings:

    local tween = tweenservice:Create(highlight, TweenInfo.new(1.25), {OutlineTransparency = 1, FillTransparency = 1}):Play()

    task.delay(1, function()
        highlight:Destroy()
    end)
end

function Combat.DeathEffect(kwargs)

    print("Played death effect.")
    
    --[[local DeathEffect = kwargs.Effect;
    local Player = kwargs.Victim;

    local Character = Player.Character;

    Effects.Clone("DeathEffects", DeathEffect, function(DeathFX)
        
        DeathFX.Position = Character.HumanoidRootPart.Position;
        DeathFX.CFrame = Character.HumanoidRootPart.CFrame;
        
        Effects._Emit(DeathFX);

        task.delay(3, function()
            DeathFX:Destroy()
        end)
    end)]]
end

function Combat.BerserkerChosen(args : {})

    print("Bes chosen")
    local player = args.Subject;

    local character = player.Character;
    local Root = character.HumanoidRootPart;

    Effects.Clone("General", "BerserkerChosen", function(Burst : Part)
        Burst.Position = Root.Position + Vector3.new(0, -2.5, 0);
        Effects._Emit(Burst)

        task.delay(3, function()
            
           Burst:Destroy() 

        end)
    end)
end

function Combat.ChampionChosen(args : {})

    print("Champ chosen.")
    
    local player = args.Subject;

    local character = player.Character;
    local Root = character.HumanoidRootPart;

    Effects.Clone("General", "ChampionChosen", function(Burst : Part)
        Burst.Position = Root.Position + Vector3.new(0, -2.5, 0);
        Effects._Emit(Burst)

        task.delay(3, function()

           Burst:Destroy() 

        end)
    end)
end


function Combat.Knockback(kwargs)

    print("Parried!")

    local Player = kwargs.Player
    local _PlayerCharacter = Player.Character;
    local KB = kwargs.Knockback;

    -- // camera shake:

   --[[ if plr == Player then
        camera.ChangeFOV(workspace.CurrentCamera, {

            Time = 0.3;
            FieldOfView = 75;
    
        })
    
        camera.Shake("Bump")
    end]]

    _PlayerCharacter.HumanoidRootPart.AssemblyLinearVelocity = -_PlayerCharacter.HumanoidRootPart.CFrame.LookVector * KB 
    _PlayerCharacter.Humanoid.Animator:LoadAnimation(Animations.Kb):Play()

end

function Combat.UseWeapon(kwargs)

    --print("Mans got hit xd")

    local Player = kwargs.Player
    local PlayerCharacter = Player.Character;
    local PlayerWeld = kwargs.PlayerWeld;
    local PlayerArray = kwargs.PlayerArray;

    PlayerWeld.C0 = PlayerArray.Equipped;
    PlayerWeld.Part0 = PlayerCharacter["Right Arm"]
    PlayerCharacter.Humanoid.Animator:LoadAnimation(Animations.Heartless):Play();

    local _slash = nil;

    if FX.Parent.Slashes:FindFirstChild(kwargs.PlayerWeapon) then
        _slash = kwargs.Weapon
    else
        _slash = "Default"
    end

    print(_slash)

    local Sound : Sound = FX.SFX.M1:Clone();
    Sound.Parent = PlayerCharacter.HumanoidRootPart;
    Sound:Play()

    task.delay(3, function()
        Sound:Destroy();
    end)

    -- // VFX:

    local Slash = Effects.Clone("Slashes", _slash, function(SlashFX)
        
        SlashFX.Position = PlayerCharacter.HumanoidRootPart.Position;
        SlashFX.CFrame = PlayerCharacter.HumanoidRootPart.CFrame * CFrame.Angles(0, 0, math.rad(math.random(-45, 45)));
        Effects._Emit(SlashFX);

        task.delay(1, function()

            SlashFX:Destroy()

            PlayerWeld.C0 = PlayerArray.Unequipped;
            PlayerWeld.Part0 = PlayerCharacter["Torso"]

        end)
    end)

    --[[local Hit = Effects.Clone("Combat", "Hit", function(HitFX)
        
        HitFX.Position = PlayerCharacter.HumanoidRootPart.Position;
        HitFX.CFrame = PlayerCharacter.HumanoidRootPart.CFrame;
        Effects._Emit(HitFX);

        task.delay(1, function()

            HitFX:Destroy()

        end)
    end)]]
end

return Combat