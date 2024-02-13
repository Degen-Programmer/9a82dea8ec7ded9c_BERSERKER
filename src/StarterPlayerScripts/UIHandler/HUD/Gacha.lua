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
local Bezier = require(Rep.Packages.Bezier)
local Effects = require(script.Parent.Parent.Parent.Utilities.Effects)

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
            self:PlayX5Animation()
        end)
    end
end

function Gacha:InitCardOffset()
    self._RUNNER_THREAD = task.spawn(function()
        game:GetService("RunService").RenderStepped:Connect(function()
            for _, v in ipairs(self._cards) do
                
                v.CFrame = Camera.CFrame * v._OFFSET.Value

            end
        end)
    end)
end

local eulerangles = CFrame.fromEulerAnglesXYZ(0, math.rad(180), 0)

function Gacha:PlayX5Animation()

    require(script.Parent.PlayerHUD).HUD:Hide()
    
    local _positions = {

        [1] = CFrame.new(-0.8, 0, -1.2);
        [2] = CFrame.new(-0.4, 0, -1.2);
        [3] = CFrame.new(0, 0, -1.2);
        [4] = CFrame.new(0.4, 0, -1.2);
        [5] = CFrame.new(0.8, 0, -1.2);

    }

    self._cards = {}

    local ColorCorrection = Instance.new("ColorCorrectionEffect")
    ColorCorrection.Parent = Camera;
    ColorCorrection.TintColor = Color3.new(103, 104, 101)

    -- // remove all other cards:

    task.spawn(function()
        for _, v in ipairs(self._elements) do
            Tweenservice:Create(v, TweenInfo.new(.25), {Size = Vector3.new(0, 0, 0)}):Play()
        end
    end)

    task.wait(.25)

    task.spawn(function()
        for i = 1, 5 do

            local element : Part = game.ReplicatedStorage.UI.BaseCard;
            local newElement = element:Clone()
    
            newElement.Parent = workspace;
            self._cards[i] = newElement;    
            
            newElement._OFFSET.Value = CFrame.new(-0.8, 0, -0.9) * CFrame.fromEulerAnglesXYZ(0, math.rad(180), 0);
            newElement.Name = tostring(i);
    
        end
    end)

    -- // initialize the render loop:

    self:InitCardOffset()
    
    -- // tween the parts positions:

    for i = 1, 5 do
        
        local element = self._cards[i]
        
        local endPos = self._positions[i].Position
        local startPos = Vector3.new(-0.8, 0, -0.9)

        local points = Bezier.new({

            startPos;
            Vector3.new(0, Random.new():NextInteger(-1, 1), Random.new():NextInteger(-1, -3));
            endPos

        })

        task.spawn(function()
            for x = 1, 50 do
                
                local decastleJauPos = points:DeCasteljau(x / 50)
                local cf = CFrame.new(decastleJauPos) * eulerangles

                Tweenservice:Create(element._OFFSET, TweenInfo.new(0.01), {Value = cf}):Play()
                task.wait(0.01)

                if x == 50 then 
                    print("EMITTING")
                    Effects._Emit(element.VFX)
                end 

            end
        end)

        task.wait(.25)
        
    end
end

return Gacha