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
local CardPacks = workspace.Map.CardPacks;

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
    self._elements = {}

	return setmetatable(self, Gacha)

end

function Gacha:SetAdornee()
    
end

function Gacha:_init_runner_thread()

    local bounds = Vector2.new(-0.5, 0.5)
	self:SetAdornee()

	self._runnerThread = task.spawn(function()
		game:GetService("RunService").RenderStepped:Connect(function()

			local screenSize = Camera.ViewportSize;
			local mousePos = (UIS:GetMouseLocation() - screenSize / 2) * (2 / screenSize)

			local yaw = CFrame.fromEulerAnglesXYZ(

				math.rad(mousePos.Y * bounds.Y),
				math.rad(mousePos.X * bounds.X),
				0

			)
			
			self._element.CFrame = Camera.CFrame * self._element._OFFSET.Value * yaw;
			
		end)
	end)
end

function Gacha:Open()

    self:_init_runner_thread()
    Tweenservice:Create(self._element, TweenInfo.new(.25), {Size = Vector3.new(0.379, 0.532, 0.001)}):Play()

end

function Gacha:Deploy()

    local element : Part = game.ReplicatedStorage.UI.Card;
	local newElement = element:Clone()
	newElement.Parent = workspace;

    self._elements[1] = element;
    self._element = self._elements[1]

    for _, part : Part in ipairs(self._container:GetChildren()) do
        
        local Activator : ProximityPrompt = part:FindFirstChild("Activator")
        Activator.UIOffset = Vector2.new(10000000001, 10000000001)

        Activator.Triggered:Connect(function(playerWhoTriggered)
            self:Open()
        end)

        Activator.PromptShown:Connect(function(playerWhoTriggered)
            Tweenservice:Create(part._R, TweenInfo.new(0.15), {Size = UDim2.new(6, 0, 7, 0)}):Play() 
        end)

        Activator.PromptHidden:Connect(function(playerWhoTriggered)
            Tweenservice:Create(part._R, TweenInfo.new(0.15), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        end)
    end

end

return Gacha