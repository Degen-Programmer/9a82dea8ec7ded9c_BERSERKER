--!nocheck

local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local HUD = {}
HUD.__index = HUD
HUD.CurrentHud = nil;

type Element = {

	Name : string;
	Element : BasePart | Part | Model;
	RunnerThread : thread;
	PositionalOffset : CFrame;	

}

export type HUD = {
	
	New : () -> {}; -- // Constructor, only called when the player loads.
	
	Elements : {Element};
	ElementOffsets : {CFrame};
	RunnerThreads : {thread};
	
	PlayEffect : (Element : string, Effect : string) -> nil;
	Reset : () -> nil;
	Deploy : () -> nil;
	
}

local ui_elements : Folder = game.ReplicatedStorage.UI;
local utils = require(script.Parent.Parent.Utilities.Effects)

function HUD.New(Elements : {string})
	
	local self = {}
	self.Elements = {}
	
	for _, element_name : string in ipairs(Elements) do
		
		local constructor = require(script:FindFirstChild(element_name))
		local _element : Element = constructor.New()
		
		self.Elements[_element._name] = _element;
		
	end
	
	return setmetatable(self, HUD);
	
end

function HUD:Deploy()

	for k : string, v : Element in pairs(self.Elements) do
		v:Deploy();
	end

	local UIS = game:GetService("UserInputService");

	UIS.InputBegan:Connect(function(input, gameProcessedEvent)
		if not gameProcessedEvent then
			if input.KeyCode == Enum.KeyCode.W then
				
				TweenService:Create(workspace.CurrentCamera, TweenInfo.new(.25), {FieldOfView = 71}):Play()

			end

			if input.KeyCode == Enum.KeyCode.S then
				
				TweenService:Create(workspace.CurrentCamera, TweenInfo.new(.25), {FieldOfView = 69}):Play()

			end
		end
	end)

	UIS.InputEnded:Connect(function(input, gameProcessedEvent)
		if not gameProcessedEvent then
			if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then
				TweenService:Create(workspace.CurrentCamera, TweenInfo.new(.25), {FieldOfView = 70}):Play()
			end
		end
	end)
end

function HUD:ParseRequest(Arguments)

	print("HUD", Arguments)

	local Element : string = Arguments.Element;
	local Action : string = Arguments.Action;
	local Arguments = Arguments.Arguments;

	print(self.Elements)

	if Element ~= "HUD" then
		print("Parsing from element handler")
		self.Elements[Element]:Parse(Action, Arguments);
	else

		if Action == "Reload" then
			task.delay(3, function()
				print("RELOADING.")

				for k, v in pairs(self.Elements) do
					v:SetAdornee()
				end
			end)
		end

		if Action == "Cleanup" then
			self:CleanupEliminations(Arguments)
		end

		if Action == "NewRound" then
			self:NewRound(Arguments);
		end

		if Action == "Elimination" then
			self:Elimination(Arguments)
		end

		if Action == "Parry" then
			self:Parry();
		end
	end
end

function HUD:Parry()

	local runnerThread;

	local element = ui_elements.Parry:Clone()
	element.Parent = workspace;

	local Offset = CFrame.new(0, -0.60, -1.70) * CFrame.Angles(0, math.rad(180), 0)

	utils._Emit(element);

	task.delay(1.5, function()
		
		task.cancel(runnerThread)
		element:Destroy()

	end)

	runnerThread = task.spawn(function()
		game:GetService("RunService").RenderStepped:Connect(function(dt : number)
			
			element.CFrame = workspace.CurrentCamera.CFrame * Offset;

		end)
	end)

end

function HUD:Hide()

	TweenService:Create(self.Elements.M1._element._OFFSET, TweenInfo.new(0.25), {Value = CFrame.new(-0.8, -1.3, -1.15) * CFrame.fromEulerAnglesXYZ(0, math.rad(180), 0)}):Play()
	TweenService:Create(self.Elements.Ability._element._OFFSET, TweenInfo.new(0.25), {Value = CFrame.new(0.8, -1.3, -1.15) * CFrame.fromEulerAnglesXYZ(0, math.rad(180), 0)}):Play()
	TweenService:Create(self.Elements.Stamina._element._OFFSET, TweenInfo.new(0.25), {Value = CFrame.new(0, -1.3, -1.15) * CFrame.fromEulerAnglesXYZ(0, math.rad(180), 0)}):Play()

end

