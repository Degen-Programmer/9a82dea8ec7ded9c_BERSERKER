
--!nocheck

type Stamina = {

	-- // Constructor and methods:

	New : (BasePart : BasePart) -> {};
	Deploy : () -> BasePart;
	Cooldown : (Duration : number) -> nil;

	Name : string;
	Element : BasePart | Part | Model;
	RunnerThread : thread;
	PositionalOffset : CFrame;	

}

local Stamina : Stamina = {}
Stamina.__index = Stamina;
Stamina._OFFSET = CFrame.new(0, -0.65, -1.20) * CFrame.Angles(0, math.rad(180), 0)
Stamina._BASEPART = game.ReplicatedStorage.UI.Stamina;

local Camera : Camera? = workspace.CurrentCamera;
local Tweenservice = game:GetService("TweenService");

function Stamina.New() : Stamina

	local self = {}

	self._name = "Stamina";
	self._element = Stamina._BASEPART
	self._runnerThread = nil;
	self._offset = Stamina._OFFSET

	return setmetatable(self, Stamina)

end

function Stamina:Parse(Action, Arguments)
	if Action == "DecreaseBoost" then
		self:DecreaseBoost(Arguments)
	end
	if Action == "RefillStamina" then
		self:RefillStamina(Arguments)
	end
end

function Stamina:Deploy()

	local element : Part = self._element;
	local newElement = element:Clone()
	newElement.Parent = workspace;

	self._element = newElement;
	local OFFSET = self._element._OFFSET.Value;
	
	self._runnerThread = task.spawn(function()
		game:GetService("RunService").RenderStepped:Connect(function()
			
			self._element.CFrame = Camera.CFrame * self._element._OFFSET.Value
			
		end)
	end)
end

function Stamina:DecreaseBoost(Arguments)

	local Max = 5;

	local GUI : SurfaceGui = self._element.GUI;
	local Bar : Frame = GUI.Bar;

	local NewSize = UDim2.new((Arguments.Boosts / Max) * 1, 0, 0.25, 0);
	Tweenservice:Create(Bar, TweenInfo.new(0.25), {Size = NewSize}):Play();

end

function Stamina:SetAdornee()
	--Playergui.Trading.Adornee = self._element;
end

function Stamina:RefillStamina(Arguments)

	local GUI : SurfaceGui = self._element.GUI;
	local Bar : Frame = GUI.Bar;

	local NewSize = UDim2.new(1, 0, 0.25, 0);
	Tweenservice:Create(Bar, TweenInfo.new(0.25), {Size = NewSize}):Play();

end

return Stamina;