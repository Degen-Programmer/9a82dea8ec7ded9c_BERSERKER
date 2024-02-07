local Gacha = {}
local cam = workspace.CurrentCamera;

local Size = UDim2.new(0.272, 0, 0.587, 0)
local Positions = {

    [1] = UDim2.new(0.053, 0, 0.503, 0);
    [2] = UDim2.new(0.349, 0, 0.504, 0);
    [3] = UDim2.new(0.649, 0,0.504, 0);
    [4] = UDim2.new(0.947, 0,0.503, 0);

}

local Container = workspace.Map.Cases;
local player = game.Players.LocalPlayer;

local playerGui = player.PlayerGui
local Root = playerGui.Root.Frames.Gacha;

local Signal = require(game.ReplicatedStorage.Packages.GoodSignal)
local Net = require(game.ReplicatedStorage.Packages.BridgeNet2);
local Configs = require(script.Parent.Configs);

local AFKBRIDGE = Net.ReferenceBridge("AFK")

local Bridge = Net.ReferenceBridge("ServerCommunication");
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService");

-- // Create connections to spin:

task.spawn(function()

    task.wait(2)

    local Character = player.Character;

    Character.Humanoid.Died:Connect(function()

        Character:SetAttribute("IsGachaing", false);
        cam.CameraType = Enum.CameraType.Custom;

    end)

    for index, case in ipairs(Container.Premium:GetChildren()) do
        if case:IsA("Part") then
            Gacha.HandleActivation(case, Container.Premium)
        end
    end

    for index, case in ipairs(Container.Standard:GetChildren()) do
        if case:IsA("Part") then
            Gacha.HandleActivation(case, Container.Standard)
        end
    end
end)

