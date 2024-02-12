--// Global declareables:

_G.DebugMode = false

--local Processor = require(script.Modules.Processor)

--// Services:
local LocalizationService: LocalizationService = game:GetService("LocalizationService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local playerS: Players = game:GetService("Players")
local repS: ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Assets:
local packages: Folder = repS.Packages

--// Imports:

local net = require(packages.BridgeNet2)
local dataMain = require(script.Data)
local combatMain = require(script.Combat)
local questsMain = require(script.Modules.Quest)
local roundMain = require(script.Rounds)
local inventory = require(script.Modules.Inventory);
local Trading = require(script.Modules.Trading);
local leaderstats = require(script.Leaderstats)

--// Declareables:
local mainCommunication: any = net.ReferenceBridge("Main")
local clientCommunication: any = net.ReferenceBridge("ClientCommunication")
local HUD: any = net.ReferenceBridge("HUD")
local AFKBRIDGE = net.ReferenceBridge("AFK")
local _AFKBRIDGE = net.ReferenceBridge("LockOn")

AFKBRIDGE:Connect(function(Player : Player, AFK : boolean)

	Player.Character:SetAttribute("AFK", AFK)

	print("Set!")
	
end)

			-------------------------------
			-- // Utility Connections \\ --
			-------------------------------

function Load(Player: Player)

	Player.Character:SetAttribute("AFK", false);
	Player.Character:SetAttribute("Trading", false);

	if dataMain.Profiles[Player.UserId] then

		local Usable_Data = dataMain:Get(Player).Data;
	
		if combatMain.__users[Player.UserId] then
			print("Combat data found, deleted.")
			combatMain.__users[Player.UserId] = nil
		end
		
		local Combat = combatMain.Construct(Player, Usable_Data)
		Combat:Load();

		return Usable_Data
	
	else

		local dataObject = dataMain.Construct(Player)
		dataObject:Load()

		local Usable_Data = dataObject:GetData();
		
		local Combat = combatMain.Construct(Player, Usable_Data)
		Combat:Load();

		HUD:Fire(net.Players({Player}), {

			Element = "Inventory";
			Action = "Load";
			Arguments = {

				Data = Usable_Data.Inventory;

			}

		})	
		
		HUD:Fire({

			Element = "Spinwheel";
			Action = "UpdateSpins";
			Arguments = {
	
				Spins = Usable_Data.Spins;
	
			}
	
		})

		return Usable_Data

	end
end

--[=[
	@Connection:
--	Description: Handle players joining.
--	@param:		Name: plr		Type: Player		Description: Player joined.
]=]

game.Players.PlayerAdded:Connect(function(plr: Player)

	--	[Below Connection]: Handle plr's character.

	plr.CharacterAdded:Connect(function(char: Model)

		HUD:Fire(net.Players({plr}), {

			Element = "HUD";
			Action = "Reload";
			Arguments = {}

		})

		char.Humanoid.WalkSpeed = 25
		char.Humanoid.JumpHeight = 8

		task.wait(2)

		local data_ = Load(plr)

		Trading.Load(plr)

		HUD:Fire(net.AllPlayers(), {

			Element = "Trading";
			Action = "AddPlayer";
			Arguments = {Player = plr}

		})

		if plr:FindFirstChild("leaderstats") then else

			local wins, kills = leaderstats.SetupLeaderboard(plr)

			wins.Value = data_.Wins;
			kills.Value = data_.Kills;

		end
	end)
end)

--[=[
	@Connection:
--	Description: Handle players leaving.
--	@param:		Name: plr		Type: Player		Description: Player leaving.
]=]
game.Players.PlayerRemoving:Connect(function(plr: Player)
	--[[local data = dataMain:Get(plr)
	data:Save()]]

	HUD:Fire(net.AllPlayers(), {

		Element = "Trading";
		Action = "DeletePlayer";
		Arguments = {Player = plr.Name}

	})
end)

--[=[
	@Connection:
--	Description: .
--	@param:		Name: requester		Type: string		Description: Player name.
--	@param:		Name: arguments		Type: table		Description: arguments.
]=]
mainCommunication:Connect(function(requester: Player, arguments: table)

	local dataObject: table = combatMain:Get(requester) -- Table.
	local request: string = arguments.Request -- String.

	if request == "M1" then -- If request is "M1".
		dataObject:ExecuteM1()

	elseif request == "Jump" then -- If request is "Jump".
	
		dataObject:ExecuteJump()

	elseif request == "Ability" then -- If request is "Ability".

		dataObject:ExecuteAbility()

	elseif request == "LockOn" then

		dataObject:LockOn();

	end
end)

local infoRequester = net.ReferenceBridge("InfoRequester")

infoRequester.OnServerInvoke = function(player: Player, content : any | nil)
	if roundMain.CurrentRound.RoundState == "Active" then
		if player == roundMain.CurrentRound.Berserker then
			
			print("player berserker")
			--combatMain.__users[player.UserId].LockedOn = true;
			return roundMain.CurrentRound.Champion.Name
		end

		if player == roundMain.CurrentRound.Champion then 
			print("Player is champion")
			--combatMain.__users[player.UserId].LockedOn = true;
			return roundMain.CurrentRound.Berserker.Name;
		end
	end
end

--local Resolver = require(script.Requests)
--local Requests = net.ReferenceBridge("Requests")

--[[
Requests:Connect(function(Player, Arguments)
	Resolver[Arguments.Request](Player, Arguments)
end)
]]