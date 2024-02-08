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
    local Humnaoid = Character.Humanoid
    local RootPart = Character.HumanoidRootPart;

    -- // SFX:

    -- // VFX:
    
end

function Dash.CameraAnimation()
    
end

return Dash