local Fusing = {}
Fusing.Sessions = {}

-- // modules:

local dataMain = require(game.ServerScriptService.Main.Data)
local combat = require(game.ServerScriptService.Main.Combat.Users);
local net = require(game.ReplicatedStorage.Packages.BridgeNet2);
local inventory = require(script.Parent.Inventory);
local GachaSignals = require(game.ServerScriptService.Main.Modules.Products.Signals)
local MY_FUCKING_ROBUX = require(script.Parent.Products);

function Fusing.ProcessRequest(Player, kwargs : {})

    if Fusing.Sessions[Player.UserId] then return end
    Fusing.Sessions[Player.UserId] = "X";

    local player_data = dataMain:Get(Player).Data;

end

return Fusing