type TRADING = {

    ---------------------------------------------------

    -- // Base Properities inherited from ELEMENT:

    ---------------------------------------------------

    _name : string;
    _element : Part;
    _runnerThread : thread | nil;
    _offset : CFrame;

    _GUI : {

        CloseButton : ImageButton;
        Title : ImageLabel;
        Sidebar : Folder;

        Base : {

            Accept : ImageButton;
            Decline : ImageButton;

            TheirOffer : {

                Container : Folder;
                CoinsContainer: {CoinsAdded : TextLabel};
                PlayerName : TextLabel;

            };

            YourOffer : {

                Container : Folder;
                CoinsContainer: {CoinsAdded : TextLabel};
                PlayerName : TextLabel;

            }
        }
    };

    ---------------------------------------------------

    -- // Unique Properties:
    
    ---------------------------------------------------

    _playerList : Frame;

    ---------------------------------------------------

    -- // Methods Inherited From Menu_Element:

    ---------------------------------------------------

    New : () -> nil; -- creates a new trading class object. called only once.

    _init_runner_thread : () -> nil; -- starts the _runnerthread and sets the position of _element with _offset to the camera.

    _cancel_runner_thread : () -> nil;  -- cancels the _runnerThread

    SetAdornee : () -> nil; -- sets the GUI element to the _element;

    CreatBlur : () -> nil;  -- creates a blur in the camera background. saves the blur as (self._blur)

    Open : () -> nil;  -- calls _init_runner_thread() and SetAdornee() to open the menu. In this case, opens player list and calls the afformentioned functions whence the trade has been accpted.

    Close : () -> nil;  -- calls _cancel_runner_thread() to close the menu

    Deploy : () -> nil;  -- creates a new _element instance. called only once.

    ParseRequest : (kwargs : {}) -> (any?); -- parses any request incoming from the server.

    ---------------------------------------------------

    -- // Unique Methods:

    ---------------------------------------------------

    _initializeTradingFrame : () -> nil; -- initializes YourOffer as the trading frame.

    AddPlayer : (Arguments : {Player : Player}) -> nil; -- Adds a player to the player list menu.

    RemovePlayer : (Arguments : {Player : Player}) -> nil; -- Removes a player from the player list menu.

    SendTradeRequest : (Player : Player, Arguments : {

        Request : string;
        Action: string;
        Arguments : {PlayerName : string};
        
    }) -> nil; -- sends a request to the server to send a trade request to "PlayerName".

    RecieveTradeRequest : (Arguments : {Sender : Player}) -> nil; -- called when a player recieves a trade request from another player.

    StartTradeSession : (Arguments : {Player : Player}) -> string; -- Starts a new trade session with a player.

    AddItem : (item : string, count : number) -> nil; -- adds an item and updates it for the other player.

    RemoveItem : (item : string, count : number) -> nil; -- removes an item and updates it for the other player.

    UpdateOffer : (Arguments : {NewOffer : {}}) -> nil; -- Updates the other player's Offer.

    DeclineTrade : () -> string; -- Declines the trade request. Next action is based on trade state (Readied/Unreadied)
    
    AcceptTrade : () -> nil; -- Accepts the trade request.

    TradeSuccesful : () -> nil; -- Invoked from the server. Calls when both players sucessfully trade.

    TradeCancelled : () -> nil; -- Trade was cancelled.

    Ready: () -> nil; -- Player has readied themselves.

    Unready: () -> nil; -- Player has unreadied themselves.

    FinalizeTradeOffer : () -> nil; -- finalizes the players trade and sends it off to the server.

    _clear_trading_frame : () -> nil; -- Function that resets the trading frame in order to be functional for the next trade.

};

local Trading : TRADING = {}
Trading.__index = Trading;

local Playergui = game.Players.LocalPlayer.PlayerGui
local TRADING_FRAME = Playergui.Trading.Base;
local PLAYER_LIST : ImageLabel = Playergui.Trading_Screen.PlayerList;
local TRADE_REQUEST : ImageLabel = Playergui.Trading_Screen.TradeRequest;
local INFO : ImageLabel = Playergui.Trading_Screen.Info

local Camera : Camera? = workspace.CurrentCamera;
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Tweenservice = game:GetService("TweenService");

local UIS = game:GetService("UserInputService")
local Rep = game:GetService("ReplicatedStorage")

