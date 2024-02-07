local TweenService = game:GetService("TweenService")
local Fuse = {}
Fuse.IsFusing = false;
Fuse.SelectedItems = {};
Fuse.SelectionConnections = {};

local Player = game.Players.LocalPlayer;
local PlayerGui = Player:WaitForChild("PlayerGui");
local Character = Player.Character;
local buffer = false;

local Inventory = require(script.Parent.Inventory);
local Configs = require(script.Parent.Configs);
local Net = require(game.ReplicatedStorage.Packages.BridgeNet2)

-- // Assets:

local Root = PlayerGui.Root;
local Buttons = Root.Buttons;
--local HUD = Root.HUD;
local Frames = Root.Frames;
local Items = Frames.Items;
local FUSEMENU = Items.Fuse
local ItemContainers = Items.Containers;
local Actions = Items.Actions;

local Bridge = Net.ReferenceBridge("ServerCommunication");

-- // functions pertaining to the Fuse.SelectedItems dictionary.

function getOpenContainer()
    for _, Container in ipairs(ItemContainers:GetChildren()) do
        if Container:IsA("ScrollingFrame") then
            if Container.Visible == true then
                return Container;
            end
        end
    end
end

-- # get the index of an item in Entries:

function getEntry(Index)
    return FUSEMENU.Entries:FindFirstChild(Index)
end

-- # get the dictionary length. (# operator doesnt work cuz yes)

function get_dict_len(Table)

	local counter = 0 

	for _, v in pairs(Table) do
		counter =counter + 1
	end

	return counter
end

-- # get the base rarity of the fusing process.

function get_base_item(Table)    
    for k, v in pairs(Table) do
        return v;
    end
end

-- // A bunch of functions that change the color of UI Elements/make something visible or invisible.
-- // some of these functions are used more than once so u gotta follow DRY!!

-- # create an entry in the Fuse.SelectedItems dictionary.

function createEntry(Item, rarity)

    local Name;

    if string.find(Item.Name, "_") then
        Name = string.split(Item.Name, "_")[1];
    else
        Name = Item.Name;    
    end

    Fuse.SelectedItems[Item] = {
    
        Name = Item.Name;
        Rarity = rarity;
        BaseContainer = getOpenContainer().Name;

   }

   Item.ImageColor3 = Color3.new(0, 1, 0);

   local newEntry : ImageButton = FUSEMENU.Entries.Spare:Clone();
   local CONFIG = Configs[getOpenContainer().Name][Name];

   newEntry.Parent = FUSEMENU.Entries
   newEntry.Visible = true;
   newEntry.Name = Name;

   newEntry.Icon.Image = CONFIG.Icon;
   newEntry.Label.Text = CONFIG.DisplayName;
   newEntry.Image = Configs.IconFrameAsset_ID[CONFIG.Rarity]



end

-- # remove an entry from the Fuse.SelectedItems dictionary.

function removeEntry(Item)

    Fuse.SelectedItems[Item] = nil;
    Item.ImageColor3 = Color3.new(1, 1, 1);

    local entry = getEntry(Item.Name);
    entry:Destroy();

end

-- # enable selection and removal of items in the inventory.

function StartFusing()

    Fuse.IsFusing = true;

    Actions.Fuse.ItemName.Text = "Cancel"
    Actions.Fuse.ImageColor3 = Color3.new(1, 0, 0)
    
    TweenService:Create(Items, TweenInfo.new(0.2), {Position = UDim2.new(-0.209, 0, 0.372, 0)}):Play()

    FUSEMENU.Size = UDim2.new(0, 0, 0, 0)
    FUSEMENU.Visible = true;

    TweenService:Create(FUSEMENU, TweenInfo.new(0.2), {Size = UDim2.new(0.229, 0, 1.018, 0)}):Play()

    for _, btn in ipairs(Items.Tabs:GetChildren()) do
       if btn:IsA("ImageButton") then
            TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
       end
       
    end
end

