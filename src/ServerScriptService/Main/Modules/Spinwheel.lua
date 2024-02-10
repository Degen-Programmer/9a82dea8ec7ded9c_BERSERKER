local MarketplaceService = game:GetService("MarketplaceService")
local Spinwheel = {}
Spinwheel.Sessions = {}
Spinwheel.Chances = {

    ["1000 Coins"] = {

        Chance = 10;
        RewardType = "Currency";
        Reward = 1000;

    };

    ["500 Coins"] = {

        Chance = 20;
        RewardType = "Currency";
        Reward = 500;

    };

    ["Sword"] = {

        Chance = 30;
        RewardType = "Item";
        Reward = "WoodenSword";
        Container = "Weapons";

    };

    ["300 Coins"] = {

        Chance = 40;
        RewardType = "Currency";
        Reward = 300;

    };

    ["1 Coin"] = {

        Chance = 50;
        RewardType = "Currency";
        Reward = 1;

    };

    ["Other Sword"] = {

        Chance = 20;
        RewardType = "Item";
        Reward = "Endsword";
        Container = "Weapons"

    };

    ["Aura"] = {

        Chance = 60;
        RewardType = "Item";
        Reward = "CorpsePiler";
        Container = "Auras";

    };

    ["Dash"] = {

        Chance = 10;
        RewardType = "Item";
        Reward = "Dash";
        Container = "Abilities";

    };
}

local dataMain = require(game.ServerScriptService.Main.Data)
local combat = require(game.ServerScriptService.Main.Combat.Users);
local net = require(game.ReplicatedStorage.Packages.BridgeNet2);
local inventory = require(script.Parent.Inventory);
local GachaSignals = require(game.ServerScriptService.Main.Modules.Products.Signals)
local MY_FUCKING_ROBUX = require(script.Parent.Products);

local ClientCommunication = net.ReferenceBridge("HUD");

function Spinwheel.ChooseItem()
    
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

function Spinwheel.ReplicateResult(plr : Player, Result : string)
    ClientCommunication:Fire(net.Players({plr}), {

        Element = "Spinwheel";
        Action = "Spin";
        Arguments = {
            Index = Result;
        }

    })
end

function Spinwheel.ProcessRequest(player : Player, Kwargs)
    
    if Spinwheel.Sessions[player.UserId] then return end
    Spinwheel.Sessions[player.UserId] = "X";

    local player_data = dataMain:Get(player).Data;
    if player_data.Spins == 0 then return end

    local Item = Spinwheel.ChooseItem()
    Spinwheel.ReplicateResult(player, Item)

    

end

return Spinwheel