function HUD:Unhide()

	TweenService:Create(self.Elements.M1._element._OFFSET, TweenInfo.new(0.25), {Value =  CFrame.new(-0.6, -0.6, -1.15) * CFrame.Angles(0, math.rad(190), 0)}):Play()
	TweenService:Create(self.Elements.Ability._element._OFFSET, TweenInfo.new(0.25), {Value = CFrame.new(0.6, -0.6, -1.15) * CFrame.Angles(0, math.rad(-190), 0)}):Play()
	TweenService:Create(self.Elements.Stamina._element._OFFSET, TweenInfo.new(0.25), {Value = CFrame.new(0, -0.65, -1.20) * CFrame.Angles(0, math.rad(180), 0)}):Play()

end

function HUD:CleanupEliminations()
	self.Elements.Eliminations:Cleanup();
end

function HUD:Elimination(Arguments)
	
	print("UwU ? ")

	local runnerThread;

	local element = ui_elements.Elimination:Clone()
	element.GUI.Container:FindFirstChild("Name").Text = "You Eliminated "..Arguments.Name;
	element.Parent = workspace;

	local CFROFFSET : CFrameValue = element:FindFirstChild("Offset")
	CFROFFSET.Value *= CFrame.Angles(0, math.rad(180), 0)

	task.delay(3, function()
		task.cancel(runnerThread)
		TweenService:Create(CFROFFSET, TweenInfo.new(.25), {Value = CFrame.new(0, 1.3, -1.7) * CFrame.Angles(0, math.rad(180), 0)}):Play();

		task.delay(.25, function()
			element:Destroy();
		end)
	end)

	runnerThread = task.spawn(function()
		game:GetService("RunService").RenderStepped:Connect(function(dt : number)
			
			element.CFrame = workspace.CurrentCamera.CFrame * CFROFFSET.Value;

		end)
	end)
end

function HUD:NewRound(Arguments)

	print("_CALLED")

	if self.Elements.Round then

		print("Cleaned up.")

		task.cancel(self.Elements.Round._waiterThread)
		self.Elements.Round.PrematureCleanup()
	end

	local Berserker : string = Arguments.Berserker;
	local Champion : string = Arguments.Champion;

	local Text_Berserker : Part = ui_elements.BerserkerChosen:Clone();
	local Text_Champion : Part = ui_elements.ChampionChosen:Clone();
	local VsText :  Part = ui_elements.Vs:Clone();

	Text_Berserker.Parent, Text_Champion.Parent, VsText.Parent = workspace, workspace, workspace

	local BerserkerOffset : CFrameValue = Text_Berserker.Offset
	local ChampionOffset : CFrameValue = Text_Champion.Offset;
	local VsOffset : CFrameValue = VsText.Offset;

	self.Elements.Round = {

		_runnerThread = nil;
		_runnerConnection = nil;
		_waiterThread = nil;
		
		_berserker = Berserker;
		_champion = Champion;

		_BerserkerElement = Text_Berserker;
		_ChampionElement = Text_Champion;
		_VsText = VsText;

	}

	self.Round = self.Elements.Round;

	self.Round.PrematureCleanup = function()

		task.cancel(self.Round._runnerThread);

		self.Round._BerserkerElement:Destroy();
		self.Round._ChampionElement:Destroy();
		self.Round._VsText:Destroy();

		self.Elements.Round = nil;

	end

	self.Round._ChampionElement.GUI.Container:FindFirstChild("Name").Text = Champion;
	self.Round._BerserkerElement.GUI.Container:FindFirstChild("Name").Text = Berserker;

	local AngularOFfset : CFrame = CFrame.Angles(0, math.rad(180), 0)
	local camera = workspace.CurrentCamera;

	self.Round._waiterThread = task.delay(5, function()
		self.Round.PrematureCleanup()
	end)

	self.Round._runnerThread = task.spawn(function()
		self.Round._runnerConnection = RunService.RenderStepped:Connect(function(deltaTime : number)
			
			self.Round._VsText.CFrame = camera.CFrame * VsOffset.Value * CFrame.Angles(0, math.rad(180), 0)
			self.Round._ChampionElement.CFrame = camera.CFrame * ChampionOffset.Value * CFrame.Angles(0, math.rad(180), 0);
			self.Round._BerserkerElement.CFrame = camera.CFrame * BerserkerOffset.Value * CFrame.Angles(0, math.rad(180), 0);

		end)
	end)
end



return HUD