function Gacha.HandleActivation(case, CaseFolder)

    local Activator : ProximityPrompt = case:FindFirstChild("Activator");
    local rarityTab = workspace.Map.Rarities:FindFirstChild(CaseFolder.Name):FindFirstChild(case.Name).Rarities

    Activator.PromptShown:Connect(function(prompt)

        print("Prompt Shown")
        
        TweenService:Create(rarityTab, TweenInfo.new(.25), {Size = UDim2.new(5, 0, 6, 0)}):Play()
        TweenService:Create(case.GUI, TweenInfo.new(.25), {Size = UDim2.new(3, 0, 3, 0)}):Play()
        
    end)

    Activator.PromptHidden:Connect(function(prompt)

        print("Prompt Hidden")

        TweenService:Create(case.GUI, TweenInfo.new(.25), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(rarityTab, TweenInfo.new(.25), {Size = UDim2.new(0, 0, 0, 0)}):Play()

    end)

    Activator.Triggered:Connect(function()
        Activator.Enabled = false;
        Bridge:Fire({
            Request = "Gacha";
            Action = "Process";
            Arguments = {
                Case = case.Name; 
            }
        })
    end)
end

function Gacha.Reject()
    for index, Case in ipairs(Container:GetDescendants()) do
        if Case:IsA("Part") then

            local Activator: ProximityPrompt = Case:FindFirstChild("Activator");
            Activator.Enabled = true;

        end
    end
end

local Positions = {
	
	Vector3.new(-8, 0, 0);
	Vector3.new(-5, 0, -3.5);
	Vector3.new(0, 0, -5);
	Vector3.new(5, 0, -3.5);
	Vector3.new(8, 0, 0);
	
}

local function emit(part)

	for _, v in ipairs(part:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			task.spawn(function()
				v:Emit(v:GetAttribute("EmitCount"))
				task.wait()
			end)
		end
	end
end


function Gacha.Spin(Kwargs)

    local thread;
    AFKBRIDGE:Fire(true)

    thread = task.spawn(function()

        local Item = Kwargs.Item;

        local translation;

        if string.find(Kwargs.Case, "Premium") then
            print("BAAAKAA")
            translation = string.split(Kwargs.Case, "Premium")[2];
        else
            print("NOP!")
            translation = Kwargs.Case;
        end

        local SelectedConfig = Configs[translation][Item];
        print(Item, SelectedConfig);

        local mouse = player:GetMouse();

        local CurrentBatch = {}

        local CorrespondingContainer = Configs[translation];
        local temptbl = {}

        for k, v in pairs(CorrespondingContainer) do
            table.insert(temptbl, k)
        end

        local connection = nil;
        local cards = {}
        local basePoses = {};
        local CFD = Instance.new("Folder", workspace)
        CFD.Name = "Cards"

        cam.CameraType = Enum.CameraType.Scriptable;
        cam.CFrame = CFrame.new(110, 110, 110)

        task.wait(0.4)
    
	    for i = 1, 5 do

            local card = game.ReplicatedStorage.Cards:FindFirstChild(Kwargs.CardType):Clone()
	    	card.Parent = CFD;

            local GUI = card.GUI;
            local Icon = GUI.Icon;
            local Chance, Name, Rarity = GUI.Chance, GUI:FindFirstChild("Name"), GUI.Rarity;

            local CONFIG;

            if i == 1 then

                CONFIG = SelectedConfig

                Icon.Image = SelectedConfig.Icon;
                Chance.Text = SelectedConfig.Chance;
                Rarity.Text = SelectedConfig.Rarity;
                Name.Text = SelectedConfig.DisplayName;

            else

                local rand = math.random(1, #temptbl)
                local selected = temptbl[rand]

                CONFIG = CorrespondingContainer[selected]

                Icon.Image = CONFIG.Icon;
                Chance.Text = CONFIG.Chance;
                Rarity.Text = CONFIG.Rarity;
                Name.Text = CONFIG.DisplayName;

            end

	    	card.Position = cam.CFrame.Position + cam.CFrame.LookVector * 10 + Positions[i];
	    	card.CFrame = CFrame.lookAt(card.Position, cam.CFrame.Position)
	    	card.Orientation = Vector3.new(card.Orientation.X, 0, card.Orientation.Z)
	    	card.Size = Vector3.new(0, 0, 0);
	    	card.Name = tostring(i);
        
	    	local t = TweenService:Create(card, TweenInfo.new(.25), {Size = Vector3.new(4.416, 6.607, 0.001), Orientation = Vector3.new(0, 180, 0)})
	    	t:Play()
        
	    	t.Completed:Connect(function()
            
	    		card.FX.Position = card.Position + Vector3.new(0, 0, -0.25)
            
	    		emit(card.FX)
	    		TweenService:Create(card, TweenInfo.new(.25), {Size = Vector3.new(3.877, 5.8, 0.001)}):Play()
            
	    	end)
        
	    	table.insert(cards, card)
	    	task.wait(0.2)
        
	    end

        task.wait(0.5)
    
	    for i = 1, #cards do
        
	    	local card = cards[i];
	    	local base = cards[3];
        
	    	table.insert(basePoses, card.Position)
        
	    	local offset =  base.Position;
	    	local alpha = i * (math.pi * 2) / 5;
        
	    	local vector = Vector3.new(math.sin(alpha) * 5, 0, math.cos(alpha) * 5) + offset
        
	    	TweenService:Create(card, TweenInfo.new(.35), {Position = vector; Orientation = Vector3.new(0, 0, 0)}):Play()
        
	    end
    
	    task.wait(.1);
    
	    local cycles = 10;
    
	    while task.wait(.2) do
        
	    	cycles = cycles - 1
        
	    	for i = 1, #cards do
	    		local card = cards[i];
	    		local nextcard = cards[i + 1]
	    		local base = cards[3];
            
	    		if i == 5 then
	    			nextcard = cards[1]
	    		end
	    		TweenService:Create(card, TweenInfo.new(.35), {Position = nextcard.Position}):Play()
	    	end
        
	    	if cycles == 0 then
	    		break
	    	end
	    end
    
	    task.wait(0.35)

	    for i = 1, #cards do
	    	local card = cards[i];
	    	local pos = basePoses[3];
	    	TweenService:Create(card, TweenInfo.new(.35), {Position = pos}):Play()
        
	    end
    
	    task.wait(0.1)
    
	    for i = 1, #cards do
        
	    	local card = cards[i];
	    	local pos = basePoses[i];
        
	    	task.spawn(function()
            
	    		TweenService:Create(card, TweenInfo.new(.35), {Position = pos, Size = Vector3.new(4.416, 6.607, 0.001)}):Play()
	    		task.wait(.35)
            
	    		TweenService:Create(card, TweenInfo.new(.35), {Position = pos, Size = Vector3.new(3.877, 5.8, 0.001)}):Play()
            
	    	end)
	    end

        local outerThread = nil;

        task.spawn(function()
            outerThread = game:GetService("UserInputService").InputBegan:Connect(function(i,gpe)
                if not gpe and i.UserInputType == Enum.UserInputType.MouseButton1 then
                    if mouse.Target.Parent == workspace.Cards and mouse.Target.Locked == false then

                        for _, v in ipairs(cards) do
                            v.Locked = true;
                        end

                        connection:Disconnect()

                        local card = mouse.Target;
                        local pos = cam.CFrame.Position + cam.CFrame.LookVector * 8
                        local rotateClone = game.ReplicatedStorage.Rotations:FindFirstChild(SelectedConfig.Rarity):Clone()
                        rotateClone.Name = "Rotate"
                        
                        local GUI = card.GUI;
                        local Icon = GUI.Icon;
                        local Chance, Name, Rarity = GUI.Chance, GUI:FindFirstChild("Name"), GUI.Rarity;

                        rotateClone.Parent = card.FX.Attachment;
                        card.FX.Attachment.Rotate.Enabled = true;

                        TweenService:Create(card, TweenInfo.new(.5), {Position = pos; Orientation = Vector3.new(0, 540, 0); Size = Vector3.new(4.145, 6.201, 0.001)}):Play()
                        TweenService:Create(card.FX, TweenInfo.new(.5), {Position = cam.CFrame.Position + cam.CFrame.LookVector * 8.25}):Play()

                        Icon.Image = SelectedConfig.Icon;
                        Chance.Text = SelectedConfig.Chance;
                        Rarity.Text = SelectedConfig.Rarity;
                        Name.Text = SelectedConfig.DisplayName;
                        Rarity.TextColor3 = Configs.TextColor3[SelectedConfig.Rarity];
                        Chance.TextColor3 = Configs.TextColor3[SelectedConfig.Rarity];

                        task.delay(.5, function()
                            emit(card.FX)
                            TweenService:Create(card, TweenInfo.new(.25), {Size = Vector3.new(3.877, 5.8, 0.001)}):Play()
                        end)			

                        for _, v in ipairs(cards) do
                            if v.Name ~= mouse.Target.Name then 
                                TweenService:Create(v, TweenInfo.new(.25), {Orientation = Vector3.new(0, 180, 0)}):Play()
                            end
                        end

                        task.wait(4);

                        AFKBRIDGE:Fire(false)
                        cam.CameraType = Enum.CameraType.Custom
                        Gacha.Reject()

                        for _, v in ipairs(cards) do
                            v:Destroy()
                        end

                        CFD:Destroy()

                        print(outerThread)
                        outerThread:Disconnect()

                    end
                end
            end)
        end)
    
	    local currentTarget = nil;
    
	    connection = game:GetService("RunService").RenderStepped:Connect(function()
        
	    	local target = mouse.Target;
        
	    	if target then
                if target.Parent == workspace.Cards and currentTarget == nil then
                
                    target.FX.ParticleEmitter.Enabled = true;

                    TweenService:Create(target, TweenInfo.new(.15), {Size = Vector3.new(4.416, 6.607, 0.001)}):Play()
                    currentTarget = target

                end

                if target ~= currentTarget and target.Parent == workspace.Cards then

                    TweenService:Create(currentTarget, TweenInfo.new(.15), {Size = Vector3.new(3.877, 5.8, 0.001)}):Play()
                    currentTarget.FX.ParticleEmitter.Enabled = false;
                    currentTarget = nil

                end

                if target.Parent ~= workspace.Cards then
                    for _, v in ipairs(cards) do
                        v.FX.ParticleEmitter.Enabled = false;
                        TweenService:Create(v, TweenInfo.new(.15), {Size = Vector3.new(3.877, 5.8, 0.001)}):Play()
                    end
                end
            end
	    end)
    end)
end

return Gacha;