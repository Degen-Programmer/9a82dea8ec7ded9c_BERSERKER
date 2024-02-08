--[[

    Description: User dashes in their movement direction.

]]

local Dash = {}

-- // Configs:

local DASH_VELOCITY_GROUND = 200
local DASH_VELOCITY_AIR = 75;
local DASH_COOLDOWN = 5;

-- // Packages:

local Rep = game:GetService("ReplicatedStorage")
local Packages = Rep.Packages
local Assets = Rep.Assets
local Animations = Assets.Animations;

local Net = require(Packages.BridgeNet2);

local ReplicationManager = Net.ReferenceBridge("ClientReplicator")
local HUD = Net.ReferenceBridge("HUD")

function Dash.Cleanup()
    
end

-- // Function that fires only to the executor, Indicating that their cooldown as begun.

function Dash.Cooldown(Player : Player, self)

    task.delay(DASH_COOLDOWN, function()
        self.AbilitiesDebounce = false;
    end)

    HUD:Fire(Net.Players{Player}, {

        Element = "Ability";
        Action = "Cooldown";
        Arguments = {Player = Player, Duration = DASH_COOLDOWN}

    })
end

-- // Function that replicates the ability to all clients and loads VFX/SFX/Camera Anims and stuff.:

function Dash.Replicate(Action : string, Arguments : {})
    ReplicationManager:Fire(Net.AllPlayers(), {

        Request = "Dash";
        Action = Action;
        Arguments = Arguments;

    })
end

-- // Function that fires only to the executor, playing some camrea animation on their screen.

function Dash.CameraAnimation(Player : Player)
    ReplicationManager:Fire(Net.Players({Player}), {

        Request = "Dash";
        Action = "CameraAnimation";
        Arguments = {Player = Player};

    })
end

-- // Main Function that executes the ability:

function Dash.Execute(kwargs : {}, ...)
    
    local self = kwargs._self

    local Character : Model = self.Character
    local Humanoid : Humanoid = Character.Humanoid;
    local RootPart : Part = Character.HumanoidRootPart;

    -- Check to see if the player is standing still or moving

    local Additive_vector = nil;
    local UsableVelocity = nil;

    if Humanoid.MoveDirection == Vector3.new(0, 0, 0) then
        Additive_vector = RootPart.CFrame.LookVector
    else
        Additive_vector = Humanoid.MoveDirection
    end

    -- Check to see if the player is jumping or na

    if Humanoid.FloorMaterial == Enum.Material.Air then
        UsableVelocity = DASH_VELOCITY_AIR;
    else
        UsableVelocity = DASH_VELOCITY_GROUND;
    end

    -- Load Animation:

    local ANimTrack : AnimationTrack =  Humanoid.Animator:LoadAnimation(Animations.FLIP)
    ANimTrack.Looped = false
    ANimTrack:Play()

    RootPart.AssemblyLinearVelocity += (Additive_vector * UsableVelocity);

    -- Load Cooldowm, Camera Effects and VFX.

    Dash.CameraAnimation(self.Player)
    Dash.Cooldown(self.Player, self)
    Dash.Replicate("Execute", {

        Player = self.Player

    })

end

return Dash