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
local cam_effects = require(script.Parent.Parent.Parent.Utilities.Camera)
local vertex_manipualtion = require(script.Parent.Parent.Parent.Utilities.VertexManipulation)

local Mouse = game.Players.LocalPlayer:GetMouse()

print(vertex_manipualtion)

local Bridge = Net.ReferenceBridge("ServerCommunication");

function Gacha.New()

    local self = {}

    self._name = "Gacha";
    self._container = CardPacks
    self._elements = {}
    self._element = nil;
    self._positions = {

        CFrame.new(-1, 0, -1.2);
        CFrame.new(-0.5, 0, -1.2);
        CFrame.new(0, 0, -1.2);
        CFrame.new(0.5, 0, -1.2);
        CFrame.new(1, 0, -1.2);

    }

    self._enterConnections = {}
    self._leaveConnections = {}
    self._activateConnections = {}

    self._isOpening = false;

	return setmetatable(self, Gacha)

end

function Gacha:SetAdornee()
    --[[for _, v in ipairs(self._elements) do
        
        local adorner = Playergui.Cards:FindFirstChild(v.Name)
        adorner.Adornee = v;

    end]]
end



function Gacha:_init_runner_thread()

    local bounds = Vector2.new(-2, 2)
    local currentTarget

	self._runnerThread = task.spawn(function()
		game:GetService("RunService").RenderStepped:Connect(function(t)
			for U, v in ipairs(self._elements) do
                v.CFrame = Camera.CFrame * v._OFFSET.Value;
            end

            -- // these 7 lines of code below are more fucked than Mia Khalifa's cunt. fix this bs later i cant deal with this fucking cancer inducing function rn

            if self._elements[tonumber(Mouse.Target.Name)] then
                
                local currentTarget = self._elements[tonumber(Mouse.Target.Name)];

                for _, v in ipairs(self._elements) do
                    if v == currentTarget and self._isOpening == false then
                       Tweenservice:Create(v, TweenInfo.new(.15), {Size = Vector3.new(0.478, 0.113, 0.754)}):Play()
                    elseif v ~= currentTarget and self._isOpening == false then
                        Tweenservice:Create(v, TweenInfo.new(.15), {Size = Vector3.new(0.456, 0.108, 0.719)}):Play()
                    end
                end
            end
		end)
	end)
    
    Mouse.Button1Down:Connect(function()
        if self._elements[tonumber(Mouse.Target.Name)] then
            
            local element = self._elements[tonumber(Mouse.Target.Name)]
            local offset = element._OFFSET;

            self:StartAnimation(Mouse.Target)

        end
    end)
end

local eulerAngles = CFrame.fromEulerAnglesXYZ(math.rad(90), math.rad(180), 0)

function Gacha:StartAnimation(clicked)

    self._isOpening = true;
    require(script.Parent.PlayerHUD).HUD:Hide()

    for _, v in ipairs(self._elements) do
        
        local element : Part = v;
        local offset : CFrameValue = element._OFFSET;

        -- // resize all other parts.

        if element ~= clicked then
            print("RESIZING....")
            Tweenservice:Create(element, TweenInfo.new(.15), {Size = Vector3.new(0, 0, 0)}):Play();
        end
    end

    -- // bring the card in front of the screen:

    local card : Part = clicked;
    local cardOffset : CFrameValue = card._OFFSET;

    -- // Tween:

    Tweenservice:Create(cardOffset, TweenInfo.new(.25), {Value = CFrame.new(0, 0, -0.9) * eulerAngles}):Play()
    Tweenservice:Create(card, TweenInfo.new(.2), {Size = Vector3.new(0.507, 0.12, 0.8)}):Play()

    task.delay(0.1, function()
        Effects._Emit(card.Appear)
        for _, v in ipairs(card.Linger:GetChildren()) do
            v.Enabled = true;
        end       
        task.wait(.1)
    end)

    -- // Effects:

    task.delay(1, function()
        Effects._Emit(card.Appear)
        print("Emitted.")

        -- // progress with the animation
        Tweenservice:Create(cardOffset, TweenInfo.new(.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {Value = CFrame.new(0, 0.1, -1) * eulerAngles}):Play()
        task.wait(.25)
        Tweenservice:Create(cardOffset, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {Value = CFrame.new(0, -0.35, -1.5) * eulerAngles}):Play()
        task.wait(1)
        Tweenservice:Create(cardOffset, TweenInfo.new(.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {Value = CFrame.new(0, -0.3, -1) * eulerAngles}):Play()

    end)
    
end

function Gacha:_init_sin_thread(element)

    self._sineThreads = {}

    local len = 2 * math.pi;

    self._sineThreads[element.Name] = task.spawn(function()
        game:GetService("RunService").Stepped:Connect(function(t)
            
            local zOffset = CFrame.new(0, 0, math.sin(t) * 0.0002)
            element._OFFSET.Value *= zOffset

        end)
    end)
end

function Gacha:Open()

   -- self:SetAdornee()

    task.spawn(function()

        for i = 1, 5 do
            
            local element : Part = self._elements[i]
            local offset : CFrameValue = element._OFFSET;

            offset.Value = self._positions[i] * CFrame.fromEulerAnglesXYZ(math.rad(90), math.rad(180), 0)

            local mesh = element.EditableMesh;
            self:_init_sin_thread(element)

            task.spawn(function()
                local VERTEX_DATA =  vertex_manipualtion.VerticesData_Class.CreateVerticesData(element, mesh)
                vertex_manipualtion.VerticesData_Class.AppearFromPoint(VERTEX_DATA, Vector3.new(0, -100, 0), 0.5, 15)
            end)

            task.wait(0.1)

        end
    end)

    self:_init_runner_thread()
end

function Gacha:Deploy()

    for i = 1, 5 do

        local element : Part = game.ReplicatedStorage.UI.Pack;
	    local newElement = element:Clone()
	    newElement.Parent = workspace;

        self._elements[i] = newElement;    

        local editableMesh = game:GetService("AssetService"):CreateEditableMeshAsync(newElement.MeshId)
        editableMesh.Parent = newElement;
        
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

        self._enterConnections[v.Name] = v.ImageButton.MouseEnter:Connect(function()
            Tweenservice:Create(offset, TweenInfo.new(.25), {Value = offset.Value * CFrame.new(0, 0.05, 0)}):Play()
        end)

        self._leaveConnections[v.Name] = v.ImageButton.MouseLeave:Connect(function()
            Tweenservice:Create(offset, TweenInfo.new(.25), {Value = self._positions[tonumber(v.Name)] * eulerRotation}):Play()
        end)

        self._activateConnections[v.Name] = v.ImageButton.Activated:Connect(function()
            self:PlayX5Animation()
        end)
    end
end

return Gacha