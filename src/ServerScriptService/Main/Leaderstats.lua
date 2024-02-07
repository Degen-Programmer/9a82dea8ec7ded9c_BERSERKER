local Leaderstats = {}

local dataMain = require(script.Parent.Data)

function Leaderstats.SetupLeaderboard(player : Player)
    
    local folder = Instance.new("Folder")
    folder.Name = "leaderstats"
    folder.Parent = player;

    local Wins = Instance.new("IntValue")
    Wins.Parent = folder;
    Wins.Value = 0;
    Wins.Name = "Wins"

    local Kills = Instance.new("IntValue")
    Kills.Parent = folder;
    Kills.Value = 0;
    Kills.Name = "Kills"

    return Wins, Kills
    
end

function Leaderstats.AddKill(player : Player)
    
    local Kills : IntValue = player.leaderstats.Kills;
    Kills.Value += 1;

    dataMain:Get(player).Data.Kills = Kills.Value;

    print(dataMain:Get(player).Data)

end


function Leaderstats.AddWin(player : Player)
    
    dataMain:Get(player).Data.Wins += 1;

    print(dataMain:Get(player).Data)
    
end

return Leaderstats