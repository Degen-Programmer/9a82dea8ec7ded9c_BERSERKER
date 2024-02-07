local MarketplaceService = game:GetService("MarketplaceService")
local Spinwheel = {}
Spinwheel.Debounces = {}

local dataMain = require(game.ServerScriptService.Main.Data)
local combat = require(game.ServerScriptService.Main.Combat.Users);
local net = require(game.ReplicatedStorage.Packages.BridgeNet2);
local inventory = require(script.Parent.Inventory);
local GachaSignals = require(game.ServerScriptService.Main.Modules.Products.Signals)
local MY_FUCKING_ROBUX = require(script.Parent.Products);

local ClientCommunication = net.ReferenceBridge("ClientCommunication");

Spinwheel.Chances = {

    ["500 Coins"] = {

        Chance = 50;
        RewardType = "Currency";
        Index = 3;

        Arguments = {
            
            Currency = "Currency";
            Reward = 500;

        }

    }; -- // 1st Index.

    ["Endsword"] = {

        Chance = 1;
        RewardType = "Item";
        Index = 4;

        Arguments = {
            
            Container = "Weapons";
            Item = "Endsword";

        }

    }; -- // 2nd Index.

    ["TheReaping"] = {

        Chance = 10;
        RewardType = "Item";
        Index = 5;

        Arguments = {
            
            Container = "Abilities";
            Item = "TheReaping";

        }

    }; -- // 3rd Index.

    ["1000 Coins"] = {

        Chance = 40;
        RewardType = "Currency";
        Index = 6;
        Arguments = {
            
            Currency = "Currency";
            Reward = 1000;

        }

    }; -- // 4th Index.

    ["1500 Coins"] = {

        Chance = 30;
        RewardType = "Currency";

        Arguments = {
            
            Currency = "Currency";
            Reward = 1500;

        };

        Index = 7;

    }; -- // 5th Index.

    ["Dodge Roll"] = {

        Chance = 50;
        RewardType = "Item";
        Index = 8;

        Arguments = {
            
            Container = "Abilities";
            Item = "TheReaping";

        }

    }; -- // 6th Index.

    ["2000 Coins"] = {

        Chance = 20;
        RewardType = "Currency";
        Index = 1;

        Arguments = {
            
            Currency = "Currency";
            Reward = 1500;

        };

    }; -- // 6th Index.

    ["Wooden Sword"] = {

        Chance = 10;
        RewardType = "Item";
        Index = 2;

        Arguments = {
            
            Container = "Weapons";
            Item = "WoodenSword";

        }

    }; -- // 7th Index.
    

}

function Spinwheel.ProcessTransaction(Player : Player, Kwargs : {})

    print("PRocessing transacxtion...")
    
    local ProductName = Kwargs.Product;
    local ProductID;

    for P_ID, Array : {} in pairs(MY_FUCKING_ROBUX.Spins) do
        if Array.Name == ProductName then
            ProductID = tonumber(P_ID)
        end 
    end

    print(ProductID);

    if ProductID then
        local approved, rejected = pcall(function()
            return MarketplaceService:PromptProductPurchase(Player, ProductID)
        end)
    end

    task.spawn(function()
        MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, isPurchased)
            if isPurchased == true then
                Spinwheel.UpdateSpins(Player, dataMain:Get(Player).Data.Spins)
            end
        end)
    end)
end

function Spinwheel.Process(Player : Player, Kwargs : {})

    print("Processing..")

    if not Spinwheel.Debounces[Player.UserId] then
        Spinwheel.Debounces[Player.UserId] = false
    end

    local playerData = dataMain:Get(Player).Data;
    local Spins = playerData.Spins;

    if Spinwheel.Debounces[Player.UserId] == false then
        Spinwheel.Debounces[Player.UserId] = true

        if Spins == 0 then

            Spinwheel.Reject(Player)

            task.delay(1, function()
                Spinwheel.Debounces[Player.UserId] = false
            end)
        else
    
            print("Can Spin..")
    
            playerData.Spins = playerData.Spins - 1

            print(playerData.Spins)
    
            Spinwheel.UpdateSpins(Player, playerData.Spins)
            local result, array = Spinwheel.Spin()
            local index = array.Index
    
            ClientCommunication:Fire(net.Players({Player}), {
    
                Request = "Spinwheel";
                Action = "Spin";
        
                Arguments = {Index = index, Item = result}
        
            })

            task.delay(5, function()

                Spinwheel.Debounces[Player.UserId] = false

                if array.RewardType == "Currency" then

                    local currency = array.Arguments.Currency;
                    local reward = array.Arguments.Reward;

                    print(playerData[currency])

                    playerData[currency] = playerData[currency] + reward;

                    print(playerData[currency])

                    ClientCommunication:Fire(net.Players({Player}), {
	
                        Request = "Inventory";
                        Action = "LoadCash";
                
                        Arguments = {
                            Cash = playerData[currency];
                        }
                    })

                    print("Rewarded player.")
                    
                end
            end)
        end
    else
        Spinwheel.Reject(Player)
        print("IS ALR SPINNING.")
    end
end

function Spinwheel.Reject(Player)
    ClientCommunication:Fire(net.Players({Player}), {

        Request = "Spinwheel";
        Action = "Reject";

        Arguments = {}

    })
end

function Spinwheel.UpdateSpins(Player, newSpinAmount)

    ClientCommunication:Fire(net.Players({Player}), {

        Request = "Spinwheel";
        Action = "UpdateSpins";

        Arguments = {
            Spins = newSpinAmount;
        }

    })
end

function Spinwheel.Spin()
    local Rarities = Spinwheel.Chances;

    local function GetItem()
	
        local RNG = Random.new(); 
        local Counter = 0;
        
        for i, v in pairs(Rarities) do
            Counter += v.Chance
        end
        
        local Chosen = RNG:NextNumber(0, Counter);
        
        for i, v in pairs(Rarities) do
            Counter -= v.Chance
            if Chosen > Counter then
                return i, Spinwheel.Chances[i]
            end
        end
    end

    return GetItem()
end

return Spinwheel