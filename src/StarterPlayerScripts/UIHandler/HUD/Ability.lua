
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

local Ability : Element = {}
Ability.__index = Ability;
Ability._OFFSET = CFrame.new(0.6, -0.6, -1.15) * CFrame.Angles(0, math.rad(-190), 0)
Ability._BASEPART = game.ReplicatedStorage.UI.Ability;

local Camera : Camera? = workspace.CurrentCamera;
local Tweenservice = game:GetService("TweenService");
local Configs = require(script.Parent.Parent.Configs)

function Ability.New() : Element

	local self = {}

	self._name = "Ability";
	self._element = Ability._BASEPART
	self._runnerThread = nil;
	self._offset = Ability._OFFSET
	

	return setmetatable(self, Ability)

end

function Ability:Deploy()

	local element : Part = self._element;
	local newElement = element:Clone()
	newElement.Parent = workspace;

	self._element = newElement;
	self._element._OFFSET.Value = Ability._OFFSET;

	self._runnerThread = task.spawn(function()
		game:GetService("RunService").RenderStepped:Connect(function()
			self._element.CFrame = Camera.CFrame * self._element._OFFSET.Value;
		end)
	end)
end

function Ability:Parse(Action, Arguments)
	if Action == "Cooldown" then
		self:Cooldown(Arguments)
	end

	if Action == "AbilityChanged" then
		self:ChangeAbility(Arguments)
	end
end

function Ability:ChangeAbility(kwargs : {})

	local _ability = kwargs.Ability;
	self._element.GUI.Label.Text = Configs.Abilities[kwargs._ability].DisplayName;
	
end

function Ability:SetAdornee()
	
end

function Ability:Cooldown(Arguments : {number})
	
	local GUI : SurfaceGui = self._element.GUI;
	local Icon : ImageLabel = GUI.Icon;
	local Cooldown : UIGradient = Icon.Cooldown;
	local text_cooldown : TextLabel = GUI.Cooldown;
		
	Cooldown.Offset = Vector2.new(0, 0)
	
	task.spawn(function()
		for i = Arguments.Duration, 0, -1 do
		
			text_cooldown.Text = tostring(i)
	
			if i == 0 then
				text_cooldown.Text = ""	
			end
	
			task.wait(1)
	
		end
	end)
	
	local CDT = Tweenservice:Create(Cooldown, TweenInfo.new(Arguments.Duration), {Offset = Vector2.new(0, 1)})
	--local Tween = Tweenservice:Create(self._element, TweenInfo.new(0.25), {Size = Vector3.new(0.15, 0.15, 0)})
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

return Ability;