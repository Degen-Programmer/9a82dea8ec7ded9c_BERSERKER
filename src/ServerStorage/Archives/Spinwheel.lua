local Spinwheel = {}

local Angles = {
    
    [1] = 12150; -- 2k coins;
    [2] = 12195; -- wooden sword;
    [3] = 12240; -- 500 coinz;
    [4] = 12285; -- Endsword;
    [5] = 12330; -- Da reaping
    [6] = 12375; -- 1k coinz;
    [7] = 12420; -- 1500 coins;
    [8] = 12465; -- Dodge roll;
 
}

local player = game.Players.LocalPlayer;

local playerGui = player.PlayerGui
local FrameSpinwheel = playerGui.Root.Frames.Spinwheel;

local Signal = require(game.ReplicatedStorage.Packages.GoodSignal)
local Net = require(game.ReplicatedStorage.Packages.BridgeNet2);
local Configs = require(script.Parent.Configs);
local handler = require(script.Parent.Handler)


local Bridge = Net.ReferenceBridge("ServerCommunication");
local TweenService = game:GetService("TweenService");

local Actions = FrameSpinwheel.Actions;
local Wheel = FrameSpinwheel.Wheel;
local Close = FrameSpinwheel.Close;
local SpinShop = FrameSpinwheel.SpinShop;
local SpinCount = FrameSpinwheel.Spins;

task.spawn(function()

    Close.Activated:Connect(function()
            
        FrameSpinwheel.Visible = false;
        handler.EnableHUD()

    end)

    playerGui.Root.Buttons.Spinwheel.Activated:Connect(function()

        FrameSpinwheel.Visible = true;
        handler.DisableHUD()

    end)

    -- // Buying Spins:

    for _, v : ImageLabel in ipairs(SpinShop.Container:GetChildren()) do
        if v:IsA("ImageLabel") then
            
            local BuyBtn : ImageButton = v.Buy;
            BuyBtn.Activated:Connect(function()

                local Product = v.Name;

                Bridge:Fire({

                    Request = "Spinwheel";
                    Action = "ProcessTransaction";
                    Arguments = {

                        ["Product"] = Product;

                    };
                })

            end)

        end
    end
end)

function ShakeBtn(Btn)

    local RunServ = game:GetService("RunService")
    local Pos = Btn.Position

    local connection;

    task.delay(0.15, function()

        connection:Disconnect()
        Btn.Position = Pos;

    end)

    connection = RunServ.RenderStepped:Connect(function(dt)

    	local BobbleX = (math.cos(os.clock() * 40) * 0.03)
    	local BobbleY = math.abs(math.sin(os.clock() * 30) * 0.05)
    	Btn.Position = Pos + UDim2.new(BobbleX,0,BobbleY,0)

    end)
end

task.spawn(function()
    Actions.Spin.Activated:Connect(function()

        Bridge:Fire({

            Request = "Spinwheel";
            Action = "Process";
            Arguments = {};

        })

    end)
end)

local max_rotations = 0.15;

function Spinwheel.Spin(Kwargs)

    print(Kwargs)
    
    local index = Kwargs.Index;
    local finalAngle = Angles[index]

    Wheel.Rotation = 0;
    TweenService:Create(Wheel, TweenInfo.new(5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {Rotation = finalAngle}):Play();

end

function Spinwheel.Reject()
    print("Rejected.")

    ShakeBtn(Actions.Spin)
end

function Spinwheel.UpdateSpins(Kwargs)

    local Newspins = Kwargs.Spins;
    SpinCount.Text = tostring(Newspins).." Spins Left."
    
    print("Updated Spins.")
    
end

return Spinwheel