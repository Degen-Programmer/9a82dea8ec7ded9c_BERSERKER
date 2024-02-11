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
local Bridge = Net.ReferenceBridge("ServerCommunication");

function Fusing.New() : FUSING
	
	local self = {}
	
	self._name = "Fusing";
	self._GUI = FUSING_FRAME;
    self._fusingTBL = {

        Item = nil;
        Count = 0;

    }

	return setmetatable(self, Fusing)
	
end

function Fusing:Deploy()

    -- // Start fusing functionality:

    INVENTORY_FRAME.Tabs.Fuse.Activated:Connect(function()

        self:StartFusing()
        require(script.Parent.PlayerHUD).HUD:Hide()

    end)

    self._GUI.Cancel.Activated:Connect(function(inputObject, clickCount)
        
        self:Close()
        self:Reset()
        require(script.Parent.PlayerHUD).HUD:Unhide()

    end)
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
    print(self._clickConnections)
end

function Fusing:SetAdornee()
    
end

function Fusing:SelectItem(Item : ImageLabel)

    -- // case 1: Item class has not been determined:

    if self:_getLen() == 0 then

        print("CHECKING...")

        if self:_getCount(Item) < 3 then return end

        self._fusingTBL.Item = Item.Name;
        self:AddItem(Item)
        self._fusingTBL.Count += 1;

        self:AddItem(Item)

    end

    -- // Case 3: Item is determined and player wants to add more of that item

    if self:_getLen() <= 3 and (self._fusingTBL.Item == Item.Name) then
        self:AddItem()
    end

    -- // Case 2: Item class has been determined:
    
    if self._fusingTBL.Item ~= nil and (Item.Name ~= self._fusingTBL.Item) then
        -- tell player u cant do dis.
    end
end

function Fusing:AddItem()
    print("Item Added.")
end

function Fusing:RemoveItem()
    
end

function Fusing:StartFusing()
    
    self:Open()
    self._clickConnections = {}

    for _, Containers : ScrollingFrame in ipairs(INVENTORY_FRAME.Containers:GetChildren()) do
        for _, Item : ImageButton in ipairs(Containers:GetChildren()) do
            if Item:IsA("ImageButton") then
                self._clickConnections[Item.Name] = Item.Activated:Connect(function(inputObject, clickCount)
                    self:SelectItem(Item)
                end)
            end
        end
    end
end

return Fusing
