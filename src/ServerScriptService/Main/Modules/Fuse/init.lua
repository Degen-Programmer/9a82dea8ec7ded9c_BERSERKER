local Fuse = {}
Fuse.Chances = require(script.Chances)

local QSignals = require(game.ServerScriptService.Main.Modules.Quest.Signals);
local net = require(game.ReplicatedStorage.Packages.BridgeNet2);
local inventory = require(script.Parent.Inventory);
local Gacha = require(script.Parent.Gacha.Cases);

local ClientCommunication = net.ReferenceBridge("ClientCommunication");
local Correspondences = {

    ["Common"] = "Rare";
    ["Rare"] = "Legendary";
    ["Legendary"] = "Unobtainable";
    ["Unobtainable"] = "Common";

}

local function CheckEqualVals(Array)
    if type(Array) ~= "table" or #Array == 0 then
        return
    end
    
    local Count = {}

    for Index, Value in ipairs(Array) do
        if not Count[Value] then
            Count[Value] = 1
        else
            Count[Value] += 1
        end

        if Index == #Array then
            if Count[Value] == #Array then
                return true
            else
                return false
            end
        end
    end
end

function get_dict_len(Table)

	local counter = 0 

	for _, v in pairs(Table) do
		counter =counter + 1
	end

	return counter
end

function get_base_item(Table)    
    for k, v in pairs(Table) do
        return v;
    end
end


-- // Processor function, evaluates if the player CAN fuse or not.

function Fuse.Process(Player: Player, Kwargs)

    local Rarities = {}
    local Items = Kwargs.Items;

    local BaseContainer = get_base_item(Kwargs.Items).BaseContainer;
    local BaseRarity = get_base_item(Kwargs.Items).Rarity;

    for _, Array : ImageButton in pairs(Items) do
       table.insert(Rarities, Array.Rarity)
    end

    local CanProcess = CheckEqualVals(Rarities)
    if CanProcess == false then return end

    QSignals.FuseAchieved:Fire(Player, {Signal = "FuseAchieved"});

    local Result = Rarities[1];
    local Chance = Fuse.Chances[Result];

    local ProcessedResult = Fuse._Fuse(Chance)
    
    -- // Remove the items:

    for _, _Item in pairs(Items) do

        print(_Item);

        inventory.RemoveItem(Player, {

            ["Item"] = _Item.Name;
            ["Container"] = BaseContainer;

        })

        task.wait(0.1)

    end

    local selectedItem;
    local counter = 0;

    if ProcessedResult == "Success" then

        print("Success! Rewarding player with item of hihger rarity")

        local tbl = Gacha[BaseContainer][Correspondences[BaseRarity]];
        local random = math.random(1, get_dict_len(tbl));

        for k, v in ipairs(tbl) do
            counter = counter + 1
            if counter == random then
                selectedItem = v;
            end
        end

    elseif ProcessedResult == "Failure" then

        print("Failre! Rewarding player with item of same rarity")

        local tbl = Gacha[BaseContainer][BaseRarity];
        local random = math.random(1, get_dict_len(tbl));

        for k, v in ipairs(tbl) do
            counter = counter + 1
            if counter == random then
                selectedItem = v;
            end
        end
    end

    inventory.AddItem(Player, {

        ["Item"] = selectedItem;
        ["Container"] = BaseContainer;

    })

    ClientCommunication:Fire(net.Players({Player}), {

        Request = "Fuse";
        Action = "FusedResult";
        Arguments = {

            BaseContainer = BaseContainer;
            Item = selectedItem;

        }
    })

end

function Fuse._Fuse(Rarities)

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

return Fuse