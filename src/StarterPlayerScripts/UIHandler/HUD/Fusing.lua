type FUSING = {

    _name : string;
    _element : BasePart;

    _GUI: {

        Container : Frame;
        Cancel : ImageButton;
        Fuse : ImageButton;

    };

    -- // Unique properties:

    _fusingTBL : {

        Item : string;
        Count : number;
        BaseCount : number;
        BaseItem : ImageButton;
        BaseContainer : Frame;

    }; -- The list that holds all the selected items

     ---------------------------------------------------

    -- // Base Methods inherited from ELEMENT:

    -----------------------------------------------------

    New : () -> nil; -- creates a new Gacha class object. called only once.

    CreateBlur : () -> nil;  -- creates a blur in the camera background. saves the blur as (self._blur)

    Open : (Menu : string) -> nil;  -- Opens the menu selected (Weapons/Abilities...etc)

    Close : () -> nil;  -- Gets the currently open meny and closes it.
    
    Deploy : () -> nil;  -- creates a new _element instance. called only once.

    ParseRequest : (kwargs : {}) -> (any?); -- parses any request incoming from the server.

    ---------------------------------------------------

    -- // Unique class-specific methods:

    -----------------------------------------------------

    PostRequest : () -> nil; -- method that requests the server to fuse the items

    PlayAnimation : (Arguments : {SelectedItem : string}) -> nil; -- Plays the fusing animation if the server validates the request.

    SelectItem : (Item : string) -> string; -- Called when an m1 connection is triggered.

    RemoveItem : (Item : string) -> string; -- Called upon SelectItem() is called, if the item has already been selected, remove it.
    
    AddItem : (Item : string) -> string; -- Called upon SelectItem(), if item does not exist than add it.

    StartFusing : () -> nil; -- Called upon the fuse button in inventory is clicked.

    Reset : ()  -> nil; -- Cleans up everything such that a new fusing session can begin. Called with Close() and PlayAnimation().

};

local Fusing = {} :: FUSING
Fusing.__index = Fusing;

local Playergui = game.Players.LocalPlayer.PlayerGui
local FUSING_FRAME : Frame = Playergui.Root.Fusing;
local INVENTORY_FRAME : Frame = Playergui:WaitForChild("Inventory");

local Camera : Camera? = workspace.CurrentCamera;
local Tweenservice = game:GetService("TweenService");

local UIS = game:GetService("UserInputService")
local Rep = game:GetService("ReplicatedStorage")

local Net = require(Rep.Packages.BridgeNet2)
local Configs = require(script.Parent.Parent.Configs)

local Bridge = Net.ReferenceBridge("ServerCommunication");

function Fusing.New() : FUSING
	
	local self = {}
	
	self._name = "Fusing";
	self._GUI = FUSING_FRAME;
    self._fusingTBL = {

        Item = nil;
        Count = 0;
        BaseCount = 0;
        BaseItem = nil;
        BaseContainer = nil

    }

	return setmetatable(self, Fusing)
	
end

function Fusing:Deploy()

    -- // Start fusing functionality:

    INVENTORY_FRAME.Tabs.Fuse.Activated:Connect(function()

        self:StartFusing()
        require(script.Parent.PlayerHUD).HUD:Hide()

    end)
    INVENTORY_FRAME.Close.Activated:Connect(function()
        
        self:Close()
        self:Reset()
        require(script.Parent.PlayerHUD).HUD:Unhide()

    end)

    self._GUI.Cancel.Activated:Connect(function(inputObject, clickCount)
        
        self:Close()
        self:Reset()
        require(script.Parent.PlayerHUD).HUD:Unhide()

    end)
end

function Fusing:Parse(Action, kwargs)
    if Action == "PlayAnimation" then
        self:PlayAnimation(kwargs)
    end
end

function Fusing:PostRequest()
    
end

function Fusing:Open()
    
    self._GUI.Size = UDim2.new(0, 0, 0, 0)
    self._GUI.Visible = true;

    Tweenservice:Create(self._GUI, TweenInfo.new(.25), {Size = UDim2.new(0.263, 0,0.145, 0)}):Play()

end

function Fusing:Close()

    Tweenservice:Create(self._GUI, TweenInfo.new(.25), {Size = UDim2.new(0, 0, 0)}):Play()

    task.delay(.25, function()

        self._GUI.Size = UDim2.new(0, 0, 0, 0)
        self._GUI.Visible = false;

    end)
end

function Fusing:_getLen()
    return self._fusingTBL.Count
end

function Fusing:_getCount(Item : ImageLabel)
    
    local gsub = string.gsub(Item.ItemCount.Text, "%D", "")
    return tonumber(gsub)

end

function Fusing:Reset()
   
    for k, v in pairs(self._clickConnections) do
        if v then v:Disconnect() end
    end

    if self._removerConnections then
        for k, v in pairs(self._removerConnections) do
            if v then v:Disconnect() end
        end
    end

    for _, v in ipairs(self._GUI.Container:GetChildren()) do
        if v:IsA("ImageButton") and v.Name ~= "Spare" and v then
            v:Destroy();
        end
    end

    self._fusingTBL.BaseItem.ItemCount.Text = "x"..tostring(self._fusingTBL.BaseCount)

    self._fusingTBL.Count = 0;
    self._fusingTBL.Item = nil;
    self._fusingTBL.BaseCount = 0;
    self._fusingTBL.BaseItem = nil;
    self._fusingTBL.BaseContainer = nil;