local __PLAYER__ = game.Players.LocalPlayer;

local Net = require(Rep.Packages.BridgeNet2)
local Slider_Class = require(Rep.Packages.Slider)
local Configs = require(script.Parent.Parent.Configs)

local Bridge = Net.ReferenceBridge("ServerCommunication");
local TradeTraffic = Net.ReferenceBridge("TradeTraffic")

function Trading.New() : TRADING
	
	local new = {} :: TRADING 
	
	new._name = "Trading";
	new._element = game.ReplicatedStorage.UI.Trading
	new._runnerThread = nil;
	new._offset = new._element._OFFSET.Value;
    new._GUI = TRADING_FRAME;
    new._CurrentContainer = "Weapons";
    new._TradeSessionUUID = nil;

	return setmetatable(new, Trading)
	
end

function Trading:_cancel_runner_thread()
	task.cancel(self._runnerThread)
end

function Trading:_init_runner_thread()

    --[[local self : TRADING = self;

	local bounds = Vector2.new(-0.5, 0.5)
	local initialoffset = self._offset;

	self._runnerThread = task.spawn(function()
		game:GetService("RunService").RenderStepped:Connect(function()

			local screenSize = Camera.ViewportSize;
			local mousePos = (UIS:GetMouseLocation() - screenSize / 2) * (2 / screenSize)

			local yaw = CFrame.fromEulerAnglesXYZ(

				math.rad(mousePos.Y * bounds.Y),
				math.rad(mousePos.X * bounds.X),
				0

			)
			
			self._element.CFrame = Camera.CFrame * self._offset * yaw;
			
		end)
	end)]]
end

function Trading:SetAdornee()
	--Playergui.Trading.Adornee = self._element;
end

function Trading:CreatBlur()
	
	local blurInstance = Instance.new("BlurEffect", Camera)
	blurInstance.Size = 5;

	self._blur = blurInstance

end

function Trading:Open()

    PLAYER_LIST.Size = UDim2.new(0, 0, 0, 0)
    PLAYER_LIST.Visible = true;

	Tweenservice:Create(Camera, TweenInfo.new(.1), {FieldOfView = 75}):Play()
    Tweenservice:Create(PLAYER_LIST, TweenInfo.new(.1), {Size = UDim2.new(0.283, 0,0.588, 0)}):Play()

	self:CreatBlur()

end

function Trading:OpenMain()
    
    self:Close();

    self:_init_runner_thread()
    self._GUI.Size = UDim2.new(0, 0, 0, 0)
    self._GUI.Visible = true;

    Tweenservice:Create(self._GUI, TweenInfo.new(.1), {Size = UDim2.new(0.594, 0,0.616, 0)}):Play()

end

function Trading:Close()

	if self._runnerThread then self:_cancel_runner_thread() end

    PLAYER_LIST.Visible = false;

	--Tweenservice:Create(self._element, TweenInfo.new(.1), {Size = Vector3.new(0, 0, 0)}):Play()
	Tweenservice:Create(Camera, TweenInfo.new(.1), {FieldOfView = 70}):Play()
    Tweenservice:Create(self._GUI, TweenInfo.new(.1), {Size = UDim2.new(0, 0, 0, 0)}):Play()

	if self._blur then self._blur:Destroy() end

end

function Trading:Parse(Action, Arguments)

    print(Action, Arguments)

	if Action == "AddPlayer" then
		self:AddPlayer(Arguments)
	end

	if Action == "RecieveTradeRequest" then
		self:RecieveTradeRequest(Arguments)
	end

    if Action == "StartTradeSession" then
        self:StartTradeSession(Arguments);
    end

    if Action == "UpdateOffer" then
        self:UpdateOffer(Arguments)
    end

    if Action == "RemoveItem" then
        self:RemoveItem(Arguments)
    end

    if Action == "Ready" then
        self:Ready(Arguments)
    end

    if Action == "Unready" then
        self:Unready(Arguments)
    end

    if Action == "Countdown" then
        self:Countdown()
    end

    if Action == "CancelCountdown" then
        self:CancelCountdown()
    end

    if Action == "FinalizeTradeOffer" then
        self:FinalizeTradeOffer(Arguments)
    end

    if Action == "FinalizeOtherOffer" then
        self:FinalizeOtherOffer()
    end

    if Action == "UnfinalizeOtherOffer" then
        self:UnfinalizeOtherOffer()
    end

    if Action == "TradeSuccesful" then
        self:TradeSuccesful(Arguments)
    end

    if Action == "TradeCancelled" then
        self:TradeCancelled(Arguments)
    end

    if Action == "ReaddPlayer" then
        self:ReaddPlayer(Arguments)
    end

    if Action == "RemovePlayer" then
        self:RemovePlayer(Arguments)
    end

    if Action == "DeletePlayer" then
        self:DeletePlayer(Arguments)
    end

    if Action == "Load" then
        self:Load(Arguments)
    end
