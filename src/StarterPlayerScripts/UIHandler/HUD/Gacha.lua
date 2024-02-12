--!nocheck

type GACHA = {

     ---------------------------------------------------

    -- // Base Properities inherited from ELEMENT:

    ---------------------------------------------------

    _name : string;
    _GUI : {

    };

     ---------------------------------------------------

    -- // Base Methods inherited from ELEMENT:

    -----------------------------------------------------

    New : () -> nil; -- creates a new Gacha class object. called only once.

    CreateBlur : () -> nil;  -- creates a blur in the camera background. saves the blur as (self._blur)

    Open : (Menu : string) -> nil;  -- Opens the menu selected (Weapons/Abilities...etc)

    Close : () -> nil;  -- Gets the currently open meny and closes it.
    
    Deploy : () -> nil;  -- creates a new _element instance. called only once.

    ParseRequest : (kwargs : {}) -> (any?); -- parses any request incoming from the server.

    ---------------------------------------------------

    -- // Unique class-specific methods:

    -----------------------------------------------------

    PostRequest : () -> nil; --

}

--{6, 0},{7, 0}

local Gacha = {}
Gacha.__index = Gacha

local Playergui = game.Players.LocalPlayer.PlayerGui
local CardPacks = workspace.Maps.CardPacks;

local Camera : Camera? = workspace.CurrentCamera;
local Tweenservice = game:GetService("TweenService");

local UIS = game:GetService("UserInputService")
local Rep = game:GetService("ReplicatedStorage")

local Net = require(Rep.Packages.BridgeNet2)
local Bridge = Net.ReferenceBridge("ServerCommunication");

function Gacha.New()

    local self = {}

    self._name = "Gacha";
    self._container = CardPacks
	return setmetatable(self, Gacha)

end

function Gacha:SetAdornee()
    
end

function Gacha:Deploy()

    for _, part : Part in ipairs(self._container) do
        
        local Activator : ProximityPrompt = part:FindFirstChild("Activator")
        Activator.UIOffset = Vector2.new(10000000001, 10000000001)

        Activator.Triggered:Connect(function(playerWhoTriggered)
            print("Uwu") 
        end)
    end

end

return Gacha