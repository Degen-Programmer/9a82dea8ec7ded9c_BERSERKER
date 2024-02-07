local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Signals = require(script.Signals)
local DataMain = require(game.ServerScriptService.Main.Data);

local Handler = {}

-- // Processor callback:

MarketplaceService.ProcessReceipt = function(Receipt)

    local Customer = Players:GetPlayerByUserId(Receipt.PlayerId)
    local Product = Receipt.ProductId
    
    if Customer then
        if Handler[Product] then
            Handler[Product](Customer)
        end
    end
end

Handler.Spins = {

    ["1721874331"] = {Spins = 5; Name = "5Spins"};
    ["1721875653"] = {Spins = 10; Name = "10Spins"};
    ["1721876061"] = {Spins = 15; Name = "15Spins"};
    ["1721877948"] = {Spins = 20; Name = "20Spins"};
    ["1721878682"] = {Spins = 25; Name = "25Spins"};
    ["1721880043"] = {Spins = 35; Name = "35Spins"};
    ["1721881340"] = {Spins = 45; Name = "45Spins"};


}

------------------------------------------- PREMIUM GACHA -------------------------------------------

Handler[1698776430] = function(Player)
    
    local handler;

    handler = task.spawn(function()

        Signals.PremiumGacha:Fire(Player, handler)
        Signals.PremiumGacha:DisconnectAll()

        return true
        
    end)
end

------------------------------------------- PREMIUM GACHA -------------------------------------------
-----------------------------------------------------------------------------------------------------


--(fix this terrible mess later...)
-----------------------------------------  SPINWHEEL SPINS -----------------------------------------

Handler[1721881340] = function(Player)
    
    local handler;

    handler = task.spawn(function()

        local Data = DataMain:Get(Player).Data;
        print(Data.Spins)
        Data.Spins = Data.Spins + Handler.Spins[tostring(1721881340)].Spins;

        print("Processed Receipt.", Data.Spins)

        return true
        
    end)
end


Handler[1721880043] = function(Player)
    
    local handler;

    handler = task.spawn(function()

        local Data = DataMain:Get(Player).Data;
        print(Data.Spins)
        Data.Spins = Data.Spins + Handler.Spins[tostring(1721880043)].Spins;

        print("Processed Receipt.", Data.Spins)

        return true
        
    end)
end

Handler[1721878682] = function(Player)
    
    local handler;

    handler = task.spawn(function()

        local Data = DataMain:Get(Player).Data;
        print(Data.Spins)
        Data.Spins = Data.Spins + Handler.Spins[tostring(1721878682)].Spins;

        print("Processed Receipt.", Data.Spins)

        return true
        
    end)
end

Handler[1721877948] = function(Player)
    
    local handler;

    handler = task.spawn(function()

        local Data = DataMain:Get(Player).Data;
        print(Data.Spins)
        Data.Spins = Data.Spins + Handler.Spins[tostring(1721877948)].Spins;

        print("Processed Receipt.", Data.Spins)

        return true
        
    end)
end

Handler[1721874331] = function(Player)
    
    local handler;

    handler = task.spawn(function()

        local Data = DataMain:Get(Player).Data;
        print(Data.Spins)
        Data.Spins = Data.Spins + Handler.Spins[tostring(1721874331)].Spins;

        print("Processed Receipt.", Data.Spins)

        return true
        
    end)
end

Handler[1721875653] = function(Player)
    
    local handler;

    handler = task.spawn(function()

        local Data = DataMain:Get(Player).Data;
        print(Data.Spins)
        Data.Spins = Data.Spins + Handler.Spins[tostring(1721875653)].Spins;

        print("Processed Receipt.", Data.Spins)

        return true
        
    end)
end

Handler[1721876061] = function(Player)
    
    local handler;

    handler = task.spawn(function()

        local Data = DataMain:Get(Player).Data;
        print(Data.Spins)
        Data.Spins = Data.Spins + Handler.Spins[tostring(1721876061)].Spins;

        print("Processed Receipt.", Data.Spins)

        return true
        
    end)
end

------------------------------------------- SPINWHEEL SPINS -----------------------------------------
-----------------------------------------------------------------------------------------------------

return Handler