local Quest = {}

local dataMain = require(game.ServerScriptService.Main.Data)
local combat = require(game.ServerScriptService.Main.Combat.Users);
local net = require(game.ReplicatedStorage.Packages.BridgeNet2);
local inventory = require(script.Parent.Inventory);
local configs = require(script.QuestConfigs);

local ClientCommunication = net.ReferenceBridge("ClientCommunication");

task.spawn(function()
    for KEY, signal : RBXScriptSignal in pairs(require(script.Signals)) do
        signal:Connect(function(Player : Player, Kwargs : {})

            Quest.Update(Player, {Quest = KEY, Signal = Kwargs.Signal})

        end)
    end
end)

function get(tbl, int)

    local c  = 0;

    for k, v in pairs(tbl) do
        c += 1
        if int == c then
            return k, v;
        end
    end
end

function get_table_len(tbl)
    local c  = 0;

    for k, v in pairs(tbl) do
        c += 1
    end

    return c;

end

function deep_Copy(original)

	local copy = {}

	for k, v in pairs(original) do

		if type(v) == "table" then
			v = deep_Copy(v)
		end

		copy[k] = v

	end

	return copy

end



function Quest.Load(Player: Player, Kwargs: {})

    local Quest = Kwargs.Quest;

    local data = dataMain:Get(Player).Data;
    local DataQuests = data.Quests;
    local TimeAdded = DataQuests.TimeAdded

    local function _Load()
        task.spawn(function()

            local Temp = {}
            local workerTable = deep_Copy(configs);
    
            for i = 1, 3 do
    
                local rand = math.random(1, get_table_len(workerTable));
                local Name, Quest = get(workerTable, rand);
    
                Temp[Name] = Quest;
                workerTable[Name] = nil;
    
                DataQuests.Container[Name] = Quest;
                TimeAdded = os.date("%I")
    
                ClientCommunication:Fire(net.Players({Player}), {
    
                    Request = "Quests";
                    Action = "New";
                    Arguments = {Quest = Quest; Name = Name;}
                    
                })

                print(DataQuests)
    
            end
    
            table.clear(Temp);
            table.clear(workerTable);
    
        end)
    end

    -- // time has expired: start new quest batch.

    print(TimeAdded)

    if get_table_len(DataQuests.Container) == 0 then

        print("No quests, starting new batch.")

        _Load()

    elseif get_table_len(DataQuests.Container) == 3 then
        if os.date("%I") == 12 then

            print("times up :)")
            _Load()

        else

            print("There is still time left, loading all quests.")

            for k, v in pairs(DataQuests.Container) do

                print(k)

                ClientCommunication:Fire(net.Players({Player}), {
                
                    Request = "Quests";
                    Action = "New";
                    Arguments = {Quest = v; Name = k;}

                })

            end

            for k, v in pairs(DataQuests.Container) do
                ClientCommunication:Fire(net.Players({Player}), {
                
                    Request = "Quests";
                    Action = "Update";
                    Arguments = {Progress = v.Progress; Requirement = v.Requirement; Name = k;}

                })
            end
        end
    end
end

function Quest.Update(Player: Player, Kwargs: {})

    local Name = Kwargs.Quest;
    local Signal = Kwargs.Signal;

    print(Signal)

    local data = dataMain:Get(Player).Data;
    local DataQuests = data.Quests;
    
    local selectedQuest = nil;
    local qname = nil;

    for k, quest in pairs(DataQuests.Container) do
        if quest.Signal == Signal then
            
            selectedQuest = quest;
            qname = k;

            print(selectedQuest, "Quest found.")
            break;

        end
    end

    if selectedQuest then
        if selectedQuest.Progress < selectedQuest.Requirement then
            
            print("Quest can progress.")

            selectedQuest.Progress += 1;

            ClientCommunication:Fire(net.Players({Player}), {
    
                Request = "Quests";
                Action = "Update";
                Arguments = {Progress = selectedQuest.Progress; Requirement = selectedQuest.Requirement; Name = qname;}
                
            })

            if selectedQuest.Progress == selectedQuest.Requirement then
                selectedQuest.Completed = true;
                print("Quest has been completed. It can now be claimed.")
            end

        else
            
            selectedQuest.Completed = true;
            print("Quest has already been compelted.")

        end
    end
end

function Quest.Claim(Player, Kwargs)

    print("Claim request recvd")
    
    local data = dataMain:Get(Player).Data;
    local DataQuests = data.Quests.Container;

    local claimRequest = Kwargs.Quest;
    local corresponding = DataQuests[claimRequest];

    print(corresponding, DataQuests, claimRequest)

    if corresponding then
        
        print("Quest Exists")
        if corresponding.Completed == true and corresponding.Claimed == false then
            
            corresponding.Claimed = true;
            print("Quest has been claimed")

            -- // reward the player:

            print(data);

            data[corresponding.Currency] += corresponding.Reward;

            print(data);

            ClientCommunication:Fire(net.Players({Player}), {
	
				Request = "Inventory";
				Action = "LoadCash";
		
				Arguments = {
					Cash = data.Currency;
				}
			})

        else
            print("Quest has already been claimed and not or completed.")
        end
    end
end

return Quest