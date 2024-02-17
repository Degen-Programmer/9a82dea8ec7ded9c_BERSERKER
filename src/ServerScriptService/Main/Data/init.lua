--!nocheck 
--// Class declareables: 
local DataManager = {} 
DataManager.__index = DataManager 
 
DataManager.Objects = {} 
DataManager.Profiles = {} 
 
--// Services: 
local Players = game:GetService("Players") 
local Rep = game:GetService("ReplicatedStorage") 
local Packages = Rep.Packages 
 
--// Imports: 
local Signal = require(Packages.GoodSignal) 
local ProfileService = require(script.ProfileService) 
 
--local ItemConfigs = require(game.ServerScriptService.Main.Requests.Configs) 
 
function DataManager.Construct(player: Player) 
	 
	local DataObject = {} 
	local ProfileStore = ProfileService.GetProfileStore( 
		"<1>x!!.!x!!<!!!!g!x1!!!>..", 
		require(script.Tree) 
	) 
	 
	DataObject.Player = player 
	DataObject.RawProfile = ProfileStore 
	DataObject.LoadedProfile = nil; 
	DataObject.OnLoaded = Signal.new() 
	DataObject.Loaded = false; 
 
	DataManager.Objects[player.UserId] = DataObject 
	 
	setmetatable(DataObject, DataManager) 
	 
	return DataObject 
	 
end 
 
function DataManager:Load() 
	local success, fail = xpcall(function() 
		 
		self.LoadedProfile = self.RawProfile:LoadProfileAsync( 
			"Player/"..self.Player.UserId, 
			"ForceLoad" 
		) 
 
	end, function() 
		 warn("smthn went wrong in data loading. rejoin pls.")
	end) 
	 
	if self.LoadedProfile then 
		if self.Player then 
			 
			self.Profiles[self.Player.UserId] = self.LoadedProfile 
			self.OnLoaded:Fire() 
 
			local Data = self.LoadedProfile.Data; 
 
		else 
			self.LoadedProfile:Release() 
		end 
	else 
		--self.Player:Kick() 
	end 
	 
	if success then 
		self.Loaded = true; 
	end 
end 
 
function DataManager:GetData() 
	return self.LoadedProfile.Data 
end 
 
function DataManager:GetKey(key: string) : any 
	return self:GetData()[key] 
end 
 
function DataManager:SetData(key : string, value: string) : string | { } | any 
	local key = self:GetKey(key) 
	key = value 
	return key, value 
end 
 
function DataManager:Get(player: Player) 
	if self.Profiles[player.UserId] then
		return self.Profiles[player.UserId] 
	else
		return nil
	end
end 
 
function DataManager:GetProfile(userID) 
	if self.Profiles[userID] then
		return self.Profiles[userID] 
	else
		return nil
	end
end 
 
return DataManager