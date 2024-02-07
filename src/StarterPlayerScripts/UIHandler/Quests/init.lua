local TweenService = game:GetService("TweenService")
local Quest = {}
local Configs = require(script.QuestConfigs);

local player = game.Players.LocalPlayer
local gui = player.PlayerGui;

local QFrame = gui.Root.Frames.Quests;
local Container = QFrame.Container;
local Expiration = QFrame.Expire;

local Signal = require(game.ReplicatedStorage.Packages.GoodSignal)
local Net = require(game.ReplicatedStorage.Packages.BridgeNet2);

local Bridge = Net.ReferenceBridge("ServerCommunication");

function Quest.New(Kwargs : {})

    print(Kwargs)

    local Name = Kwargs.Name;
    local Data = Kwargs.Quest;
    
    local New = Container.Spare:Clone();
    New.Parent = Container;
    New.Name = Name;
    New.Visible = true;

    task.wait(1)

    local cnfgs = Configs[Name]
    print(cnfgs, Name)

    New:GetChildren()[1].Text = cnfgs.Title;
    New:GetChildren()[3].Text = "0/"..cnfgs.Progress;

    New.Claim.MouseEnter:Connect(function()
        player.Character:FindFirstChild("Hover"):Play()
        TweenService:Create(New.Claim, TweenInfo.new(0.2), {Size =  UDim2.new(0.183, 0,0.314, 0)}):Play()
    end)

    New.Claim.MouseLeave:Connect(function()
        TweenService:Create(New.Claim, TweenInfo.new(0.2), {Size =  UDim2.new(0.16, 0,0.455, 0)}):Play()
    end)

    New.Claim.Activated:Connect(function()
                
        print("activated.")
        player.Character:FindFirstChild("Click"):Play()

        Bridge:Fire({

            Request = "Quest";
            Action = "Claim";
            Arguments = {Quest = New.Name;}

        })
    end)
end

function Quest.Update(Kwargs)
    
    local Progress = Kwargs.Progress; 
    local Requirement = Kwargs.Requirement; 
    local Name = Kwargs.Name;

    local QuestContainer = QFrame.Container:WaitForChild(Name);
    QuestContainer.Progress.Bar.Size = UDim2.new(Progress/Requirement, 0, 2.172, 0);
    QuestContainer.Count.Text = tostring(Progress).."/"..tostring(Requirement);

end

task.spawn(function()

    local function Format(Int)
        return string.format("%02i", Int)
    end
    
    local function convertToHMS(Seconds)
        
        local Minutes = (Seconds - Seconds % 60) / 60
        Seconds = Seconds - Minutes * 60

        local Hours = (Minutes - Minutes % 60) / 60
        Minutes = Minutes - Hours * 60
        
        return Format(Hours)..":"..Format(Minutes)..":"..Format(Seconds)
    end

    local hours = os.date("%I")
    local minutes = os.date("%M")
    local seconds = os.date("%S")

    local hours_to_sec = (hours - 1) * 3600; -- // hours - 1 because the minutes will make up for it.
    local minutes_to_sec = minutes * 60;
    local DtoS = 11 * 3600 - (hours_to_sec + minutes_to_sec + seconds);

    while task.wait(1) do

        DtoS = DtoS - 1;

        local new = convertToHMS(DtoS)
        Expiration.Text = "Expires in: ".. new;

    end
end)

return Quest