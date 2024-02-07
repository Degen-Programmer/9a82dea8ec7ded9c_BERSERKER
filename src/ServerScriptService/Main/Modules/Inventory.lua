local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Inventory = {}

local dataMain = require(game.ServerScriptService.Main.Data)
local combat = require(game.ServerScriptService.Main.Combat.Users);
local net = require(game.ReplicatedStorage.Packages.BridgeNet2);

local ClientCommunication = net.ReferenceBridge("ClientCommunication");
local HUD = net.ReferenceBridge("HUD")

function GetItemStack(PlayerData, Kwargs)

    local Inventory = PlayerData.Inventory;

    local Container = Inventory[Kwargs.Container];
    local ItemStack = Container[Kwargs.Item];
    
    return ItemStack, Container

end

function Inventory.AddItem(Player : Player, Kwargs : {})
    
    -- // get Item Stack:

    local PlayerData = dataMain:Get(Player).Data;
    local ItemStack, ItemContainer = GetItemStack(PlayerData, Kwargs)

    -- // Item Stack Already Exists, Increment it by 1:

    if ItemStack then
        ItemStack = ItemStack + Kwargs.ItemCount;
    elseif not ItemStack then
        ItemContainer[Kwargs.Item] = Kwargs.ItemCount;
    end

    print(ItemStack)

    HUD:Fire(net.Players({Player}), {

        Element = "Inventory";
        Action = "AddItem";
        Arguments = {

            Item = Kwargs.Item;
            Count =   ItemStack;
            Container = Kwargs.Container;

        }

    })
    
end

function Inventory.RemoveItem(Player : Player, Kwargs : {})
    
    -- // get Item Stack:

    local PlayerData = dataMain:Get(Player).Data;
    local ItemStack, ItemContainer = GetItemStack(PlayerData, Kwargs)

    if not ItemStack or not ItemContainer then print("Exception: Stack or Container returned null") return end
    
    PlayerData.Inventory[Kwargs.Container][Kwargs.Item] -= Kwargs.Count;

    if PlayerData.Inventory[Kwargs.Container][Kwargs.Item] == 0 then
        PlayerData.Inventory[Kwargs.Container][Kwargs.Item] = nil;

        HUD:Fire(net.Players({Player}), {

            Element = "Inventory";
            Action = "DeleteItem";
            Arguments = {
    
                Item = Kwargs.Item;
                Container = Kwargs.Container;

            }
    
        })

    else
        
        HUD:Fire(net.Players({Player}), {

            Element = "Inventory";
            Action = "RemoveItem";
            Arguments = {
    
                Item = Kwargs.Item;
                Count = PlayerData.Inventory[Kwargs.Container][Kwargs.Item];
                Container = Kwargs.Container;
    
            }
        })

    end
end

--[[

    function that equips an item, if the player has it that is.

    @function Inventory.Equip()

        @param        Player          Player          The player to equip the item to.
        @key        Item            string          The item to equip.
        @key        Container       string          The container to equip the item from.

]]

function Inventory.Equip(Player : Player, Kwargs: {})
    
    local Profile = dataMain:Get(Player).Data;

    local BaseContainer = Kwargs.Container;
    local Item = Kwargs.Item;

    local DataContainer = Profile.Inventory[BaseContainer];

    if BaseContainer == "Weapons" then
        print(Item)
        Profile.Weapon = Item;
        combat[Player.UserId]:ChangeWeapon(Item);
    end

    if BaseContainer == "Abilities" then
        Profile.Ability = Item;
        combat[Player.UserId]:ChangeAbility(Item);
    end

    if BaseContainer == "Auras" then
        print("CHANGING AURAS...")
        Profile.Aura = Item;
        print(Profile.Aura)
    end
end

return Inventory