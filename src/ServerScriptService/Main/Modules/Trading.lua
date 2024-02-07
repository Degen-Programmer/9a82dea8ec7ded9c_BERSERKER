local Trading = {}

Trading.ActiveTrades = {};
Trading.ActiveRequests = {};
Trading.RemovedPlayers = {};

local Modules = script.Parent;
local Inventory = require(Modules.Inventory)

local ContentProvider = game:GetService("ContentProvider")
local Main = game:GetService("ServerScriptService").Main;
local Rep = game:GetService("ReplicatedStorage")

local Net = require(Rep.Packages.BridgeNet2)
local data = require(Main.Data);
local Inventory = require(script.Parent.Inventory)

local TradeTraffic = Net.ReferenceBridge("TradeTraffic")
local HUD = Net.ReferenceBridge("HUD")

TradeTraffic:Connect(function(Sender : Player, Arguments)

    local Request = Arguments.Request;
    local Kwargs = Arguments.Arguments;

    local TradeSession = Trading.ActiveTrades[Kwargs.UUID]

    if Request == "TradeAccepted" then
        
        local _request = Trading.ActiveRequests[Kwargs.UUID]
        
        local plr1 = Trading.CheckPlayer(_request.Reciever)
        local plr2 = Trading.CheckPlayer(_request.Sender)

        if plr1 == true or plr2 == true or (plr1 == true and plr2 == true) then return end        
        print("Players are not in any other active trades at the moment.");

        Trading.NewTradeSession(_request.Reciever, _request.Sender, Kwargs.UUID)
        _request = nil;

    end

    if Request == "TradeDeclined" then

        local req = Trading.ActiveRequests[Kwargs.UUID]
        print(req.Sender.Name)

        HUD:Fire(Net.Players({req.Sender}), {

            Element = "Trading";
            Action = "ReaddPlayer";
            Arguments = {Player = req.Reciever.Name};

        })

        Trading.ActiveRequests[Kwargs.UUID] = nil;
    end

    if Request == "UpdateItem" then
        Trading.UpdateItem(TradeSession, Sender, Kwargs)
    end

    if Request == "AlterTradeRequests" then
        Trading.AlterTradeRequests(Sender)
    end

    if Request == "Accept" then
        Trading.Accept(TradeSession, Sender, Kwargs)
    end

    if Request == "Decline" then
        Trading.Decline(TradeSession, Sender, Kwargs)
    end
end)

function Trading.RemovePlayer(PLR_NAME)

    HUD:Fire(Net.AllPlayers(), {

        Element = "Trading";
        Action = "RemovePlayer";
        Arguments = {Player = PLR_NAME}

    })

end

function Trading.ReaddPlayer(PLR_NAME)

    HUD:Fire(Net.AllPlayers(), {

        Element = "Trading";
        Action = "ReaddPlayer";
        Arguments = {Player = PLR_NAME}

    })

end

function Trading.AlterTradeRequests(Player)
    Trading.RemovedPlayers[Player.Name] = Player;
end

function Trading.CheckPlayer(Player : Player)

    local c = 0;

    for UUID, TradeSession : {} in pairs(Trading.ActiveTrades) do

        c = c + 1

        if TradeSession.Player1 == Player or TradeSession.Player2 == Player then
            return true
        else
            return false
        end
    end

    -- // no active session were going on, default to 0 and return.

    if c == 0 then
        return false
    end
end

function Trading.ProcessTradeRequest(Player, Arguments)
    
    local Reciever : Player = Arguments.Requester;
    local PLR_Reciever = game.Players:FindFirstChild(Reciever.Name)

    if Trading.CheckPlayer(PLR_Reciever) == true then return end
    --if Trading.RemovedPlayers[Reciever.Name] then print("Bro has turned off trade requests") return end

    local ResponseUUID = game:GetService("HttpService"):GenerateGUID(false)

    task.delay(10, function()

        -- // this means that the request was simply ignored.

        if Trading.ActiveRequests[ResponseUUID] then
           Trading.ActiveRequests[ResponseUUID] = nil;

           HUD:Fire(Net.Players({Player}), {

            Element = "Trading";
            Action = "ReaddPlayer";
            Arguments = {Player = Reciever.Name};

            })

        end
    end)

    Trading.ActiveRequests[ResponseUUID] = {

        Resolve = "WAITING";
        Sender = Player;
        Reciever = Reciever;

    }

    HUD:Fire(Net.Players({PLR_Reciever}), {

        Element = "Trading";
        Action = "RecieveTradeRequest";
        Arguments = {

            Sender = Player;
            UUID = ResponseUUID;

        }

    })

