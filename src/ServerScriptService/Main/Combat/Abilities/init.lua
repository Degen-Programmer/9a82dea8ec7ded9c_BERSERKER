local module = {}
local QSignals = require(game.ServerScriptService.Main.Modules.Quest.Signals);
local Net = require(game.ReplicatedStorage.Packages.BridgeNet2)

function module.Execute(kwargs)

    local self = kwargs._self;
    local Ability = self.CurrentAbility;
    local mod = require(script:FindFirstChild(Ability))
    
    mod.Execute(kwargs)

    --[[if self.AbilityDebounce == false and self.AbilitiesDisabled == false then

        self.AbilityDebounce = true;
        
        mod.Execute(kwargs)

        Net.ReferenceBridge("HUD"):Fire(Net.Players({self.Player}), {

            Element = "Ability";
            Action = "Cooldown";
            Arguments = {Duration = mod.Configurations.Cooldown}
    
        })

        QSignals.AbilityUseAchieved:Fire(self.Player, {Signal = "AbilityUseAchieved"});
        
    end]]
end

return module 