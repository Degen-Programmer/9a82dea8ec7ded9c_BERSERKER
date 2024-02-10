local player = game.Players.LocalPlayer
local character = player.Character;

local BridgeNet = require(game.ReplicatedStorage.Packages:FindFirstChild("BridgeNet2"));
local clientReplicator = BridgeNet.ReferenceBridge("ClientReplicator")

clientReplicator:Connect(function(Args)
    require(script:FindFirstChild(Args.Request) ) [Args.Action](Args.Arguments)
end)