end

function Trading:SendTradeRequest(Player : Player)

    Bridge:Fire({

        Request = "Trading";
        Action = "ProcessTradeRequest";
        Arguments = {Requester = Player}

    })

    self:RemovePlayer({Player = Player.Name})

    --task.delay

end

function Trading:RecieveTradeRequest(Arguments : {})
    
    local finalSize = UDim2.new(0.193, 0, 0.226, 0);

    local newTradeRequest : ImageLabel = TRADE_REQUEST:Clone()
    newTradeRequest.Parent = Playergui.Trading_Screen;
    newTradeRequest.Visible = true;

    Tweenservice:Create(newTradeRequest, TweenInfo.new(.25), {Size = finalSize}):Play()

    task.delay(10, function()
        if newTradeRequest then newTradeRequest:Destroy() end
    end)

    newTradeRequest.Accept.Activated:Connect(function()
        TradeTraffic:Fire({

            Request = "TradeAccepted";
            Arguments = {UUID = Arguments.UUID}

        })

        self._TradeSessionUUID = Arguments.UUID;
        newTradeRequest:Destroy()

    end)

    newTradeRequest.Decline.Activated:Connect(function()
        
        TradeTraffic:Fire({
            
            Request = "TradeDeclined";
            Arguments = {UUID = Arguments.UUID}

        })

        newTradeRequest:Destroy()

    end)
end

function Trading:UpdateItem(item : string, Count : number)

    local _TradeSessionUUID = self._TradeSessionUUID;

    TradeTraffic:Fire({
            
        Request = "UpdateItem";
        Arguments = {Item = item, Count = Count; Container = self._CurrentContainer; UUID = _TradeSessionUUID}

    })

end

function Trading:RemoveItem(Arguments)

    local self : TRADING = self;
    self._GUI.Base.YourOffer.Container:FindFirstChild(Arguments.Entry.Container):FindFirstChild(Arguments.Entry.Item).CheckMark.Visible = false;
    
end

--TODO: Change update method from clearing all instances and loading all instances to more of a 
-- adding instances on top of each other.

-- DONE

function Trading:UpdateOffer(Arguments)

    print("Arguments")
    print("UWU! PARSING>!", Arguments)
    
    local self : TRADING = self

    local Entry = Arguments.Entry;
    local Action = Arguments.Action;

    -- // load new offer:

    if Action == "AddItem" then

        local ItemCount = Entry.Count;
        local Container = Entry.Container;
        local ItemConfig = Configs[Container][Entry.Item]
        local NewInstance : ImageButton = self._GUI.Spare:Clone();

	    NewInstance.Parent = self._GUI.Base.TheirOffer.Container;
	    NewInstance.Visible = true;
	    NewInstance:FindFirstChild("Icon").Image = ItemConfig.Icon;
	    NewInstance:FindFirstChild("itemName").Text = ItemConfig.DisplayName;
        
	    NewInstance.Image = Configs.IconFrameAsset_ID[ItemConfig.Rarity]
	    NewInstance.ColorManager.Color = Configs.FrameColor3[ItemConfig.Rarity]
	    NewInstance:FindFirstChild("ItemCount").Text = "x"..tostring(ItemCount)
	    NewInstance.Name = Entry.Item;

    end

    if Action == "RemoveItem" then
        self._GUI.Base.TheirOffer.Container:FindFirstChild(Entry.Item):Destroy()
    end

    if Action == "UpdateItem" then
        self._GUI.Base.TheirOffer.Container:FindFirstChild(Entry.Item).ItemCount.Text = Entry.Count;
    end
end