end

function Fusing:SetAdornee()
    
end

function Fusing:SelectItem(Item : ImageLabel)

    self._removerConnections = {}

    if self:_getLen() ~= 3 and (self._fusingTBL.Item == Item.Name) and (self:_getLen() ~= 0) then

        self:AddItem(Item)
        self._fusingTBL.Count += 1;

    end

    -- // case 1: Item class has not been determined:

    if self:_getLen() == 0 then

        if self:_getCount(Item) < 3 then return end

        self._fusingTBL.Item = Item.Name;
        self._fusingTBL.Count += 1;
        self._fusingTBL.BaseCount = self:_getCount(Item)
        self._fusingTBL.BaseItem = Item;
        self._fusingTBL.BaseContainer = Item.Parent
        
        self:AddItem(Item)


    end

    -- // Case 2: Item class has been determined:
    
    if self._fusingTBL.Item ~= nil and (Item.Name ~= self._fusingTBL.Item) then
        -- tell player u cant do dis.
    end
end

function Fusing:AddItem(Item : string)

    local ContainerBaseObject : ScrollingFrame = self._GUI.Container
	local ConfigsContainer : {} = Configs[Item.Parent.Name]
	local Spare : ImageButton = ContainerBaseObject.Spare;
		
	local ItemConfig = ConfigsContainer[Item.Name];
	local NewInstance : ImageButton = Spare:Clone();
	NewInstance.Parent = ContainerBaseObject;
	NewInstance.Visible = true;
	NewInstance:FindFirstChild("Icon").Image = ItemConfig.Icon;
	NewInstance:FindFirstChild("itemName").Text = ItemConfig.DisplayName;
	
	NewInstance.Image = Configs.IconFrameAsset_ID[ItemConfig.Rarity]
	NewInstance.ColorManager.Color = Configs.FrameColor3[ItemConfig.Rarity]
	NewInstance:FindFirstChild("ItemCount").Text = "x"..tostring(1)
	NewInstance.Name = Item.Name;
    
    -- Update the count of the item:

    Item.ItemCount.Text = "x"..tostring(self:_getCount(Item) - 1)

    -- Create the listener event:

    self._removerConnections[NewInstance.Name] = NewInstance.Activated:Connect(function()
        self:RemoveItem(NewInstance, Item)
    end)
end

function Fusing:RemoveItem(Item, BaseItem)
    
    Item:Destroy()

    self._fusingTBL.Count -= 1;
    BaseItem.ItemCount.Text = "x"..tostring(self:_getCount(BaseItem) + 1)

    if self._fusingTBL.Count == 0 then
        
        print("Item removing . . . ")
        self:Reset();

    end
end

function Fusing:StartFusing()
    
    self:Open()
    self._clickConnections = {}

    for _, Containers : ScrollingFrame in ipairs(INVENTORY_FRAME.Containers:GetChildren()) do
        for _, Item : ImageButton in ipairs(Containers:GetChildren()) do
            if Item:IsA("ImageButton") then
                self._clickConnections[Item.Name] = Item.Activated:Connect(function(inputObject, clickCount)
                    print("FIRED")
                    self:SelectItem(Item)
                end)
            end
        end
    end

    self._GUI.Fuse.Activated:Connect(function(inputObject, clickCount)
        if self:_getLen() == 3 then
            
            local BaseContainer = self._fusingTBL.BaseContainer.Name
            local Item =self._fusingTBL.Item

            self:Close();
            self:Reset();

            Bridge:Fire({

                Request = "Fusing";
                Action = "ProcessRequest";
                Arguments = {

                    Item = Item;
                    Container = BaseContainer;

                }

            })
        end
    end)
end

function Fusing:PlayAnimation(Kwargs)
    
    local Item = Kwargs.Item;
    local Result : string = Kwargs.Result;
    local BaseItem = Kwargs.BaseItem;
    local BaseContainer = Kwargs.BaseContainer;

    require(script.Parent.PlayerHUD).HUD.Elements.Inventory:Close()

    -- // Create cards:

    local GachaFrame = Playergui.Root.Gacha;
    local Batch : Folder = GachaFrame.Batch;
    local Card : Frame = GachaFrame.Card;

    local Positions = {
        
        UDim2.new(-0.117543034,0, 0.411139637, 0);
        UDim2.new(0.524952769, 0, 0.411139637, 0);
        UDim2.new(1.17082119, 0, 0.411139637, 0);

    }

    local _cards = {}
    local Config = Configs[BaseContainer][BaseItem]

    for i = 1, 3 do

        local NewCard = Card:Clone()
        NewCard.Size = UDim2.new(0, 0, 0)
        NewCard.Parent = Batch;
        NewCard.Visible = true;

        NewCard.Front.Icon.Image = Config.Icon;
        NewCard.Front.ItemName.Text = Config.DisplayName;
        NewCard.Front.ItemRarity.Text = Config.Rarity;
        NewCard.Front.ItemChance.Text =  Config.Chance;

        NewCard.Position = Positions[i]
        Tweenservice:Create(NewCard, TweenInfo.new(.1), {Size = UDim2.new(0.558, 0,0.798, 0)}):Play()

        table.insert(_cards, NewCard)
        task.wait(.1)

    end
end
--{0.585, 0},{0.836, 0}
return Fusing