end

local function Ready(Player : Player) 

    HUD:Fire(Net.Players({Player}), {

        Element = "Trading";
        Action = "Ready";
        Arguments = {}

    })

end

local function Finalize(Player : Player, OtherPlayer, Offer)
    HUD:Fire(Net.Players({Player}), {

        Element = "Trading";
        Action = "FinalizeTradeOffer";
        Arguments = {Entries = Offer}

    })

    HUD:Fire(Net.Players({OtherPlayer}), {

        Element = "Trading";
        Action = "FinalizeOtherOffer";
        Arguments = {}

    })
    
end

local function Unready(Player : Player, OtherPlayer) 

    HUD:Fire(Net.Players({Player}), {

        Element = "Trading";
        Action = "Unready";
        Arguments = {}

    })

    HUD:Fire(Net.Players({OtherPlayer}), {

        Element = "Trading";
        Action = "UnfinalizeOtherOffer";
        Arguments = {}

    })
end

local function Countdown(Player : Player)
    HUD:Fire(Net.Players({Player}), {

        Element = "Trading";
        Action = "Countdown";
        Arguments = {}

    })
end

local function CancelCountdown(Player)
    HUD:Fire(Net.Players({Player}), {

        Element = "Trading";
        Action = "CancelCountdown";
        Arguments = {}

    })
end

function Trading.Accept(TradeSession, Sender, Arguments)

    print("Accepting")

    TradeSession.TradeState = "PartialReadied"
    
    if Sender == TradeSession.Player1 then
        print("Player 1 Accepted.")
        TradeSession.Player1Ready = true;
        Ready(Sender)
        Finalize(Sender, TradeSession.Player2, TradeSession.Player1Offer)
    end

    if Sender == TradeSession.Player2 then
        print("Player 2 Accepted.")
        TradeSession.Player2Ready = true;
        Ready(Sender)
        Finalize(Sender, TradeSession.Player1, TradeSession.Player2Offer)
    end

    if TradeSession.Player1Ready == true and TradeSession.Player2Ready == true and TradeSession.TradeState ~= "Countdown" then
        print("Both are readied, can commence exchange.")
        TradeSession.TradeState = "Countdown";
        Countdown(TradeSession.Player1); Countdown(TradeSession.Player2)

        TradeSession.Counter = task.spawn(function()
            for i = 5, 0, -1 do
                
                task.wait(1)

                print(i)

                if i == 0 then
                    print("Exchanging Items.")
                    Trading.ExchangeItems(TradeSession)
                end
            end
        end)
    end
end

function Trading.ExchangeItems(TradeSession)
    
    local Player1 : Player, player2 : Player = TradeSession.Player1, TradeSession.Player2;
    local Offer1 : {}, Offer2 : {} = TradeSession.Player1Offer, TradeSession.Player2Offer;

    for _, v in pairs(Offer1) do

        Inventory.RemoveItem(Player1, {Item = v.Item; Container = v.Container; Count = v.Count});
        Inventory.AddItem(player2, {Item = v.Item; Container = v.Container; ItemCount = v.Count});

    end

    for _, v in pairs(Offer2) do
        
        Inventory.RemoveItem(player2, {Item = v.Item; Container = v.Container, Count = v.Count});
        Inventory.AddItem(Player1, {Item = v.Item; Container = v.Container; ItemCount = v.Count});

    end

    print(Player1.Name.." Traded: ", Offer1)
    print(Player1.Name.." Recieved: ", Offer2)

    print(player2.Name.." Traded: ", Offer2)
    print(player2.Name.." Recieved: ", Offer1)

    HUD:Fire(Net.Players({Player1, player2}), {

        Element = "Trading";
        Action = "TradeSuccesful";
        Arguments = {}

    });

    Trading.ReaddPlayer(Player1.Name)
    Trading.ReaddPlayer(player2.Name)

