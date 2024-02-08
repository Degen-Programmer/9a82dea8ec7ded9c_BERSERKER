local Dash = {}

local TweenService = game:GetService("TweenService")
local AssetService = game:GetService("AssetService")
local HTTP = game:GetService("HttpService")

local rep = game:GetService("ReplicatedStorage")

local Packages = rep.Packages;
local Brigenet = require(Packages.BridgeNet2)
local Bezier = require(Packages.Bezier)

local utils_folder = script.Parent.Parent.Utilities
local CameraUtil, EffectsUtil = require(utils_folder.Camera), require(utils_folder.Effects)

local Modules = rep.Modules
local Assets = rep.Assets;
local DashAssets = Assets.FX.Dash

function Dash.Cleanup(self)
    for k, v in pairs(self) do
        v:Destroy()
        print("Destroyed : "..v.Name)
    end
end

function Dash.CreateSmokeCloud(RootPart, self)
    EffectsUtil.Clone("Dash", "SmokeCloud", function(SmokeCloud : Part)
        
        SmokeCloud.CFrame = RootPart.CFrame * CFrame.new(0, -2, 0);
        EffectsUtil._Emit(SmokeCloud)

        local UUID = HTTP:GenerateGUID(false)

        self[UUID] = SmokeCloud;

        return SmokeCloud

    end)
end

function Dash.Execute(Kwargs : {})

    local Player : Player = Kwargs.Player;
    local Character = Player.Character;
    local Humanoid = Character.Humanoid
    local RootPart = Character.HumanoidRootPart;

    local self = {}

    -- // SFX:

    local DashSound : Sound = DashAssets.SFX:Clone()
    DashSound.Parent = RootPart
    DashSound:Play();

    self.DashSound = DashSound

    -- // VFX:

    Dash.CreateSmokeCloud(RootPart, self)

    task.delay(0.45, function()
        Dash.CreateSmokeCloud(RootPart, self)
    end)

    task.delay(0.9, function()
        Dash.Cleanup(self)
    end)
end

function Dash.CameraAnimation()

    local PhaseIn = {Time = 0.25, FieldOfView = 65}
    local PhaseOut = {Time = 0.25, FieldOfView = 70}

    CameraUtil.ChangeFOV(PhaseIn)

    task.wait(0.25)

    CameraUtil.ChangeFOV(PhaseOut)

end

return Dash