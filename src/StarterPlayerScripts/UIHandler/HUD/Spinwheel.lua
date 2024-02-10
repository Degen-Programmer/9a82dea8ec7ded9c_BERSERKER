type SPINWHEEL = {

    _name : string;
    
    _GUI : {

		Close : ImageButton;
		Spins : TextLabel;
		Wheel : ImageLabel;
		Actions : {

			Buy : ImageButton;
			Spin : ImageButton;

		};

		SpinShop : {Container : {

		}; Title : ImageLabel}

    }

}

local Spinwheel : SPINWHEEL = {}
Spinwheel.__index = Spinwheel
Spinwheel.INDEXES = {

}

local Camera : Camera? = workspace.CurrentCamera;
local Tweenservice = game:GetService("TweenService");

local UIS = game:GetService("UserInputService")
local Rep = game:GetService("ReplicatedStorage")

local Net = require(Rep.Packages.BridgeNet2)
local Bridge = Net.ReferenceBridge("ServerCommunication");

local Playergui = game.Players.LocalPlayer.PlayerGui
local SCREENGUI : Frame = Playergui.Root.Spinwheel;

local Utils = script.Parent.Parent.Parent.Utilities

local camFX = require(Utils.Camera)
local Effects = require(Utils.Effects)

function Spinwheel.New()

	local self : SPINWHEEL = {}
	
	self._name = "Spinwheel";
	self._element = game.ReplicatedStorage.UI.Spinwheel
	self._runnerThread = nil;
	self._offset = self._element._OFFSET.Value;
	self._GUI = SCREENGUI

	return setmetatable(self, Spinwheel)
	
end

function Spinwheel:_init_runner_thread()

	local bounds = Vector2.new(-0.5, 0.5)
	local initialoffset = self._offset;

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

function Spinwheel:_cancel_runner_thread()
	task.cancel(self._runnerThread)
end

function Spinwheel:Open()

	local plrHud = require(script.Parent.PlayerHUD).HUD
	plrHud:Hide()
    
	self:_init_runner_thread()
	SCREENGUI.Visible = true;

	self:SetAdornee()

end

function Spinwheel:Close()
    
end

function Spinwheel:SetAdornee()
    Playergui.Spinwheel.Adornee = self._element;
end

function Spinwheel:SpinAnimation(Index)
	
	local Base3dOBject : Part = self._element;

	for _, v in ipairs(Base3dOBject.Spinning:GetChildren()) do
		v.Enabled = true;
	end

	camFX.ShakeSustained("Vibration", 4.5)

	self._element.Size = Vector3.new(0, 0, 0)
	self._GUI.Wheel.Visible = true
	self._GUI.Wheel.Rotation = 0;

	Tweenservice:Create(self._GUI.Wheel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0), {Size = UDim2.new(1.2, 0, 1.2, 0)}):Play()
	
	local MainTween = Tweenservice:Create(self._GUI.Wheel, TweenInfo.new(5), {Rotation = 3600 * 2})
	MainTween:Play()

	task.delay(4, function()
		for _, v in ipairs(Base3dOBject.Spinning:GetChildren()) do
			v.Enabled = false;
		end
	end)

	task.delay(4.75, function()
		for _, v in ipairs(Base3dOBject.Released:GetChildren()) do
			v:Emit(v:GetAttribute("EmitCount"))
		end
	end)

	MainTween.Completed:Connect(function(playbackState)

		self._GUI.Wheel.Visible = false;
		self._element.Size = Vector3.new(1, 1, 0)

	end)
end

function Spinwheel:Deploy()

    local element : Part = self._element;
	local newElement = element:Clone()
	newElement.Parent = workspace;

    self._element = newElement
    self._offset = self._element._OFFSET.Value;
    Playergui.Spinwheel.Adornee = self._element

	local Buy = self._GUI.Actions.Buy;
	local Close = self._GUI.Close;
	local Spin = self._GUI.Actions.Spin;

	Spin.Activated:Connect(function(inputObject, clickCount)
		Bridge:Fire({

			Request = "Spinwheel";
			Action = "ProcessRequest";
			Arguments = {};

		})
	end)

end

return Spinwheel