end

function Trading.Load(plr)
    
    local players = game.Players:GetPlayers()
    HUD:Fire(Net.Players({plr}), {

        Element = "Trading";
        Action = "Load";
        Arguments = {List = players}

    })
end

function Trading.Decline(TradeSession, Sender, Arguments)

    if TradeSession.TradeState == "Trading" then
        print("Terminate the trade.")
        Trading.Terminate(TradeSession.UUID, "Trade was declined :( ")
    end

    if TradeSession.TradeState == "PartialReadied" then

        print("Terminating Partial Trade...")

        if Sender == TradeSession.Player1 then
            print("Player 1 Unreadied.")
            TradeSession.Player1Ready = false;
            Unready(Sender, TradeSession.Player2)
        end

        if Sender == TradeSession.Player2 then
            print("Player 2 Unreadied.")
            TradeSession.Player2Ready = false;
            Unready(Sender, TradeSession.Player1)
        end

        if TradeSession.Player1Ready == false and TradeSession.Player2Ready == false then
            TradeSession.TradeState = "Trading";
            print("reverted trade state.")
        end

        TradeSession.TradeState = "Trading"

    end

    if TradeSession.TradeState == "Countdown" then

        print("Terminating Countdown Trade...")
        task.cancel(TradeSession.Counter)

        print("COUNTER CANCELLED.")
        TradeSession.TradeState = "Unreadied"

        TradeSession.Player1Ready = false;
        TradeSession.Player2Ready = false;

        CancelCountdown(Sender)
        CancelCountdown(TradeSession.Player1)
        
        Unready(Sender, TradeSession.Player1)
        Unready(TradeSession.Player1, Sender)

    end
end

function Trading.UpdateItem(TradeSession, Sender, Arguments)

    local function AddItem(plr, Entry)
        HUD:Fire(Net.Players({plr}), {

            Element = "Trading";
            Action = "UpdateOffer";
            Arguments = {Entry = Entry; Action = "AddItem"}

        })
    end

    local function RemoveItem(Adder : Player, Player2 : Player, Entry)
        HUD:Fire(Net.Players({Adder}), {

            Element = "Trading";
            Action = "RemoveItem";
            Arguments = {

                Entry = Entry;
            }

        })

        HUD:Fire(Net.Players({Player2}), {

            Element = "Trading";
            Action = "UpdateOffer";
            Arguments = {

                Entry = Entry;
                Action = "RemoveItem"

            }

        })
    end

    local function UpdateItem(Player, Entry)
        HUD:Fire(Net.Players({Player}), {

            Element = "Trading";
            Action = "UpdateOffer";
            Arguments = {

                Entry = Entry;
                Action = "UpdateItem";
            }

        })
    end

    -- // check if an item already exists, if it does, cap the fucker.

    local function CheckForItem(TradeOffer, Item, Entry)
        if TradeOffer[Item] then

            -- // if the count remains the exact same, that means that the user wants to remove the item.

            if TradeOffer[Item].Count == Entry.Count then
                print("SAME EXACT COUNT. REMOVE THE ITEM.")
                
                TradeOffer[Item] = nil;
                return "Remove_Item"

            end

            if Entry.Count == (0) then
                
                TradeOffer[Item] = nil;
                return "Remove_Item";

            end

            -- // if the count has changed and is greater than 0, that means the user has changed the amount of that item.

            if TradeOffer[Item].Count ~= Entry.Count and Entry.Count ~= (0) then
        
                TradeOffer[Item].Count = Entry.Count
                return "Update_Item"

            end

            return true

        else

            -- // create a new entry.

            print("New entry has been created.")

            TradeOffer[Item] = Entry
            return "Add_Item"

        end
    end

    if Sender == TradeSession.Player1 then
        
        local Reciever : Player = TradeSession.Player2;

        -- // check to see if the player actually has the items. If not then cap the fucker.
        
        local Player1Data = TradeSession.Player1Data

        local Entry : {} = {

            Item = Arguments.Item;
            Count = Arguments.Count;
            Container = Arguments.Container;

        }

        if TradeSession.Player1Data.Inventory[Entry.Container][Entry.Item] == nil then return end
        local __ITEMCOUNT = TradeSession.Player1Data.Inventory[Entry.Container][Entry.Item] 

        if Entry.Count > __ITEMCOUNT then
            print("More than the amount the player has. Kick him from the game")
        else
            print("Selected copies are within range.")
        end

        local Result = CheckForItem(TradeSession.Player1Offer, Entry.Item, Entry)

        if Result == "Add_Item" then
            AddItem(TradeSession.Player2, Entry)
        end

        if Result == "Update_Item" then
            UpdateItem(TradeSession.Player2, Entry)
        end

        if Result == "Remove_Item" then
            RemoveItem(Sender, TradeSession.Player2, Entry)
        end
    end

    if Sender == TradeSession.Player2 then
        
        local Reciever : Player = TradeSession.Player1;

        -- // check to see if the player actually has the items. If not then cap the fucker.

        local Entry : {} = {

            Item = Arguments.Item;
            Count = Arguments.Count;
            Container = Arguments.Container;

        }

        if TradeSession.Player2Data.Inventory[Entry.Container][Entry.Item] == nil then return end
        local __ITEMCOUNT = TradeSession.Player2Data.Inventory[Entry.Container][Entry.Item] 

        if Entry.Count > __ITEMCOUNT then
            print("More than the amount the player has. Kick him from the game")
        else
            print("Selected copies are within range.")
        end
        
        local Result = CheckForItem(TradeSession.Player2Offer, Entry.Item, Entry)

        if Result == "Add_Item" then
            AddItem(TradeSession.Player1, Entry)
        end

        if Result == "Update_Item" then
            UpdateItem(TradeSession.Player1, Entry)
        end

        if Result == "Remove_Item" then
            RemoveItem(Sender, TradeSession.Player1, Entry)
        end

    end
