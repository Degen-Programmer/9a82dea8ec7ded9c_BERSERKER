local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local DataMain = require(game.ServerScriptService.Main.Data);

local Handler = {}

-- // Processor callback:

function Handler.ProcessPurchase(player : Player, Kwargs : {})
   
    local Module = require(script:FindFirstChild(Kwargs.Product_Class))
    local Products = Module.Products;

    local PRODUCT_PURCHASE_ID = nil;

    for k, v in pairs(Products) do
        if Kwargs.Product_Name == v.Name then 
            PRODUCT_PURCHASE_ID = tostring(k)
        end
    end

    local Success, Error = pcall(function()
        MarketplaceService:PromptProductPurchase(player, PRODUCT_PURCHASE_ID)
    end)

    if Success then
        return
    else
        warn("Bruh!")
    end
end

MarketplaceService.ProcessReceipt = function(Receipt)

    local Customer = Players:GetPlayerByUserId(Receipt.PlayerId)
    local Product = Receipt.ProductId
    
    if Customer then
        print(Receipt)
    end
end

return Handler