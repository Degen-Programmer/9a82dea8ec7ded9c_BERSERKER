task.wait(1.5);

local player = game.Players.LocalPlayer
local character = player.Character;

local BridgeNet = require(game.ReplicatedStorage.Packages:FindFirstChild("BridgeNet2"));
local hd = require(script.HUD)
local playerHud = require(script.HUD.PlayerHUD)

function DeployHUD()

    local HBJ = hd.New({"M1", "Stamina", "Ability", "Eliminations", "Inventory", "Buttons", "Trading"})

    hd.CurrentHud = HBJ;
    HBJ:Deploy()

    playerHud.HUD = HBJ;

end


DeployHUD()

print(playerHud.HUD, "NEW HUD MADE.")

local __HUD = BridgeNet.ReferenceBridge("HUD")

__HUD:Connect(function(Args)
    hd.CurrentHud:ParseRequest(Args)
end)