end

function Trading.NewTradeSession(Player1 : Player, Player2 : Player, UUID)
    
    local newPlayerOffer = {

        TradeState = "Trading"; -- // Trading / Readied / Processing

        ["Player1"] = Player1;
        ["Player2"] = Player2;

        Player1Ready = false;
        Player2Ready = false;

        Player1Offer = {};
        Player2Offer = {};

        Player1Data = data:Get(Player1).Data;
        Player2Data = data:Get(Player2).Data;

        Counter = nil;
        UUID = UUID;

    }

    Trading.ActiveTrades[UUID] = newPlayerOffer;

    HUD:Fire(Net.Players({Player1}), {

        Element = "Trading";
        Action = "StartTradeSession";
        Arguments = {Tradee = Player2, UUID = UUID};

    })

    HUD:Fire(Net.Players({Player2}), {

        Element = "Trading";
        Action = "StartTradeSession";
        Arguments = {Tradee = Player1, UUID = UUID};

    })

    Trading.RemovePlayer(newPlayerOffer.Player1.Name)
    Trading.RemovePlayer(newPlayerOffer.Player2.Name)

    -- // create listener for when if someone leaves.

    game.Players.PlayerRemoving:Connect(function(player)
        if player == newPlayerOffer.Player1 then
            print("Player left while trading.")
            Trading.Terminate(UUID, "Player left while trading.")
        end

        if player == newPlayerOffer.Player2 then
            print("Player left while trading.")
            Trading.Terminate(UUID, "Player left while trading.")
        end
    end)

end

function Trading.Terminate(UUID, Reason)
    if Trading.ActiveRequests[UUID] then
        Trading.ActiveRequests[UUID] = nil;
    end

    if Trading.ActiveTrades[UUID] then

        Trading.ReaddPlayer(Trading.ActiveTrades[UUID].Player1.Name);
        Trading.ReaddPlayer(Trading.ActiveTrades[UUID].Player2.Name);

        HUD:Fire(Net.Players({ Trading.ActiveTrades[UUID].Player1,  Trading.ActiveTrades[UUID].Player2}), {

            Element = "Trading";
            Action = "TradeCancelled";
            Arguments = {Reason = Reason};
    
        })

        Trading.ActiveTrades[UUID] = nil;

    end
end

return Trading