function Fuse.FusedResult(Kwargs)

    for _, btn in ipairs(Items:GetDescendants()) do
        if btn:IsA("ImageButton") or btn:IsA("ImageLabel") then
           TweenService:Create(btn, TweenInfo.new(0.2), {ImageTransparency = 0.9}):Play()
        end

        if btn:IsA("TextButton") or btn:IsA("TextLabel") then
            TweenService:Create(btn, TweenInfo.new(0.2), {TextTransparency = 0.9}):Play()
        end
    end

    local Item, BaseContainer = Kwargs.Item, Kwargs.BaseContainer;
    local size = UDim2.new(1.454, 0,1.439, 0)

    local FuseResult = Root.Frames.FuseResult;
    FuseResult.Visible = true;

    local _config = Configs[BaseContainer][Item];
    TweenService:Create(FuseResult, TweenInfo.new(0.2), {Size = size}):Play()

    FuseResult.Icon.Image = _config.Icon;
    FuseResult.Label.Text = _config.DisplayName;
    FuseResult.Image = Configs.IconFrameAsset_ID[_config.Rarity]

    task.wait(1.5);

    TweenService:Create(FuseResult, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()

    for _, btn in ipairs(Items:GetDescendants()) do
        if btn:IsA("ImageButton") or btn:IsA("ImageLabel") then
            TweenService:Create(btn, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
        end

        if btn:IsA("TextButton") or btn:IsA("TextLabel") then
            TweenService:Create(btn, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
        end
    end
end

-- # exit fusing mode.

function StopFusing()

    Fuse.IsFusing = false;

    Actions.Fuse.ItemName.Text = "Fuse"
    Actions.Fuse.ImageColor3 = Color3.new(1, 1, 1)
    Actions.Start.Visible = false;

    local openContainer = getOpenContainer();
    if openContainer == nil then return end

    TweenService:Create(Items, TweenInfo.new(0.2), {Position = UDim2.new(0.506, 0, 0.372, 0)}):Play()
    TweenService:Create(FUSEMENU, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play();

    for _, btn in ipairs(Items.Tabs:GetChildren()) do
        if btn:IsA("ImageButton") then
             TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(0.773, 0, 0.143, 0)}):Play()
        end
     end

    for _, v in ipairs(openContainer:GetChildren()) do
        if v:IsA("ImageButton") then
            v.ImageColor3 = Color3.new(1, 1, 1);
        end
    end

    for _, v in ipairs(FUSEMENU.Entries:GetChildren()) do
        if v:IsA("ImageButton") and v.Name ~= "Spare" then
            v:Destroy();
        end
    end

    task.spawn(function()
        for k, conn in pairs(Fuse.SelectionConnections) do
            if conn then conn:Disconnect(); end
        end
    end)

    Fuse.SelectedItems = {};
    Fuse.SelectionConnections = {};

end

-- // Logic:

task.spawn(function()
    Actions.Fuse.Activated:Connect(function() 
        if Fuse.IsFusing == false then

            StartFusing();
    
            local openContainer = getOpenContainer();
            if openContainer == nil then return end

            local Container = openContainer;
                
            for _, Item in ipairs(Container:GetChildren()) do
                if Item:IsA("ImageButton") then

                    local connection;

                    -- // create activation connections:

                    task.spawn(function()
                         connection = Item.Activated:Connect(function()

                            local Name;

                            if string.find(Item.Name, "_") then
                                Name = string.split(Item.Name, "_")[1];
                            else
                                Name = Item.Name;    
                            end

                            local rarity = Configs[Container.Name][Name].Rarity;      
                            local len = get_dict_len(Fuse.SelectedItems)
                            
                            if len ~= 3 and not Fuse.SelectedItems[Item] then

                                if len == 0 then
                                    createEntry(Item, rarity)
                                else
                                    if get_base_item(Fuse.SelectedItems).Rarity == rarity then
                                        createEntry(Item, rarity)
                                    end
                                end
                            else

                                removeEntry(Item)

                            end
                        end)
                    end)

                    Fuse.SelectionConnections[Item] = connection;

                end
            end
            
            task.spawn(function()
                Fuse.SelectionConnections["Selector"] = FUSEMENU.Fuse.Activated:Connect(function()
                    if get_dict_len(Fuse.SelectedItems) == 3 then
    
                        Bridge:Fire({
    
                            Request = "Fuse";
                            Action = "Process";
    
                            Arguments = {
    
                                Items = Fuse.SelectedItems;
    
                            }
                        })
    
                        StopFusing()
                    else

                    end
                end)
            end)
        else
            StopFusing()
        end
    end)
end)

-- // Effects:

local TweenService = game:GetService("TweenService")

task.spawn(function()

    local Click, Hover = Character:WaitForChild("Click"), Character:WaitForChild("Hover");

    for _, Button in ipairs(Actions:GetChildren()) do
        if Button:IsA("ImageButton") then
            
            Button.MouseEnter:Connect(function()

                Hover:Play()
                TweenService:Create(Button, TweenInfo.new(0.2), {Size = UDim2.new(0.32, 0, 0.949, 0)}):Play()

            end)

            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {Size = UDim2.new(0.291, 0,0.76, 0)}):Play()
            end)

        end
    end
end)

return Fuse;
