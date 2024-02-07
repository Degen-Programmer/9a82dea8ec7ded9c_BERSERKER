local Commands = {}

local Net = require(game.ReplicatedStorage.Packages.BridgeNet2)
local UI_Updater = Net.ReferenceBridge("UI_Updater")

local player = game.Players.LocalPlayer
local gui = player.PlayerGui
local Root = gui:WaitForChild("Root")

local Frames = Root.Frames;
local Voting = Frames.Voting;
local WinnerDisplayer = Frames.Winner;
local Status = Frames.Status;

local TweenService = game:GetService("TweenService")

function Commands.Countdown()
    
    local countdown = Frames.Countdown;
    
    for i = 5, 1, -1 do

        print(i)

        countdown.Text = tostring(i);

        local _t = TweenService:Create(countdown, TweenInfo.new(0.85), {Size = UDim2.new(1.533, 0, 0.383, 0), TextTransparency = 1;}):Play()

        task.wait(0.85) 

        countdown.Text = ""
        countdown.TextTransparency = 0;
        countdown.Size = UDim2.new( 1.042, 0, 0.371, 0)

    end
end

function Commands.UpdateStatus(kwargs)

    local sizedDownSize = UDim2.new(0.868, 0, 0.092, 0)

    TweenService:Create(Status, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true, 0), {

        Size = sizedDownSize

    }):Play()

    local StatusText = kwargs.Status
    local Timer = kwargs.Timer

    Status.Text.Text = StatusText

    if Timer then

        local Time = kwargs.Time

        while Time > 0 do

            Status.Text.Text = StatusText .. Time
            task.wait(1)
            Time = Time - 1

        end
    end
end

function Commands.StartVoting(kwargs)

    task.delay(8, function()
        Voting.Visible = false
    end)

    local connections = {}

    -- tween the voting menu:

    Voting.Visible = true
    Voting.Size = UDim2.new(0, 0, 0, 0)

    TweenService:Create(Voting, TweenInfo.new(0.5), {

        Size = UDim2.new(0.925, 0,0.237, 0)

    }):Play()

    -- // ui effects:

    local VoteButtons = Voting:GetChildren()
    
    for _, v in ipairs(VoteButtons) do
        if v:IsA("ImageButton") then
            
            local c1 = v.MouseEnter:Connect(function()

                local to_tween = UDim2.new(0.294, 0,0.461, 0)
                TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {

                    Size = to_tween

                }):Play()

            end)

            local c2 = v.MouseLeave:Connect(function()

                local to_tween = UDim2.new(0.279, 0,0.438, 0)
                TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {

                    Size = to_tween

                }):Play()

            end)

            table.insert(connections, c1)
            table.insert(connections, c2)

            v.Activated:Connect(function()
                for _, c in ipairs(connections) do
                    c:Disconnect()
                end

                for _, n in ipairs(VoteButtons) do
                    if n:IsA("ImageButton") then
                        n.Active = false;
                        if n == v then return 
                    else
                        n.ImageTransparency = 0.7
                        end
                    end
                end
            end)
        end
    end
end

function Commands.DisplayWinner(kwargs)

    local winner = kwargs.Winner
    
    -- tween the winner frame:

    WinnerDisplayer.Visible = true
    WinnerDisplayer.Size = UDim2.new(0, 0, 0, 0)

    TweenService:Create(WinnerDisplayer, TweenInfo.new(0.5), {

        Size = UDim2.new(0.622, 0, 0.1, 0)

    }):Play()

    task.wait(3)

    TweenService:Create(WinnerDisplayer, TweenInfo.new(0.5), {

        Size = UDim2.new(0, 0, 0, 0)

    }):Play()
    
end

UI_Updater:Connect(function(kwargs)

    local Command = kwargs.Command
    local Arguments = kwargs.Arguments

    Commands[Command](Arguments)
    
end)