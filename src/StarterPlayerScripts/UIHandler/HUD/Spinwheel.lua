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

    ["1000 Coins"] = {
		Base2D_Rotation = 340
    };

    ["500 Coins"] = {

		Base2D_Rotation = 25;

    };

    ["Sword"] = {
		Base2D_Rotation = 295
    };

    ["300 Coins"] = {

		Base2D_Rotation = 70;

    };

    ["1 Coin"] = {

		Base2D_Rotation = 115;

    };

    ["Other Sword"] = {

		Base2D_Rotation = 160;

    };

    ["Aura"] = {
		Base2D_Rotation = 205;
    };

    ["Dash"] = {

		Base2D_Rotation = 250

    };
}

local Camera : Camera? = workspace.CurrentCamera;
local StarterGui = game:GetService("StarterGui")
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
	self._isSpinning = false;

	return setmetatable(self, Spinwheel)
	
end

function Spinwheel:_init_runner_thread()

	local bounds = Vector2.new(-0.5, 0.5)
	local initialoffset = self._offset;

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

function Spinwheel:_cancel_runner_thread()
	task.cancel(self._runnerThread)
	Playergui.Spinwheel.Adornee = nil;
end

function Spinwheel:Parse(Action, Arguments)

	if Action == "Spin" then
		self:SpinAnimation(Arguments)
	end

	print("GOT ARGUMNETNS", Arguments, Action)
	if Action == "UpdateSpins" then
		self:UpdateSpins(Arguments.Spins)
	end
end

function Spinwheel:UpdateSpins(NewSpins)
	self._GUI.Spins.Text = tostring(NewSpins)
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

	self._isSpinning = true;
	
	local Base3dOBject : Part = self._element;
	local Base2dRotation = self.INDEXES[Index.Index].Base2D_Rotation

	for _, v in ipairs(Base3dOBject.Spinning:GetChildren()) do
		v.Enabled = true;
	end

	camFX.ShakeSustained("Vibration", 4.5)

	self._element.Size = Vector3.new(0, 0, 0)
	self._element._OFFSET.Value = CFrame.new(-0.012, 0.057, -1.13) * CFrame.fromEulerAnglesXYZ(0, math.rad(180), 0)

	self._GUI.Wheel.Visible = true
	self._GUI.Wheel.Rotation = 0;
	self._GUI.Wheel.Size = UDim2.new(1, 0, 1, 0)

	Tweenservice:Create(self._GUI.Wheel, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0), {Size = UDim2.new(1, 0, 1, 0)}):Play()
	
	local MainTween = Tweenservice:Create(self._GUI.Wheel, TweenInfo.new(5), {Rotation = 3600 + Base2dRotation})
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

		self._isSpinning = false;

		self._GUI.Wheel.Visible = false;
		self._element.Size = Vector3.new(1, 1, 0)
		
		Tweenservice:Create(self._element, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, true, 0), {Size = Vector3.new(1.2, 1.2, 0)}):Play()
		self._element._OFFSET.Value *= CFrame.fromEulerAnglesXYZ(0, 0, math.rad(Base2dRotation))

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

	self._GUI.Close.Activated:Connect(function(inputObject, clickCount)
		
		if self._isSpinning == true then return end

		self:_cancel_runner_thread()
		self._GUI.Visible = false;
		
		local plrHud = require(script.Parent.PlayerHUD).HUD
		plrHud:Unhide()

	end)

	self._GUI.Actions.Buy.Activated:Connect(function(inputObject, clickCount)
		self._GUI.SpinShop.Visible = true;
	end)

	for _, v : ImageLabel in ipairs(self._GUI.SpinShop.Container:GetChildren()) do
		if v:IsA("ImageLabel") then  
			local BuyButton : ImageButton = v:FindFirstChild("Buy")

			BuyButton.Activated:Connect(function(inputObject, clickCount)

				Bridge:Fire({

					Request = "Products";
					Action = "ProcessPurchase";
					Arguments = {

						Product_Class = "Spinwheel";
						Product_Name = v.Name;

					}
				})

			end)
		end
	end
end

return Spinwheel