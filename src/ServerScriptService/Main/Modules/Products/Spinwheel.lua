local Spinwheel = {}
Spinwheel.Products = {

    ["1721874331"] = {Spins = 5; Name = "5Spins"};
    ["1721875653"] = {Spins = 10; Name = "10Spins"};
    ["1721876061"] = {Spins = 15; Name = "15Spins"};
    ["1721877948"] = {Spins = 20; Name = "20Spins"};
    ["1721878682"] = {Spins = 25; Name = "25Spins"};
    ["1721880043"] = {Spins = 35; Name = "35Spins"};
    ["1721881340"] = {Spins = 45; Name = "45Spins"};

}

local DataMain = require(game.ServerScriptService.Main.Data)
local Net = require(game.ReplicatedStorage.Packages.BridgeNet2)

local Bridge = Net.ReferenceBridge("HUD")

function Spinwheel.FulfillPromise(Player, PRODUCT_PURCHASE_ID)
    
    local Data = DataMain:Get(Player).Data;
    local ProductData = Spinwheel.Products[PRODUCT_PURCHASE_ID]

    Data.Spins += ProductData.Spins
    
    Bridge:Fire({

        Element = "Spinwheel";
        Action = "UpdateSpins";
        Arguments = {

            Spins = Data.Spins;

        }

    })

    print("Succesful.", Data)

end

return Spinwheel