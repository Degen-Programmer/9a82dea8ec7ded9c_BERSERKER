--[[

    Description: User Teleportes in their movement direction.

]]

local Teleport = {}

-- // Configs:

local TELEPORT_DISTANCE = 20
local TELEPORT_COOLDOWN = 5;

-- // Packages:

local Rep = game:GetService("ReplicatedStorage")
local Ts = game:GetService("TweenService")

local Packages = Rep.Packages
local Assets = Rep.Assets
local Animations = Assets.Animations;

local Net = require(Packages.BridgeNet2);
local ReplicationManager = Net.ReferenceBridge("ClientReplicator")
local HUD = Net.ReferenceBridge("HUD")

function Teleport.Cleanup()
    
end

-- // Function that fires only to the executor, Indicating that their cooldown as begun.

function Teleport.Cooldown(Player : Player, self)

    task.delay(TELEPORT_COOLDOWN, function()
        self.AbilitiesDebounce = false;
    end)

    HUD:Fire(Net.Players{Player}, {

        Element = "Ability";
        Action = "Cooldown";
        Arguments = {Player = Player, Duration = TELEPORT_COOLDOWN}

    })
end

-- // Function that replicates the ability to all clients and loads VFX/SFX/Camera Anims and stuff.:

function Teleport.Replicate(Action : string, Arguments : {})
    ReplicationManager:Fire(Net.AllPlayers(), {

        Request = "Teleport";
        Action = Action;
        Arguments = Arguments;

    })
end

-- // Function that fires only to the executor, playing some camrea animation on their screen.

function Teleport.CameraAnimation(Player : Player)
    ReplicationManager:Fire(Net.Players({Player}), {

        Request = "Teleport";
        Action = "CameraAnimation";
        Arguments = {Player = Player};

    })
end

-- // Main Function that executes the ability:

function Teleport.Execute(kwargs : {}, ...)
    
    local self = kwargs._self;

    local Character : Model = self.Character;
    local Humanoid : Humanoid = Character.Humanoid;
    local RootPart : Part = Character.Torso;

    -- // Raycast to see the location of where to teleport the player:

    local raycast = RaycastParams.new()
    raycast.FilterDescendantsInstances = {Character}
    raycast.FilterType = Enum.RaycastFilterType.Exclude
    raycast.IgnoreWater = true;

    local worldRootRaycast : RaycastResult = workspace:Raycast(

        RootPart.CFrame.Position,
        RootPart.Position * (RootPart.Position + RootPart.CFrame.LookVector * TELEPORT_DISTANCE),
        raycast

    )

    if not worldRootRaycast then return end

    if worldRootRaycast.Instance then

        print("UwU \n Hru")

        local Position : CFrame = RootPart.CFrame * CFrame.new(RootPart.CFrame.LookVector * TELEPORT_DISTANCE)
        Ts:Create(RootPart, TweenInfo.new(0.25), {CFrame = Position}):Play()

    else

        local Position : CFrame = RootPart.CFrame * CFrame.new(RootPart.CFrame.LookVector * TELEPORT_DISTANCE)
        Ts:Create(RootPart, TweenInfo.new(0.25), {CFrame = Position}):Play()

    end
end

return Teleport