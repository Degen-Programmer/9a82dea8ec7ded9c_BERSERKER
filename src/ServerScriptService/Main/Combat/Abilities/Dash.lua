--[[

    Description: User dashes in their movement direction.

]]

local Dash = {}

-- // Configs:

local DASH_DURATION = 0.3;
local DASH_DISTANCE = 15;
local DASH_VELOCITY = 200

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

function Dash.Cooldown()
    
end

-- // Main Function that executes the ability:

function Dash.Replicate(Action : string, Arguments : {})
    ReplicationManager:Fire(Net.AllPlayers(), {

        Request = "Dash";
        Action = Action;
        Arguments = Arguments;

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
        UsableVelocity = 100;
    else
        UsableVelocity = DASH_VELOCITY;
    end

    local ANimTrack : AnimationTrack =  Humanoid.Animator:LoadAnimation(Animations.FLIP)
    ANimTrack.Looped = false
    ANimTrack:Play()
    
    RootPart.AssemblyLinearVelocity += (Additive_vector * UsableVelocity);
    Dash.Replicate("Execute", {})

end

return Dash