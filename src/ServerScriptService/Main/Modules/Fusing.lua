local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusing = {}
Fusing.Sessions = {}
Fusing.Chances = {

    ["Success"] = 10;
    ["Failure"] = 90;

}

-- // modules:

local dataMain = require(game.ServerScriptService.Main.Data)
local combat = require(game.ServerScriptService.Main.Combat.Users);
local net = require(game.ReplicatedStorage.Packages.BridgeNet2);
local inventory = require(script.Parent.Inventory);
local MY_FUCKING_ROBUX = require(script.Parent.Products);

local HUD = net.ReferenceBridge("HUD")

function Fusing.Fuse()
    local Rarities = Fusing.Chances;

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
                return i, Fusing.Chances[i]
            end
        end
    end

    return GetItem()
end

function Fusing.ReplicateResult(Player, Kwargs)
    
    HUD:Fire(net.Players({Player}), {

        Element = "Fusing";
        Action = "PlayAnimation";
        Arguments = Kwargs;

    })

end

function Fusing.RewardItem(Player, Reward)

    inventory.AddItem(Player, {

        Container = "Weapons";
        Item = Reward;
        ItemCount = 1;

    })

end

function Fusing.ProcessRequest(Player, kwargs : {})

    print(Player, kwargs)

    if Fusing.Sessions[Player.UserId] then return end
    Fusing.Sessions[Player.UserId] = "X";

    local player_data = dataMain:Get(Player).Data;

    if player_data.Inventory[kwargs.Container][kwargs.Item] == nil then return end
    if player_data.Inventory[kwargs.Container][kwargs.Item] < 3 then return end
    
    print("Item exists and is over the count of 3.")

    -- // Start fusing process

    local Item, Rarity = Fusing.Fuse()

    print(Item, Rarity)

    if Item == "Failure" then
        
        Fusing.RewardItem(Player, kwargs.Item)
        Fusing.ReplicateResult(Player, {Item = kwargs.Item; BaseItem = kwargs.Item; BaseContainer = kwargs.Container; Result = "Failure";})

    end

    if Item == "Success" then

        Fusing.RewardItem(Player, "Endsword")
        Fusing.ReplicateResult(Player, {Item = "Endsword"; BaseItem = kwargs.Item; BaseContainer = kwargs.Container; Result = "Success";})

    end

    for i = 1, 3 do

        inventory.RemoveItem(Player, {

            Container = kwargs.Container;
            Item = kwargs.Item;
            Count = 1;

        })

    end

    task.delay(5, function()
        Fusing.Sessions[Player.UserId] = nil
    end)
end

return Fusing