function Trading:_initializeTradingFrame(Tradee)

    local self : TRADING = self;
    local Sliders = {}

    local HUD = require(script.Parent.PlayerHUD).HUD
    local Inventory_element = HUD.Elements.Inventory._GUI;
    local Holder = self._GUI.Holder;

    self:OpenMain()

    local YourOffer = self._GUI.Base.YourOffer.Container;
    local BaseContainer = Inventory_element.Containers.Weapons;

    self._GUI.Base.TheirOffer.PlayerName.Text = "@"..Tradee.Name.."'s Offer"

    task.spawn(function()

        -- // clone all items:

        for _, Container : Folder in ipairs(Inventory_element.Containers:GetChildren()) do
            for _, Item in ipairs(Container:GetChildren()) do
                if Item:IsA("ImageButton") and Item and Item.Name ~= "Spare" then
                    
                    local clone = Item:Clone()
                    clone.Parent = YourOffer:FindFirstChild(Container.Name)
    
                    local newHolder = Holder:Clone()
                    newHolder.Parent = clone;
                    newHolder.Visible = true;

                    local __SLIDER = self._GUI.Slider:Clone()
                    __SLIDER.Parent = newHolder
                    __SLIDER.Visible = true;

                    local gsub = string.gsub(clone.ItemCount.Text, "%D", "")
                    local ItemCount = tonumber(gsub)

                    local _slider = Slider_Class.new(newHolder, {

                        SliderData = {Start = 1, End = ItemCount, Increment = 1, DefaultValue = 1},
                        MoveType = "Instant";
                        Axis = "X",
                        Padding = 5;
                        AllowBackgroundClick = true;

                    })

                    _slider:Track()
        
                    local checkMark = self._GUI.CheckMark:Clone()
                    checkMark.Parent = clone;

                    local _ItemCount : TextBox = clone.ItemCount
                    _ItemCount:Destroy()

                    _ItemCount  = self._GUI.ItemCount:Clone()
                    _ItemCount.Parent = clone;
                    _ItemCount.Text = "x"..tostring(ItemCount)
                    _ItemCount.Visible = true;

                    _slider.Changed:Connect(function()
                        __SLIDER.ItemCount.Text = tostring(_slider:GetValue());
                    end)
                    
                    _slider.Released:Connect(function()

                        clone.CheckMark.Visible = true;
                        self:UpdateItem(_ItemCount.Parent.Name, _slider:GetValue())

                    end)

                    clone.Activated:Connect(function(inputObject, clickCount)

                        print("OVERRIDDEN")

                        clone.CheckMark.Visible = true;
                        self:UpdateItem(clone.Name, ItemCount)

                    end)
                end
            end
        end

        for _, Btn : ImageButton in ipairs(self._GUI.Sidebar:GetChildren()) do

            local BtnPosition = Btn.Position;

            -- // handle switching of tabs in the inventory menu:

            Btn.Activated:Connect(function()

                self._CurrentContainer = Btn.Name;

                for _, v in ipairs(YourOffer:GetChildren()) do
                    v.Visible = false
                end

                YourOffer:FindFirstChild(Btn.Name).Visible = true;
                
            end)
    
            Btn.MouseEnter:Connect(function(x, y)
                Tweenservice:Create(Btn, TweenInfo.new(.15), {Position = Btn.Position - UDim2.new(0.01, 0, 0, 0)}):Play()
            end)
    
            Btn.MouseLeave:Connect(function(x, y)
                Tweenservice:Create(Btn, TweenInfo.new(.15), {Position = BtnPosition}):Play()
            end)
        end
    end)
end

function Trading:_clear_trading_frame()
    
    local YourOffer = self._GUI.Base.YourOffer.Container;
    local TheirOFfer = self._GUI.Base.TheirOffer.Container;

    for _, v : ScrollingFrame in ipairs(YourOffer:GetChildren()) do
        for _, items in ipairs(v:GetChildren()) do
            
            if items:IsA("ImageButton") then
                items:Destroy()
                print("DESTROYED!")
            end

        end
    end

    for _, items in ipairs(TheirOFfer:GetChildren()) do
            
        if items:IsA("ImageButton") then
            items:Destroy()
            print("DESTROYED!")
        end

    end

    self._GUI.Base.TheirOffer.Checkmark.Visible = false
    self._GUI.Base.YourOffer.Checkmark.Visible = false

end

