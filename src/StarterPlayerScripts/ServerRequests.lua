local Rep = game:GetService("ReplicatedStorage")
local Get : RemoteEvent = Rep.Get

local Player = game.Players.LocalPlayer
local requests = {}

function requests.GetMousePosition()
    return Player:GetMouse().Hit.Position
end

Get.OnClientEvent:Connect(function(request, args)

    print("Got?")

    local result = requests[request](args)
    Get:FireServer(Player, "MousePos", result)
    
end)
