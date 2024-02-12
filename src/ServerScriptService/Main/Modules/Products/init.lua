local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local DataMain = require(game.ServerScriptService.Main.Data);
local Signals = require(game.ReplicatedStorage.Packages.GoodSignal)

local OnPurchaseSuccess = Signals.new()
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
        OnPurchaseSuccess:Connect(function(Product_ID, player_ID)
            
            if player_ID ~= player.UserId then return end
            if not player then return end

            Module.FulfillPromise(player, PRODUCT_PURCHASE_ID)
            
        end)
    else
        warn("Bruh!")
    end
end

MarketplaceService.ProcessReceipt = function(Receipt)

    local Customer = Players:GetPlayerByUserId(Receipt.PlayerId)
    local Product = Receipt.ProductId
    
    -- // Player did not leave game:

    if Customer then
        OnPurchaseSuccess:Fire(Receipt.ProductId, Receipt.PlayerId)
    end
end

return Handler