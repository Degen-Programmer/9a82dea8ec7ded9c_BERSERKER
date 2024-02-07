local TweenService = game:GetService("TweenService")
local HTTP = game:GetService("HttpService")
local Inventory = {}

Inventory.SelectedItemContainer = nil;
Inventory.SelectedItem = nil;
Inventory.CurrentlyOpen = nil;

local Player = game.Players.LocalPlayer;
local PlayerGui = Player:WaitForChild("PlayerGui");
local Character = Player.Character;

-- // Assets:

local Root = PlayerGui.Root;
local Buttons = Root.Buttons;
--local HUD = Root.HUD;
local Frames = Root.Frames;
--local Cash = HUD.Cash;

local Items = Frames.Items;
local ItemContainers = Items.Containers;
local Tabs = Items.Tabs;
local Desc = Items.ItemDescription;

local Signal = require(game.ReplicatedStorage.Packages.GoodSignal)
local Net = require(game.ReplicatedStorage.Packages.BridgeNet2);
local Configs = require(script.Parent.Configs);
local HUD = require(script.Parent.HUD)

local Click, Hover = Character:WaitForChild("Click"), Character:WaitForChild("Hover");
local ItemAdded = Signal.new();

local Bridge = Net.ReferenceBridge("ServerCommunication");

function Inventory.LoadCash(kwargs: {})

    --[[local newCash = kwargs.Cash;
    local cashValue = Cash:FindFirstChild("VALUE");

    TweenService:Create(Cash, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, true, 0), {Size = UDim2.new(0, 463,0, 71)}):Play()
    TweenService:Create(cashValue, TweenInfo.new(0.5), {Value = newCash}):Play();

    cashValue:GetPropertyChangedSignal("Value"):Connect(function()
        Cash.Label.Text = "$"..tostring(cashValue.Value);
    end)]]
end

function Inventory.LoadAbility(kwargs : {})


    print("Load ability called..")

    local newAbility = kwargs.Ability;

    print(newAbility)

    local Ability_div = HUD.CurrentHud.Elements.Ability._element.GUI;
    local _config = Configs.Abilities[newAbility];

    print(_config)

    --Ability_div:WaitForChild("Icon").Image = _config.Icon;
    Ability_div:WaitForChild("Label").Text = _config.DisplayName;
    
end

--[[

    A function that loads the player's inventory.

    @ function Inventory.Load()

        @ key            Data            {}                The data to load the inventory with.

]]

--[[

    A function that adds an item into a container of the inventory.

    @ function Inventory.AddItem()

        @ key        Item               string               The item to add into the inventory.
        @ key        Container          string               The container to add the item into.

]]

function Inventory.AddItem(kwargs: {})

    local Item = kwargs.Item;
    local Container = kwargs.Container;
    local nitem = nil;

    if string.find(Item, "_") then
        nitem = string.split(Item, "_")[1];
    else
        nitem = Item;
    end

    local CorrespondingContainer = ItemContainers:FindFirstChild(Container);

    if CorrespondingContainer then

        local Config  = Configs[Container][nitem]
        print(Config, nitem)

        local NewItem = CorrespondingContainer:FindFirstChild("Spare"):Clone();
        NewItem.Parent = CorrespondingContainer;
        NewItem.Visible = true;
        NewItem.Label.Text = Config.DisplayName; 
        NewItem.Icon.Image = Config.Icon;
        NewItem.Image = Configs.IconFrameAsset_ID[Config.Rarity];

        NewItem.Name = Item;
        ItemAdded:Fire();

    end
end

function Inventory.RemoveItem(kwargs: {})

    local Item = kwargs.Item;
    local Container = kwargs.Container;

    local CorrespondingContainer = ItemContainers:FindFirstChild(Container);

    if CorrespondingContainer then

        CorrespondingContainer:FindFirstChild(Item):Destroy();
        print("removed item..")

    end
end

