local HttpService = game:GetService("HttpService")

local Replicator = require(script.Parent.Replication) 
local RoundManager = require(script.Parent.Parent.Rounds) 

local validater = {}
validater.ActiveSessions = {}

function validater.Find(str)

    local function getN()
        local c = 0;

        for k, v in pairs(validater.ActiveSessions) do
            c += 1
        end

        return c;
    end

    if getN() == 0 then
        return "CAN"
    elseif getN() > 0 then

        local c = 0;

        for k, v in pairs(validater.ActiveSessions) do
            if k == str then
                c += 1;
                return "CAN"
            end
        end

        if c == getN() then
            return "CANNOT"
        end
    end
end

function validater.Validate(self: {}, Hitter_CombatData: {}, Result)

    local HTTP = HttpService:GenerateGUID(false)

    print(validater.Find(self.Player.Name))
    
    if validater.Find(self.Player.Name) == "CAN" then
        print("f(x)")
        validater.ActiveSessions[HTTP] = {

            [self.Player.Name] = self;
            [Hitter_CombatData.Player.Name] = Hitter_CombatData;
    
        }
    
        
        task.delay(0.1, function()
            validater.ActiveSessions[HTTP] = nil;
        end)
    end
end

return validater