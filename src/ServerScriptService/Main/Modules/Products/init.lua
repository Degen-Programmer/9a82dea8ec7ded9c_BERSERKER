local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local DataMain = require(game.ServerScriptService.Main.Data);

local Handler = {}

-- // Processor callback:

MarketplaceService.ProcessReceipt = function(Receipt)

    local Customer = Players:GetPlayerByUserId(Receipt.PlayerId)
    local Product = Receipt.ProductId
    
    if Customer then
        print(Receipt)
    end
end

return Handler