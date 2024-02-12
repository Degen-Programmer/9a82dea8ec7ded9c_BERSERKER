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
    self._element = nil;
    self._positions = {

        CFrame.new(-0.8, 0, -1.2);
        CFrame.new(-0.4, 0, -1.2);
        CFrame.new(0, 0, -1.2);
        CFrame.new(0.4, 0, -1.2);
        CFrame.new(0.8, 0, -1.2);

    }


	return setmetatable(self, Gacha)

end

function Gacha:SetAdornee()
    for _, v in ipairs(self._elements) do
        
        local adorner = Playergui.Cards:FindFirstChild(v.Name)
        adorner.Adornee = v;

    end
end

function Gacha:_init_runner_thread()

    local bounds = Vector2.new(-0.5, 0.5)

	self._runnerThread = task.spawn(function()
		game:GetService("RunService").RenderStepped:Connect(function()

			for U, v in ipairs(self._elements) do
                local screenSize = Camera.ViewportSize;
			    local mousePos = (UIS:GetMouseLocation() - screenSize / 2) * (2 / screenSize)

			    local yaw = CFrame.fromEulerAnglesXYZ(

			    	math.rad(mousePos.Y * bounds.Y),
			    	math.rad(mousePos.X * bounds.X),
			    	0

			    )
            
			    v.CFrame = Camera.CFrame * v._OFFSET.Value * yaw;

            end
		end)
	end)
end

function Gacha:Open()

    self:SetAdornee()

    task.spawn(function()

        for i = 1, 5 do
            
            local element : Part = self._elements[i]
            local offset : CFrameValue = element._OFFSET;

            offset.Value = self._positions[i] * CFrame.fromEulerAnglesXYZ(0, math.rad(180), 0)
            Tweenservice:Create(element, TweenInfo.new(.25), {Size = Vector3.new(0.379, 0.532, 0.001)}):Play()

            task.wait(.1)

        end
    end)

    self:_init_runner_thread()
    
end

function Gacha:Deploy()

    for i = 1, 5 do

        local element : Part = game.ReplicatedStorage.UI.Card;
	    local newElement = element:Clone()
	    newElement.Parent = workspace;

        self._elements[i] = newElement;    
        
        newElement.Name = tostring(i)

    end

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

    local function resizeRest(item)
        for _, v in ipairs(self._elements) do
            task.spawn(function()
                if v.Name == "1" then return end
                print("FALSL")
            end)

            print(v.Name)
        end
    end

    resizeRest()

    for _, v : ImageButton in ipairs(Playergui.Cards:GetChildren()) do

        local element : Part = self._elements[tonumber(v.Name)]
        local offset : CFrameValue = element._OFFSET;

        local eulerRotation = CFrame.fromEulerAnglesXYZ(0, math.rad(180), 0)

        v.ImageButton.MouseEnter:Connect(function()
            Tweenservice:Create(offset, TweenInfo.new(.25), {Value = offset.Value * CFrame.new(0, 0.05, 0)}):Play()
        end)

        v.ImageButton.MouseLeave:Connect(function()
            Tweenservice:Create(offset, TweenInfo.new(.25), {Value = self._positions[tonumber(v.Name)] * eulerRotation}):Play()
        end)

        v.ImageButton.Activated:Connect(function()
            
        end)
    end
end

return Gacha