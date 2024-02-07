
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

local M1 : Element = {}
M1.__index = M1;
M1._OFFSET = CFrame.new(-0.6, -0.6, -1.15) * CFrame.Angles(0, math.rad(190), 0)
M1._BASEPART = game.ReplicatedStorage.UI.M1;

local Camera : Camera? = workspace.CurrentCamera;
local Tweenservice = game:GetService("TweenService");
--local Spring = require(script.Parent.Parent.Spring);

function M1.New() : Element
	
	local self = {}
	
	self._name = "M1";
	self._element = M1._BASEPART
	self._runnerThread = nil;
	self._offset = M1._OFFSET
	--self._spring = Spring.new(1, 1, 1, 1, 1, 1)
	
	return setmetatable(self, M1)
	
end

function M1:SetAdornee()
	
end

function M1:Deploy()
	
	local element : Part = self._element;
	local newElement = element:Clone()
	newElement.Parent = workspace;
	
	self._element = newElement;
	
	self._runnerThread = task.spawn(function()
		game:GetService("RunService").RenderStepped:Connect(function()
			
			self._element.CFrame = Camera.CFrame * M1._OFFSET
			
		end)
	end)
end

function M1:Parse(Action, Arguments)
	if Action == "Cooldown" then
		self:Cooldown(Arguments)
	end
end

function M1:Cooldown(Arguments : {number})
	
	local GUI : SurfaceGui = self._element.GUI;
	local Icon : ImageLabel = GUI.Icon;
	local Cooldown : UIGradient = Icon.Cooldown;
	
	Cooldown.Offset = Vector2.new(0, 0)
	
	local CDT = Tweenservice:Create(Cooldown, TweenInfo.new(Arguments.Duration), {Offset = Vector2.new(0, 1)})
	--local Tween = Tweenservice:Create(self._element, TweenInfo.new(0.25), {Size = Vector3.new(0.30, 0.15, 0.001)})
	--local ImageTransparency = Tweenservice:Create(Icon, TweenInfo.new(0.25), {ImageTransparency = 0.5}):Play()
	
	CDT:Play()
	--Tween:Play()
	
	CDT.Completed:Connect(function()
		
		--local ImageTransparency = Tweenservice:Create(Icon, TweenInfo.new(0.25), {ImageTransparency = 0}):Play()
		--local Readjust = Tweenservice:Create(self._element, TweenInfo.new(0.25), {Size = Vector3.new(0.3, 0.3, 0)})
		--Readjust:Play()
		
		for _, particle_emitter : ParticleEmitter in ipairs(self._element.CooldownEnded:GetDescendants()) do
			if particle_emitter:IsA("ParticleEmitter") then
				particle_emitter:Emit(particle_emitter:GetAttribute("EmitCount"))
			end
		end
	end)
end

return M1;