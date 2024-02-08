local Dash = {}

local TweenService = game:GetService("TweenService")
local AssetService = game:GetService("AssetService")

local rep = game:GetService("ReplicatedStorage")

local Packages = rep.Packages;
local Brigenet = require(Packages.BridgeNet2)
local Bezier = require(Packages.Bezier)

local utils_folder = script.Parent.Parent.Utilities
local CameraUtil, EffectsUtil = require(utils_folder.Camera), require(utils_folder.Effects)

local Modules = rep.Modules
local Assets = rep.Assets;

function Dash.Cleanup(self)
    
end

function Dash.Execute(Kwargs : {})

    local Player : Player = Kwargs.Player;
    local Character = Player.Character;
    local Humanoid = Character.Humanoid
    local RootPart = Character.HumanoidRootPart;

    local self = {}

    -- // SFX:



    -- // VFX:

    EffectsUtil.Clone("Dash", "SmokeCloud", function(SmokeCloud : Part)
        
        SmokeCloud.CFrame = RootPart.CFrame * CFrame.new(0, -2, 0);
        EffectsUtil._Emit(SmokeCloud)

        self.SmokeCloud = SmokeCloud;

    end)

    Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function(new_state : Enum.Material)
        print("NEW MATERIAL!")
    end)
end

function Dash.CameraAnimation()
    
end

return Dash