function Trading:AcceptTrade()
    TradeTraffic:Fire({
            
        Request = "Accept";
        Arguments = {UUID = self._TradeSessionUUID}

    })
end

function Trading:Ready()
    
    self._GUI.Base.Decline.TextLabel.Text = "Unready"
    self._GUI.Base.Accept.ImageTransparency = 0.5;
    self._GUI.Base.Accept.Active = false;

end

function Trading:DeclineTrade()
    TradeTraffic:Fire({
            
        Request = "Decline";
        Arguments = {UUID = self._TradeSessionUUID}

    })
end

function Trading:Unready()
    
    self._GUI.Base.Decline.TextLabel.Text = "Decline"
    self._GUI.Base.Accept.ImageTransparency = 0;
    self._GUI.Base.Accept.Active = true;

    self._GUI.Base.YourOffer.Container.Finalized.Visible = false;

    for _, v in ipairs(self._GUI.Base.YourOffer.Container.Finalized:GetChildren()) do
        if v:IsA("ImageButton") then
            v:Destroy()
        end
    end

    self._GUI.Base.YourOffer.Checkmark.Visible = false;
    self._GUI.Base.YourOffer.Container.Weapons.Visible = true;

    for _, v in ipairs(self._GUI.Sidebar:GetChildren()) do
        v.Visible = true;
    end
end

function Trading:Countdown()
    self._Countdown = task.spawn(function()
        for i = 5, 0, -1 do
                
            task.wait(1)

            self._GUI.Base.Decline.TextLabel.Text = tostring(i)

        end
    end)
end

function Trading:CancelCountdown()
    task.cancel(self._Countdown)
    self._GUI.Base.Decline.TextLabel.Text = "Decline"
    self._GUI.Base.Accept.ImageTransparency = 0;
end

function Trading:StartTradeSession(Arguments)
    
    local self : TRADING = self;
    self:_initializeTradingFrame(Arguments.Tradee)
    self._TradeSessionUUID = Arguments.UUID;

    self._GUI.Base.Accept.Activated:Connect(function(inputObject, clickCount)
        self:AcceptTrade()
    end)
    
    self._GUI.Base.Decline.Activated:Connect(function(inputObject, clickCount)
        self:DeclineTrade()
    end)
end

function Trading:FinalizeOtherOffer(Arguments)
    self._GUI.Base.TheirOffer.Checkmark.Visible = true;
end

function Trading:UnfinalizeOtherOffer(Arguments)
    self._GUI.Base.TheirOffer.Checkmark.Visible = false;
end

function Trading:FinalizeTradeOffer(Arguments : {})
    
    local self : TRADING = self;
    local Items = {}

    for _, v in ipairs(self._GUI.Sidebar:GetChildren()) do
        v.Visible = false;
    end

    for k : string, entries : {} in pairs(Arguments.Entries) do
       
        local CorrespondingItem : ImageButton = nil;

        for _, v in ipairs(self._GUI.Base.YourOffer.Container:GetDescendants()) do
            if v.Name == k then

                local clone = v:Clone()
                clone.Parent = self._GUI.Base.YourOffer.Container.Finalized;

            end
        end
    end

    self._GUI.Base.YourOffer.Checkmark.Visible = true;

    for _, v in ipairs(self._GUI.Base.YourOffer.Container:GetChildren()) do
        v.Visible = false
    end

    self._GUI.Base.YourOffer.Container.Finalized.Visible = true;

end

function Trading:TradeSuccesful()
    
    self:Close()
    self:_clear_trading_frame()

    local Info = INFO:Clone()
    Info.Parent = Playergui.Trading_Screen;
    Info.Visible = true;
    
    Info.Description.Text = "Trade successful! \n Items are now available in your inventory."
    Info.Description.TextColor3 = Color3.new(85, 255, 127)

    Tweenservice:Create(Info, TweenInfo.new(.25), {Size = UDim2.new(0.226, 0, 0.274, 0)}):Play()

    Info.Close.Activated:Connect(function()
        Info:Destroy()
    end)
end

