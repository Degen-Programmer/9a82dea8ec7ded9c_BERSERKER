local Trading = {}

local Teams = game:GetService("Teams")
local TweenService = game:GetService("TweenService")
local HTTP = game:GetService("HttpService")
local Net = require(game.ReplicatedStorage.Packages.BridgeNet2);
local Handler = require(script.Parent.Handler);
local Configs = require(script.Parent.Configs);

local Player = game.Players.LocalPlayer;
local PlayerGui = Player:WaitForChild("PlayerGui");
local Character = Player.Character;

-- // Assets:

local Root = PlayerGui.Root;
local Frames = Root.Frames;

local PlayerList = Frames.PlayerList;
local Container = PlayerList.Container;
local Spare = Container.Spare

local Bridge = Net.ReferenceBridge("ServerCommunication");

task.spawn(function()

    local Items = Frames.Items;
    local Actions = Items.Actions;
    local TradeOpen = Actions.Trade;
    local DisableTrading = PlayerList.DisableTrading;

    -- // opening the player list window.

    TradeOpen.Activated:Connect(function()

        PlayerList.Visible = true;
        PlayerList.Size = UDim2.new(0, 0, 0, 0);

        TweenService:Create(PlayerList, TweenInfo.new(0.2), {
            Size = UDim2.new(3.111, 0, 1.98, 0)
        }):Play();

        TweenService:Create(Frames.Items, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play();

    end)

    -- // closing the player list window.

    PlayerList.Close.Activated:Connect(function()

        TweenService:Create(PlayerList, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 0, 0, 0);
        }):Play();

        TweenService:Create(Frames.Items, TweenInfo.new(0.2), {
            Size = UDim2.new(5.265, 0,2.443, 0)
        }):Play();

        task.wait(0.2)

        PlayerList.Visible = false;

    end)

    -- // disabling trading fot the player.

    DisableTrading.Activated:Connect(function()
        
        Bridge:Fire({

            Request = "Trading";
            Action = "ToggleTrading";
            Arguments = {}

        })

        -- // messy ass code, refactor later today...
        
        if DisableTrading.ImageColor3 == Color3.fromRGB(255, 0, 0) then

            DisableTrading.ImageColor3 = Color3.fromRGB(0, 255, 0);
            DisableTrading.ItemName.Text = "Enable Trading"

        elseif DisableTrading.ImageColor3 == Color3.fromRGB(0, 255, 0) then

            DisableTrading.ImageColor3 = Color3.fromRGB(255, 0, 0);
            DisableTrading.ItemName.Text = "Disable Trading"

        end
    end)
end)

-- // opening and closing.

Trading.PlayerAdded = (function(Args)

    local p = game.Players:FindFirstChild(Args.Player)

    if p == Player then

        print("SAME??!?!?!")

        if Args.IsTrading == true then
            PlayerList.DisableTrading.ImageColor3 = Color3.fromRGB(255, 0, 0);
        else
            PlayerList.DisableTrading.ImageTransparency = Color3.fromRGB(0, 255, 0);
        end

        return 

    else

        local new = Spare:Clone();
        new.Parent = Container;
        new.Visible = true;
        new.Name = p.Name;

        local userId = p.UserId
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size420x420
        local content, isReady = game:GetService("Players"):GetUserThumbnailAsync(userId, thumbType, thumbSize)

        new.PlayerIcon.Image = content
        new.PlayerName.Text = p.Name

        print(Args.IsTrading)

        if Args.IsTrading == true then
            new.InitiateTrade.ImageTransparency = 0;
        else
            new.InitiateTrade.ImageTransparency = 0.5;
        end

        --// Initiate a trade with that player.

        new.InitiateTrade.Activated:Connect(function()

            Bridge:Fire({

                Request = "Trading";
                Action = "InitiateTradeRequest";
                Arguments = {["Player"] = p.Name; UserId = p.UserId};
    
            })

        end)
    end
end)

local TradeRequest = Frames.TradeRequest;
local Description = TradeRequest.Desc;
local Accept = TradeRequest.Accept;
local Decline = TradeRequest.Decline;

local TradeTrafficNetwork = Net.ReferenceBridge("TradeTrafficNetwork");

function Trading.ProcessRequest(Kwargs)

    print("Req Recieved.")

    local Trader = Kwargs.Trader;
    local TradeRequest = Frames.TradeRequest;
    TradeRequest.Visible = true;

    -- // opening:

    TweenService:Create(TradeRequest, TweenInfo.new(0.25), {Size = UDim2.new(1.447, 0, 0.862, 0)}):Play();
    Description = Trader.." Has sent you a trade request!";

    -- // accepting:

    Accept.Activated:Connect(function()

        TradeTrafficNetwork:Fire({

            Request = "Result";
            Result = "Accepted";
            Arguments = {UUID = Kwargs.TransactionID}

        })

        TweenService:Create(TradeRequest, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0, 0)}):Play();

    end)

    Decline.Activated:Connect(function()

        TradeTrafficNetwork:Fire({
            
            Request = "Result";
            Result = "Declined";
            Arguments = {UUID = Kwargs.TransactionID}

        })

        TweenService:Create(TradeRequest, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0, 0)}):Play();

    end)
