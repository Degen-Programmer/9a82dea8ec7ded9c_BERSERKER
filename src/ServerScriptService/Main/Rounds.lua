local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local Round = {}

Round.__index = Round
Round.CurrentRound = nil;

local DataMain = require(script.Parent.Data)
local CombatUsers = require(script.Parent.Combat.Users)
local Signal = require(game.ReplicatedStorage.Packages.GoodSignal)
local Net = require(game.ReplicatedStorage.Packages.BridgeNet2)
local QSignals = require(game.ServerScriptService.Main.Modules.Quest.Signals);
local leaderstats = require(script.Parent.Parent.Main.Leaderstats)

local clientCommunication = Net.ReferenceBridge("ClientReplicator")
local UI_Updater = Net.ReferenceBridge("UI_Updater")
local serverStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local serverAssets = serverStorage.Assets;

local Maps = serverAssets.Maps;
local defaultMap = Maps.Magma;

--[[

    Stages of a round:

    1) Voting: players are voting for the next gamemode. -- 10 seconds 
    2) Unpacking: Maps is unpacked into worskpace. -- 5 seconds.
    3) Game beginds, berserker and champion are chosen with a delay of 5 seconds. (3 seconds for the timer to play, 2 seconds as a buffer)
    4) when the gamme ends, winner is displayed to all players - 4 seconds.
    5) Inermission of 10 seconds.

]]

function Round.New()
   
    local self = {

        RoundState = "Inactive";
        Berserker = nil;
        Champion = nil;
        LastBerserker = nil;
        LastChampion = nil;
        PlayerLeaveConnections = {};
        PlayerKilledConnections = {};

        RoundEnded = Signal.new();
        PlayerKilled = Signal.new();
        RoundStart = Signal.new();
        CurrentMap = nil;
        Players = {};

    }

    Round.CurrentRound = self;

    setmetatable(self, Round)
    return self;

end

function Round:GetChampion()
    
end

function Round:GetBerserker()
    
end

function Round:CheckPlayerOpponent(player: Player)
    print("func called.")
    if player == self.CurrentRound.Berserker then 
        return "Berserker", self.CurrentRound.Champion.Character
    elseif player == self.CurrentRound.Champion then
        return "Champion", self.CurrentRound.Berserker.Character
    end
end

function Round:StartVoting()

    for _, v in ipairs(Workspace.FX:GetChildren()) do
        if v then v:Destroy() end
    end

    task.wait(3)

    print("Voting started.")

    -- // start game if there are more than 1 player.

    UI_Updater:Fire(Net.AllPlayers(), {

        Command = "UpdateStatus";
        Arguments = {

            Status = "Vote for your next gamemode! ends in: ";
            Timer = true;
            Time = 10;

        }

    })

    -- // start voting:

    UI_Updater:Fire(Net.AllPlayers(), {

        Command = "StartVoting";
        Arguments = {
        }

    })
    
    -- start game

    task.wait(10)

    self:StartGame();
end

function Round:AddHighlight(Character: Model, Role)

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1;
    highlight.OutlineTransparency = 0;
    highlight.Name = "__HIGHLIGHT__"
    
    if Role == "Berserker" then
        highlight.OutlineColor = Color3.new(255, 0, 0)    
    elseif Role == "Champion" then
        highlight.OutlineColor = Color3.new(1, 1, 1)
    end
        
    highlight.Parent = Character;

end