function Inventory.EquipItem()
    task.spawn(function()

        local Connections = {};

         -- // Create Connections:

        local function make_connection()

            for _, Container in ipairs(ItemContainers:GetChildren()) do
                if Container and Container:IsA("ScrollingFrame") then

                    for _, Item in ipairs(Container:GetChildren()) do
                        if Item and Item:IsA("ImageButton") then
    
                            local ClickConnection = Item.Activated:Connect(function()

                                local Name;

                                Inventory.SelectedItem = Item.Name;

                                if string.find(Item.Name, "_") then
                                    Name = string.split(Item.Name, "_")[1];
                                else
                                    Name = Item.Name;
                                end

                                print(Inventory.SelectedItem, Name)

                                Inventory.SelectedItemContainer = Item.Parent.Name;

                                Click:Play()

                                local Config  = Configs[Container.Name][Name]
                                Desc.Frame.UIGradient.Color = Configs.FrameColor3[Config.Rarity];
                                Desc.ItemName.Text = Config.DisplayName;
                                Desc.Icon.Image = Config.Icon;
                                Desc.Rarity.UIGradient.Color = Configs.FrameColor3[Config.Rarity];
                                Desc.Rarity.Label.Text = Config.Rarity;

                                Desc.Description.Text = Config.Description;

                            end)
    
                            local MouseEnterConnection = Item.MouseEnter:Connect(function()

                                Hover:Play()
                                TweenService:Create(Item, TweenInfo.new(0.2), {ImageTransparency = 0.5}):Play()

                            end)
    
                            local MouseLeaveConnection = Item.MouseLeave:Connect(function()
                                TweenService:Create(Item, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
                            end)
    
                            table.insert(Connections, ClickConnection);
                            table.insert(Connections, MouseEnterConnection);
                            table.insert(Connections, MouseLeaveConnection);
    
                        end
                    end
                end
            end

            Desc.Equip.MouseEnter:Connect(function()
                Hover:Play();
                TweenService:Create(Desc.Equip, TweenInfo.new(0.2), {Size = UDim2.new(0.628, 0,0.118, 0)}):Play()
            end)

            Desc.Equip.MouseLeave:Connect(function()
                TweenService:Create(Desc.Equip, TweenInfo.new(0.2), {Size = UDim2.new(0.6, 0,0.106, 0)}):Play()
            end)

            Desc.Equip.Activated:Connect(function()
                if Inventory.SelectedItem ~= nil and Inventory.SelectedItemContainer ~= nil then

                    Bridge:Fire({

                        Request = "Inventory";
                        Action = "Equip";
    
                        Arguments = {
    
                            Item = Inventory.SelectedItem;
                            Container = Inventory.SelectedItemContainer;

                        }
                    })

                    print(Inventory.SelectedItem, Inventory.SelectedItemContainer)

                    Inventory.SelectedItem = nil
                    Inventory.SelectedItemContainer = nil

                end
            end)
        end

        ItemAdded:Connect(function()
            
            for _, Connection in ipairs(Connections) do
                if Connection and Connection.Connected then
                    Connection:Disconnect();
                end
            end

            make_connection();

        end)
    end)
end

task.spawn(function()

    print("Client/Handler/Inventory: LOADED Inventory.lua")

    Inventory.EquipItem();
    
    -- // switching tabs:

    for _, tab in ipairs(Tabs:GetChildren()) do
        if tab and tab:IsA("ImageButton") then

            local tabPos = tab.Position;

            -- // Mouse enter and mouse leave:

            tab.MouseEnter:Connect(function()
               Hover:Play();
               TweenService:Create(tab, TweenInfo.new(0.2), {Position = tabPos + UDim2.new(-0.05, 0, 0, 0)}):Play()
            end)

            tab.MouseLeave:Connect(function()
               TweenService:Create(tab, TweenInfo.new(0.2), {Position = tabPos}):Play()
            end)

            -- // on click:

            tab.Activated:Connect(function()

                Click:Play()
                
                
                for _, v in ipairs(ItemContainers:GetChildren()) do
                    if v and v:IsA("ScrollingFrame") then
                        v.Visible = false;
                    end
                end

                local InventoryFrame = ItemContainers:FindFirstChild(tab.Name);
                InventoryFrame.Visible = true;

            end)
        end
    end
end)

return Inventory;