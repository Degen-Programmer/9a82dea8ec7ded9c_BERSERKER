local Gacha = {}
Gacha.Sessions = {}
Gacha.Requirements = {

    ["10"] = 500;
    ["15"] = 1000;
    ["20"] = 1500;
    ["25"] = 3000;
    ["30"] = 3500;

}

-- loop through the dictionary gacha.Requirements and return the value closes to the number "5"

Gacha.Chances = {

    ["Weapons"] = {

        ["WoodenSword"] = 10;
        ["WoodenGreatsword"] = 10;
        ["WatchersDagger"] = 10;
        ["TechnoKatana"] = 10;
        ["StoneKnife"] = 10;
        ["Shield"] = 10;
        ["RitualSword"] = 10;
        ["MagesStaff"] = 10;
        ["AncientDagger"] = 10;
        ["Lifeweaver"] = 10;
        ["Katana"] = 10;
        ["JotunnGreatsword"] = 10;
        ["Hammer"] = 10;
        ["Greatsword"] = 10;
        ["GreatHammer"] = 10;
        ["DryadsThorn"] = 10;
        ["Doomcaller"] = 10;
        ["BoStaff"] = 10;
        ["BattleAx"] = 10;
        ["Bat"] = 10;
        ["ViridianSword"] = 10;
        ["ViridianDagger"] = 10;
        ["DivineClaymore"] = 10;
        ["Sundial"] = 10;
        ["Stonesword"] = 10;
        ["RustedCleaver"] = 10;
        ["Darksword"] = 10;
        ["RedsteelDagger"] = 10;
        ["PinkyPower"] = 10;
        ["Lifebreaker"] = 10;
        ["IronBroadsword"] = 10;
        ["HookedDagger"] = 10;
        ["GoldenCleaver"] = 10;
        ["GoblinsMachette"] = 10;
        ["FlankedGreatsword"] = 10;
        ["Endsword"] = 10;
        ["Badsword"] = 10;
        ["DraconicRapier"] = 10;
        ["RunicXiphos"] = 10;
        ["Cleaver"] = 10;
        ["SwordOfHonor"] = 10;

    };

    ["Abilities"] = {
        

    }

}

function findClosestValueInDict(dict, target)

    if next(dict) == nil or not target then
        return nil 
    end

    local closestValue = nil
    local closestDiff = math.huge
    local x = nil;

    for key, value in pairs(dict) do
        local currentDiff = math.abs(value - target)
  
        if currentDiff < closestDiff then
            closestValue = value
            closestDiff = currentDiff
            x = key;
        end
    end

    return closestValue, x

 end

local dataMain = require(game.ServerScriptService.Main.Data)
local combat = require(game.ServerScriptService.Main.Combat.Users);
local net = require(game.ReplicatedStorage.Packages.BridgeNet2);
local inventory = require(script.Parent.Inventory);
local MY_FUCKING_ROBUX = require(script.Parent.Products);

local HUD = net.ReferenceBridge("HUD")

function Gacha.Process(Player : Player, Kwargs)
    
    local playerData = dataMain:Get(Player).Data;

    local Container = Kwargs.Container
    local Times = Kwargs.Times;

    local list

    if Kwargs.Times == "5" then
        list = Gacha.Select(Player, Container, Kwargs.Times)
    elseif Kwargs.Times == "Max" then
        print("Selecting max")
        local value, times = findClosestValueInDict(Gacha.Requirements, playerData.Kills)
        print(value, times)
        list = Gacha.Select(Player, Container, times)
    end


    HUD:Fire(net.Players({Player}), {

        Element = "Gacha";
        Action = "PlayAnimation";
        Arguments = {

            List = list;
            Container = Container;
            Times = #list;

        }

    })

end

function Gacha.Update(Player, Kills)

    local result, key = findClosestValueInDict(Gacha.Requirements, Kills)

    HUD:Fire(net.Players({Player}), {

        Element = "Gacha";
        Action = "Update";
        Arguments = {

            Max = key;

        }

    })
    
end

function Gacha.Select(plr, Container, Times)

    Gacha.Update()

    local Rarities = Gacha.Chances[Container];
    local list = {}

    local function GetItem()
	
        local RNG = Random.new(); 
        local Counter = 0;
        
        for i, v in pairs(Rarities) do
            Counter += v
        end
        
        local Chosen = RNG:NextNumber(0, Counter);
        
        for i, v in pairs(Rarities) do
            Counter -= v
            if Chosen > Counter then
                return i
            end
        end
    end

    for i = 1, Times do

        local item = GetItem()
        table.insert(list, item)

        inventory.AddItem(plr, {Item = item; Container = Container; ItemCount = 1})

    end

    return list
end

return Gacha;