--[[

 if #self.CurrentRound.Players > 2 then
        
        print("Selecting with checking for last berserker.")

        repeat 

            local RAND = math.random(1, #self.CurrentRound.Players)
            local player = self.CurrentRound.Players[RAND]
    
            self.CurrentRound[Target] = player
    
        until player~= self.CurrentRound[Opposer] and player ~= self.CurrentRound.LastChampion and player ~= self.CurrentRound.LastBerserker;

    elseif #self.CurrentRound.Players == 2 then

        print("Selecting without checking for last berserker.")

        repeat 

            local RAND = math.random(1, #self.CurrentRound.Players)
            local player = self.CurrentRound.Players[RAND]
    
            self.CurrentRound[Target] = player
    
        until player~= self.CurrentRound[Opposer]
    end

    local Plr = self.CurrentRound[Target]
    
    if self.CurrentRound[Target] == self.CurrentRound.Berserker then
        self.CurrentRound.LastBerserker = Plr;
    elseif self.CurrentRound[Target] == self.CurrentRound.Champion then
        self.CurrentRound.LastChampion = Plr;
    end

    clientCommunication:Fire(Net.AllPlayers(), {

        Request = "Combat";
        Action = Target.."Chosen";
        Arguments = {

            Subject = Plr;

        }

    })

    local data = DataMain:Get(Plr).Data;
    local aura = nil;

    if data.Aura == "Default" then
        aura = Target;
    else
        aura = data.Aura;   
    end

    print(aura)

    clientCommunication:Fire(Net.AllPlayers(), {

        Request = "Combat";
        Action = "LoadAura";
        Arguments = {

            Subject = Plr;
            Aura = aura;
        }

    })

    self:AddHighlight(self.CurrentRound[Target].Character, Target)

    print("Chose: "..self.CurrentRound[Target].Name.. "As "..Target)
    return self[Target]

]]

function Round:Choose(Target, Opposer)

    repeat 

        local RAND = math.random(1, #self.CurrentRound.Players)
        local player = self.CurrentRound.Players[RAND]

        self.CurrentRound[Target] = player

    until player~= self.CurrentRound[Opposer]

    local Plr = self.CurrentRound[Target]

    clientCommunication:Fire(Net.AllPlayers(), {

        Request = "Combat";
        Action = Target.."Chosen";
        Arguments = {

            Subject = Plr;

        }

    })

    local data = DataMain:Get(Plr).Data;
    local aura = nil;

    if data.Aura == "Default" then
        aura = Target;
    else
        aura = data.Aura;   
    end

    print(aura)

    clientCommunication:Fire(Net.AllPlayers(), {

        Request = "Combat";
        Action = "LoadAura";
        Arguments = {

            Subject = Plr;
            Aura = aura;
        }

    })

    self:AddHighlight(self.CurrentRound[Target].Character, Target)

    print("Chose: "..self.CurrentRound[Target].Name.. "As "..Target)
    return self[Target]

end

function Round:DismissPlayer(player)
    clientCommunication:Fire(Net.AllPlayers(), {

        Request = "Combat";
        Action = "RemoveAura";
        Arguments = {

            Subject = player;

        }

    })
end

function Round:RemovePlayer(player)

    table.remove(self.CurrentRound.Players, table.find(self.CurrentRound.Players, player))

    if #self.CurrentRound.Players >= 2 then
        if player == self.CurrentRound.Berserker or player == self.CurrentRound.Champion then
            if player == self.CurrentRound.Berserker then

                self:DismissPlayer(self.CurrentRound.Champion)
                self.CurrentRound.Champion = nil;
    
            end
    
            if player == self.CurrentRound.Champion then
    
                self:DismissPlayer(self.CurrentRound.Berserker)
                self.CurrentRound.Berserker = nil;
    
            end
    
            self:Choose("Berserker", "Champion") 
            self:Choose("Champion", "Berserker") 
    
            Net.ReferenceBridge("HUD"):Fire(Net.AllPlayers(), {
    
                Element = "HUD";
                Action = "NewRound";
        
                Arguments = {Berserker = self.CurrentRound.Berserker.Name, Champion = self.CurrentRound.Champion.Name}
        
            })    
        end

        print("Condition >= 1 Met")
        
    elseif #self.CurrentRound.Players == 1 then

        print("Condition 1 Met")
        self:EndGame("Won", self.CurrentRound.Players[1])

    elseif #self.CurrentRound.Players == 0 and self.CurrentRound.RoundState == "Active" then

        print("Condition 0 Met")
        
        self:DestroyMap();
        self:EndGame("KillGame")

    end
end

function Round:UnpackMap()

    local maps = Maps:GetChildren();

    local newFault =  maps[math.random(1, #maps)]:Clone();
    newFault.Parent = workspace.Map
    newFault.Name = "_MAP"
    newFault:SetPrimaryPartCFrame(workspace.Map.ArenaCenter.CFrame)

    self.CurrentRound.CurrentMap = newFault;

end

function Round:DestroyMap()
    if self.CurrentRound.CurrentMap then
        self.CurrentRound.CurrentMap:Destroy();
        self.CurrentRound.CurrentMap = nil;
    end
end

function Round:StartGame()

    print("START CALLED.")

    UI_Updater:Fire(Net.AllPlayers(), {

        Command = "UpdateStatus";
        Arguments = {    
            Status = "Loading map..."
        }

    })

    self:UnpackMap()

    task.delay(5, function() -- // wait for map to load:

        for _, player in ipairs(game.Players:GetPlayers()) do
        
            local player_data = DataMain.Objects[player.UserId]
    
            if player_data then
                if player_data.Loaded == true and player.Character  and player.Character.Humanoid.Health > 0 then

                    -- // Disable UI

                    --player.PlayerGui.Root.Menus.Inventory.Active = false;

                    print("player data loaded, player is in game and player is alive.")
                    table.insert(self.CurrentRound.Players, player)
                else
                    continue
                end
            end
        end

        self.CurrentRound.handler_thread = task.spawn(function()
            if #self.CurrentRound.Players >= 2 then
                
                self.CurrentRound.RoundState = "Active";

                --[[UI_Updater:Fire(Net.AllPlayers(), {

                    Command = "Countdown";
                    Arguments = {    
                        --Status = "Loading map..."
                    }
            
                })]]

                self:Choose("Berserker", "Champion");
                self:Choose("Champion", "Berserker");

               --[[task.delay(5, function()
                   
                    self:Choose("Berserker", "Champion");
                    self:Choose("Champion", "Berserker");

                    Net.ReferenceBridge("HUD"):Fire(Net.AllPlayers(), {

                        Element = "HUD";
                        Action = "NewRound";
                
                        Arguments = {Berserker = self.CurrentRound.Berserker.Name, Champion = self.CurrentRound.Champion.Name}
                
                    })
               end)]]
    
                UI_Updater:Fire(Net.AllPlayers(), {
    
                    Command = "UpdateStatus";
                    Arguments = {
                        Status = "Game is ongoing.";
                    }
                
                })
    
                for _, v : Player in ipairs(self.CurrentRound.Players) do
    
                    local Character = v.Character;
                    Character.PrimaryPart.CFrame = workspace.Map.ArenaCenter.CFrame + CFrame.new(math.random(-30, 30), 4, math.random(-30, 30)).Position
    
                    self.CurrentRound.PlayerLeaveConnections[v.UserId] = game.Players.PlayerRemoving:Connect(function(player)
                        if player == v then
                            self:RemovePlayer(v)

                            if table.find(self.CurrentRound.Players, player) then
                                print("Player who left was a part of the game!!!!")
                            end
                        
                            local connection = self.CurrentRound.PlayerLeaveConnections[player.UserId]
                            print(connection, "dc'ed leave connection", v.Name, player.Name)
                        
                            if connection then
                                connection:Disconnect()
                            end
                        end
                    end)
    
                    self.CurrentRound.PlayerKilledConnections[v.UserId] = v.Character.Humanoid.Died:Connect(function()
    
                        self.CurrentRound.PlayerKilled:Fire(v)
                        CombatUsers[v.UserId]:Reset()

                        if v == self.CurrentRound.Berserker then
                            print("Bers was killed")
                            QSignals.BerserkerKillAchieved:Fire(self.CurrentRound.Champion, {Signal = "BerserkerKillAchieved"})
                        end

                        if v == self.CurrentRound.Champion then
                            print("champo was killed")
                            QSignals.ChampionKillAchieved:Fire(self.CurrentRound.Berserker, {Signal = "ChampionKillAchieved"})
                        end

                        self:RemovePlayer(v)
    
                        ---v.PlayerGui.Root.Menus.Inventory.Active = true;
    
                        local connection = self.CurrentRound.PlayerLeaveConnections[v.UserId]
                        print(connection, "disconnected death connection")
    
                        if connection then
                            connection:Disconnect()
                        end
                    end)
                end
            else

                self:DestroyMap();
                self:EndGame("KillGame")

            end
        end)
    end)
end

function Round:EndGame(Message: string, Winner)

    print("Game Ended.")

    self.CurrentRound.RoundState = "Inactive";
    if self.CurrentRound.handler_thread then task.cancel(self.CurrentRound.handler_thread) end

    for _, v in ipairs(self.CurrentRound.PlayerKilledConnections) do
        if v then v:Disconnect() end
    end

    for _, v in ipairs(self.CurrentRound.PlayerLeaveConnections) do
        if v then v:Disconnect() end
    end

    task.spawn(function()
       task.delay(2, function()

            for _, v in ipairs(self.CurrentRound.Players) do

                print(v.Character:GetAttribute("AFK"))
                CombatUsers[v.UserId]:Reset();

                if v and v.Character:GetAttribute("AFK") == false then 
                    print("Man is NOT AFK.")
                    v:LoadCharacter() 
                end

                task.delay(2, function()
                  --  v.PlayerGui.Root.Menus.Inventory.Active = true;
                end)

                table.remove(self.CurrentRound.Players, table.find(self.CurrentRound.Players, v))

            end
       end)
    end)

    print(self.CurrentRound.Players)

    --Round.CurrentRound.RoundState = "Inactive"
    
    if Message == "KillGame" then

        task.spawn(function()
            UI_Updater:Fire(Net.AllPlayers(), {

                Command = "UpdateStatus";
                Arguments = {
                    Status = "Not enough players! starting new game soon.";
                }
        
            })
        end)

    elseif Message == "Won" then

        task.spawn(function()
            UI_Updater:Fire(Net.AllPlayers(), {

                Command = "UpdateStatus";
                Arguments = {
                    Status = "A gamer has won!";
                }
        
            })
    
            if Winner then 

                QSignals.WinAchieved:Fire(Winner, {Signal = "WinAchieved"});
                leaderstats.AddWin(Players)

                UI_Updater:Fire(Net.AllPlayers(), {
    
                    Command = "DisplayWinner";
                    Arguments = {
                        Winner = Winner;
                    }
            
                })
            end
        end)
    end

    task.wait(4)

    self:DestroyMap()

    UI_Updater:Fire(Net.AllPlayers(), {

        Command = "UpdateStatus";
        Arguments = {
            
            Status = "New game starting in: ";
            Timer = true;
            Time = 9;

        }

    })

    task.wait(10)

    Round:StartVoting()
    
end

return Round