function Trading:TradeCancelled(Arguments)

    self:Close()
    self:_clear_trading_frame()

    local Info = INFO:Clone()
    Info.Parent = Playergui.Trading_Screen;
    Info.Visible = true;
    
    Info.Description.Text = Arguments.Reason;
    Info.Description.TextColor3 = Color3.new(255, 83, 83)

    Tweenservice:Create(Info, TweenInfo.new(.25), {Size = UDim2.new(0.226, 0, 0.274, 0)}):Play()

    Info.Close.Activated:Connect(function()
        Info:Destroy()
    end)
end

function Trading:AddPlayer(Arguments)

    print(PLAYER_LIST:GetChildren())

    if Arguments.Player == __PLAYER__ then print("SAME PERSON!") return end

    local Player : Player = Arguments.Player;
    local Container : ScrollingFrame = PLAYER_LIST:WaitForChild("Container ");
    local PlayerFrame : ImageLabel = Container.Player;

    if Container:FindFirstChild(Arguments.Player.Name) then return end

    local New = PlayerFrame:Clone()
    New.Parent = Container ;
    New.Visible = true;
    New.Name = Player.Name;

    local DisplayName : TextLabel, UserName : TextLabel, Icon : ImageLabel = New.DisplayName, New.UserName, New.Icon
    local SendRequest : ImageButton = New.SendRequest;

    DisplayName.Text = Player.DisplayName;
    UserName.Text = '@'..Player.Name;

    local userId = Player.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local content, isReady = game.Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

    Icon.Image = content

    SendRequest.Activated:Connect(function(inputObject, clickCount)
        self:SendTradeRequest(Player)
    end)
    
end

function Trading:Load(kwargs)
    
    local list = kwargs.List 

    print("LIST__ = " ,list)

    for _, Player in ipairs(list) do
        if Player == __PLAYER__ then return end
        
        local Player : Player = Player;
        local Container : ScrollingFrame = PLAYER_LIST:WaitForChild("Container ");
        local PlayerFrame : ImageLabel = Container.Player;

        if Container:FindFirstChild(Player.Name) then return end

        local New = PlayerFrame:Clone()
        New.Parent = Container ;
        New.Visible = true;
        New.Name = Player.Name;

        local DisplayName : TextLabel, UserName : TextLabel, Icon : ImageLabel = New.DisplayName, New.UserName, New.Icon
        local SendRequest : ImageButton = New.SendRequest;

        DisplayName.Text = Player.DisplayName;
        UserName.Text = '@'..Player.Name;

        local userId = Player.UserId
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size420x420
        local content, isReady = game.Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

        Icon.Image = content

        SendRequest.Activated:Connect(function(inputObject, clickCount)
            self:SendTradeRequest(Player)
        end)
    end
end

function Trading:GetPlayerFrameFromList(PlayerName)

    local Container : ScrollingFrame = PLAYER_LIST:WaitForChild("Container ");
    local PlayerFrame = Container:FindFirstChild(PlayerName)

    return PlayerFrame

end

function Trading:ReaddPlayer(Arguments)

    local _player = Arguments.Player;
    local PlayerFrame : Frame = self:GetPlayerFrameFromList(_player)

    if PlayerFrame == nil then print("BRAH") return end

    PlayerFrame.SendRequest.Active = true
    PlayerFrame.SendRequest.ImageTransparency = 0;

    print("Player reinstated..")

end

function Trading:RemovePlayer(Arguments)

    local _player = Arguments.Player;
    local PlayerFrame : Frame = self:GetPlayerFrameFromList(_player)

    if PlayerFrame == nil then return end

    PlayerFrame.SendRequest.Active = false
    PlayerFrame.SendRequest.ImageTransparency = 0.5;

    print("Player removed.")

end

function Trading:DeletePlayer(Arguments)

    local _player = Arguments.Player;
    local PlayerFrame : Frame = self:GetPlayerFrameFromList(_player)

    if PlayerFrame == nil then return end
    PlayerFrame:Destroy()

    print("Destroyed.")
end


function Trading:Deploy()
	
	local element : Part = self._element;
	local newElement = element:Clone()
	newElement.Parent = workspace;

    local self : TRADING = self;

    PLAYER_LIST.Close.Activated:Connect(function()
        
        Tweenservice:Create(PLAYER_LIST, TweenInfo.new(.25), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        self:Close()

    end)

    local players = game.Players:GetPlayers()

    local Container : ScrollingFrame = PLAYER_LIST:WaitForChild("Container ");
    local PlayerFrame : ImageLabel = Container.Player;
    
end

return Trading