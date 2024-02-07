
--!nocheck

type Element = {
	
	-- // Constructor and methods:
	
	New : (BasePart : BasePart) -> {Element};
	Deploy : () -> BasePart;
	Cooldown : (Duration : number) -> nil;
	
	Name : string;
	Element : BasePart | Part | Model;
	RunnerThread : thread;
	PositionalOffset : CFrame;	

}

local Tweenservice = game:GetService("TweenService")

local Buttons : Element = {}
Buttons.__index = Buttons;
Buttons._BASEPART = game.ReplicatedStorage.UI.Buttons;

local Playergui = game.Players.LocalPlayer.PlayerGui
Buttons.__Buttons = Playergui.Buttons;
local PlayerHud = require(script.Parent.PlayerHUD)

local Camera : Camera? = workspace.CurrentCamera;
local Tweenservice = game:GetService("TweenService");
local UIS = game:GetService("UserInputService")

function Buttons.New() : Element
	
	local self = {}
	
	self._name = "Buttons";
	self._element = Buttons._BASEPART
	self._runnerThread = nil;
	self._HUD = PlayerHud.HUD;
    self._Buttons = nil;
    self._CurrentlyOpen = nil;

   -- self._SurfaceGUIs = Buttons.__Buttons
    
	return setmetatable(self, Buttons)
	
end

function Buttons:SetAdornee()
end

function Buttons:Deploy()
    for _, Activator : SurfaceGui in ipairs(Playergui.Buttons:GetChildren()) do

        Activator.Activated:Connect(function()
            if self._CurrentlyOpen == nil then

                local hudObject = PlayerHud.HUD.Elements[Activator.Name]:Open()
                self._CurrentlyOpen = hudObject;

            elseif self._CurrentlyOpen ~= nil then
                
                self._CurrentlyOpen:Close()
                self._CurrentlyOpen = nil

                local hudObject = PlayerHud.HUD.Elements[Activator.Name]:Open()
                self._CurrentlyOpen = hudObject;

            end
        end)

        Activator.MouseEnter:Connect(function()
            Tweenservice:Create(Activator, TweenInfo.new(.15), {Size = UDim2.new(0.054, 0, 0.11, 0)}):Play()
        end)

        Activator.MouseLeave:Connect(function()
            Tweenservice:Create(Activator, TweenInfo.new(.15), {Size = UDim2.new(0.047, 0, 0.112, 0)}):Play()
        end)
    end

end

function Buttons:Parse(Action, Arguments)
	
end


return Buttons;