end

local TradeWindow = Frames.TradeWindow;
local Containers = TradeWindow.Containers;
local Tabs = TradeWindow.Tabs;
local TradeMenu = TradeWindow.Trade;
local Accept = TradeMenu.Accept;
local Decline = TradeMenu.Decline;
local YourOffer = TradeMenu.YourOffer;
local TheirOffer = TradeMenu.TheirOffer;

function Trading.InitTradeInventory()
    for _, v in ipairs(Frames.Items.Containers:GetChildren()) do
        if v:IsA("ScrollingFrame") then
            for _, Item in ipairs(v:GetChildren()) do

                local CorrespondingContainer = TradeWindow.Containers:FindFirstChild(v.Name);

                if Item:IsA("ImageButton") then

                    local NewItem = Item:Clone();
                    Item.Parent = CorrespondingContainer;

                end
            end
        end
    end

    print("Trade Inventory Initiated.")

end

function Trading.Initiate(Kwargs)

    local Session = {}

    YourOffer.PlayerName.Text = "Your Offer!"
    TheirOffer.PlayerName.Text = Kwargs.Player.."'s Offer!"

    Accept.Activated:Connect(function()

        TradeTrafficNetwork:Fire({
            
            Request = "Session";
            Action = "Accept";
            Arguments = {}

        })

        YourOffer.Check.Visible = true;
        
    end)

    function Session.Accept()
        TheirOffer.Check.Visible = true;
    end

    function Session.Decline()
        TheirOffer.Check.Visible = false
    end

    function Session.Terminate()

        TradeWindow.Visible = false;

        for _, v in ipairs(Containers:GetChildren()) do
            if v:IsA("ScrollingFrame") then
                for _, Item in ipairs(v:GetChildren()) do
                    if Item:IsA("ImageButton") then
                        Item:Destroy()
                    end
                end
            end
        end

        for _, v in ipairs(YourOffer.Container) do
            if v:IsA("ImageButton") then
                v:Destroy()
            end
        end

        for _, v in ipairs(TheirOffer.Container) do
            if v:IsA("ImageButton") then
                v:Destroy()
            end
        end
    end

    function Session.AddItem(Arguments)
       
        print("adding Item")

        local Item = Arguments.Item;
        local Container = Arguments.Container;
        local Offer = TradeMenu:FindFirstChild(Arguments.Offer);

        local item;

        if string.find(Item, "_") then
            item = string.split(Item, "_")[1]
        else
            item = Item;
        end

        print(Offer, Arguments.Offer)

        local _item = Offer.Container.Spare:Clone()
        local cfg = Configs[Container][item];

        _item.Parent = Offer.Container;
        _item.Visible = true;
        _item.Name = item;
        _item.Label.Text = cfg.DisplayName;
        _item.Icon.Image = cfg.Icon;
        _item.Image = Configs.IconFrameAsset_ID[cfg.Rarity];

        _item.Activated:Connect(function()

            print("SUE")

            TradeTrafficNetwork:Fire({
            
                Request = "Session";
                Action = "RemoveItem";
                Arguments = {Item = _item.Name}
    
            })

        end)
    end

    function Session.RemoveItem(Arguments)
        
        local Item = Arguments.Item;
        local Container = Arguments.Container;
        local Offer = TradeMenu:FindFirstChild(Arguments.Offer);

        Offer.Container:FindFirstChild(Item):Destroy();

        print("Removed.")

    end

    print("Initiating trade...")
    
    -- // Open Trade window:

    Handler.Reset();
    Trading.InitTradeInventory();

    TradeTrafficNetwork:Connect(function(Arguments)
        if Arguments.Request == "Session" then
            Session[Arguments.Action](Arguments.Arguments)
        end
    end)

    TradeWindow.Visible = true;

    for _, v in ipairs(Containers:GetChildren()) do
        if v:IsA("ScrollingFrame") then
            for _, Item in ipairs(v:GetChildren()) do
                if Item:IsA("ImageButton") then
                    Item.Activated:Connect(function()

                        TradeTrafficNetwork:Fire({
            
                            Request = "Session";
                            Action = "AddItem";
                            Arguments = {Item = Item.Name, Container = v.Name}
                
                        })

                    end)
                end
            end
        end
    end
end

return Trading