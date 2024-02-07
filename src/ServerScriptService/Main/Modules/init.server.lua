local net = require(game.ReplicatedStorage.Packages.BridgeNet2)
local comm = net.ReferenceBridge("ServerCommunication")

require(script.Quest);
require(script.Products);

comm:Connect(function(Player, keywordArgs)

    print(keywordArgs)

    local Request = keywordArgs.Request
    local Action = keywordArgs.Action;
    local kwargs = keywordArgs.Arguments;

    require(script:FindFirstChild(Request))[Action](Player, kwargs)
    
end)