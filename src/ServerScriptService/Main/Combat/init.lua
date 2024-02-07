--!nocheck 


-- // Class declarables: 

local Combat: table = {} 
Combat.__index = Combat 
Combat.__users = require(script.Users)  

-- // Services: 

local repS: ReplicatedStorage = game:GetService("ReplicatedStorage") 
local sSS: ServerScriptService = game:GetService("ServerScriptService") 
local playerS: Players = game:GetService("Players") 
local TweenService = game:GetService("TweenService") 

-- // Assets: 
 
local Assets: Folder = repS.Assets 
local Weapons: Folder = Assets.Weapons 
local Animations: Folder = Assets.Animations 
local Packages: Folder = repS.Packages 
local ServerAssets: Folder = game.ServerStorage.Assets; 
 
-- // Imports: 
 
local DataMain = require(script.Parent.Data) 
local RoundManager = require(script.Parent.Rounds) 
local Signal = require(Packages.GoodSignal) 
local Hitbox = require(script.Hitbox) 
local Abilities = require(script.Abilities) 
local Net = require(Packages.BridgeNet2) 
local Offsets = require(script.Offsets) 
local Replicator = require(script.Replication) 
local leaderstats = require(script.Parent.Leaderstats)

local clientCommunication = Net.ReferenceBridge("ClientCommunication")
 
--// Declareables: 
 
--[=[ 
 
@function:	Combat.Construct(). 
 
-- Description: Constructs the base class "combat". 
-- @param:      Name: player		type: Player		Description: the player around which the class will be constructed. 
-- @return:		Name: self			type: table			Description: the constructed class. 
 
]=] 
 
function Combat.Construct(player: Player, Data: table) 
	local queue: table = {} 
	local QMT: table = setmetatable(queue, {}) 
 
	local self: table = { 
		 
		Player = player, 
		Character = player.Character, 
		Debounce = false, 
		CurrentAbility = Data.Ability; 
		AbilityDebounce = false; 
		OnHit = Signal.new(), 
		_Hitbox = Hitbox.Initialize(player.Character), 
		Queue = QMT, 
		Data = Data, 
		Jumps = 0, 
		Cooldown = 1.5; 
		AbilitiesDisabled = false; 
		DeathHandler = nil; 
		debounceTaskHandler = nil; 
		Eliminations = 0;
		TimesHit = 0; 
		canAccept = true; 
		Knockback = 180;
		Power = 0;
		Boosts = 5;

		LockedOn = false;
		LockOnDebounce = false;

		lastBoost = os.clock();
		StaminaRefiller = nil;
 
		_OnHitHandler = nil; 
		_OnM1Handler = nil; 

		_OnHit = Signal.new();
		_OnM1 = Signal.new(); 
		_OnParry = Signal.new(); 
		_OnKilled = Signal.new();
 
	} 
 
	player.Character:SetAttribute("Active", false) 
 
	Combat.__users[player.UserId] = self 
	setmetatable(self, Combat) 
	
	return self 

end
 
--[=[ 
 
	@function:	Combat:Get(). 
 
--	Description: . 
--	@param:		Name: player	Type: Player	Description: Player for retrieving data. 
--	@return		Name: self.__users		Type: table		Description: Data. 
 
]=] 
 
function Combat:Get(player: Player) 
	if self.__users[player.UserId] then 
		return self.__users[player.UserId] 
	else 
		Combat.Construct(player, DataMain.Profiles[player.UserId].Data) 
		return self.__users[player.UserId] 
	end 
end 

-- // base stats:

--[[

walkSpeed : 25;
Knockback: 250;
Cooldown: 1.25;

-----------------------

final stats (after 45 parries)

walkSpeed : 60;
Knockback : 75;
Cooldown: 0.25;

]]

function Combat:IncreasePower()
	if self.Power ~= 100 then

		self.Power += 1;

		if self.Character.Humanoid.WalkSpeed < 40 then
			self.Character.Humanoid.WalkSpeed += 1
		end

		if self.Cooldown > 0.025 then
			self.Cooldown -= 0.025;
		end

		if self.Knockback > 10 then
			self.Knockback -= 10
		end

	end
end

function Combat:DecreasePower()
	
	self.Power -= 1;

	self.Character.Humanoid.WalkSpeed -= 1;
	self.Knockback += 5;
	self.Cooldown += 0.025;

end

function Combat:Load() 
 
	local data: table = self.Data 
	self.Ability = data.Ability 
 
	local Weapon: string = data.Weapon 
	local Offset : Offsets.Offset = Offsets.Get(Weapon) 
	local Unequipped: CFrame = Offset.Unequipped 
 
	local Target: SoundGroup = Offset.Target 
	local WeaponPath = Weapons:FindFirstChild(Weapon) 
 
	self.CurrentWeapon = WeaponPath:Clone() 
	self.CurrentWeapon.Parent = self.Character 
	self.CurrentWeapon.Name = "__WEAPON__"
	self.OffsetArray = Offset 
 
	local Root: any = self.Character:FindFirstChild(Target) 
 
	local MainWeld: Motor6D = Instance.new("Motor6D") 
	MainWeld.Parent = self.Character;
	MainWeld.Name = "WeaponWeld";
	MainWeld.Part0 = Root;
	MainWeld.Part1 = self.CurrentWeapon; 
 
	self.WeaponWeld = MainWeld 
	self.WeaponWeld.C0 = Unequipped 

	clientCommunication:Fire(Net.Players({self.Player}), {
	
		Request = "Inventory";
		Action = "LoadAbility";

		Arguments = {
			Ability = self.CurrentAbility;
		}
	})
 
end 

function Combat:LockOn()

	if self.Character.Humanoid.Health == 0 then return end

	if self.LockedOn == false then

		print("Locking on.")

		self.LockedOn = true;

		local Role, Opponent = RoundManager.CurrentRound:CheckPlayerOpponent(self.Player);

		self.Opponent = Opponent;

		local OPP_Player = game.Players:GetPlayerFromCharacter(self.Opponent)

		self.OpponentLeaveConnection = game.Players.PlayerRemoving:Connect(function(player)
			if player == OPP_Player then
				
				Replicator.ReplicateToPlayer(self.Player, "Combat", "LockOn", {
					Request = "LockOff";
				})

				print("opponent left.")

			end
		end)

		self.OpponentDied = Opponent.Humanoid.Died:Connect(function()

			print("THE FUCKER IS DEADDD")
			
			Replicator.ReplicateToPlayer(self.Player, "Combat", "LockOn", {
				Request = "LockOff";
			})

			print("Opponent died")
			
		end)

		Replicator.ReplicateToPlayer(self.Player, "Combat", "LockOn", {

			Opponent = Opponent;
			Request = "LockOn";

		})

	elseif self.LockedOn == true then

		if self.OpponentLeaveConnection then
			self.OpponentLeaveConnection:Disconnect()
		end

		self.Opponent = nil;
		
		if self.OpponentDied then
			self.OpponentDied:Disconnect();
		end

		self.LockedOn = false

		Replicator.ReplicateToPlayer(self.Player, "Combat", "LockOn", {
			Request = "LockOff";
		})

	end
end

-- // When the player gets hit.

function Combat:GotHit(Hitter_CombatData : {})
	if self._OnHitHandler then
		self._OnHitHandler(self)
	else
		self.Character:BreakJoints()
	end
end

-- // When the player sucessfuly connectes a hit.

function Combat:HitConnected(Target : string)

	print("HIT SUCCESFUL")

	Replicator.ReplicateToAll("Combat", "UseWeapon", { 
		
		Player = self.Player;
		PlayerCharacter = self.Character;
		PlayerWeld = self.WeaponWeld;
		PlayerArray = self.OffsetArray;
		PlayerWeapon = self.CurrentWeapon.Name;
		
	})


	self:ResetPower();
	self._Hitbox.OnDetected:DisconnectAll() 

	leaderstats.AddKill(self.Player)

	self.Eliminations += 1;

	Net.ReferenceBridge("HUD"):Fire(Net.Players({self.Player}), {

		Element = "Eliminations";
		Action = "GrantElimination";
		Arguments = {Index = self.Eliminations}

	})

	Net.ReferenceBridge("HUD"):Fire(Net.Players({self.Player}), {

		Element = "HUD";
		Action = "Elimination";
		Arguments = {Name = Target}

	})

end

-- // When the player parries:

function Combat:Parry()

	print("PARRYING : "..self.Player.Name)

	if self.Tween then
		self.Tween:Cancel();
	end

	Replicator.ReplicateToAll("Combat", "UseWeapon", { 
		
		Player = self.Player;
		PlayerCharacter = self.Character;
		PlayerWeld = self.WeaponWeld;
		PlayerArray = self.OffsetArray;
		PlayerWeapon = self.CurrentWeapon.Name;
		
	})

	Replicator.ReplicateToAll("Combat", "Knockback", { 
		
		Player = self.Player;
		Knockback = self.Knockback;

	})

	Net.ReferenceBridge("HUD"):Fire(Net.AllPlayers(), {

		Element = "HUD";
		Action = "Parry";
		Arguments = {};

	})

	self:IncreasePower();
	self._Hitbox.OnDetected:DisconnectAll() 

end

function Combat:HitDetection() 
 
	local thread : thread 
 
	if self.Player == RoundManager.CurrentRound.Berserker or self.Player == RoundManager.CurrentRound.Champion then 
		thread = task.spawn(function() 
 
			self._Hitbox:Detect(self.Cooldown, "__HITBOX__") 
 
			self._Hitbox.OnDetected:Connect(function(return_List) 
				for _, v in ipairs(return_List) do 
 
					if v.Name == "__HITBOX__" then 
 
						local Detection = v.Parent 
 
						local player = game.Players:GetPlayerFromCharacter(Detection) 
						local player_combat_data = self.__users[player.UserId] 

						self._OnHit:Fire(player_combat_data)
						self._OnHit:DisconnectAll();
						
						if player_combat_data.Player == RoundManager.CurrentRound.Berserker or 
						player_combat_data.Player == RoundManager.CurrentRound.Champion then 
 
 
							if Detection:GetAttribute("Active") == false then 
 
								local result = "Hit"; 

								player_combat_data:GotHit(self) 
								self:HitConnected(player_combat_data.Player.Name)

								return player_combat_data.Player, result

							else 
 
								local result = "Parried"; 

								self:Parry()
								player_combat_data:Parry()

								return player_combat_data.Player, result
 
							end 
						end 
 
						self._Hitbox.OnDetected:DisconnectAll() 
 
						break 
 
					end 
				end 
			end) 
 
			-- // clean up residue connection to prvent it from stacking up. 
 
			task.delay(self.Cooldown, function() 
				self._Hitbox.OnDetected:DisconnectAll() 
			end) 
 
		end) 
	end 
end 
 
function Combat:ChangeWeapon(Item: string) 
 
	self.CurrentWeapon:Destroy(); 
	self.WeaponWeld:Destroy(); 
	self.OffsetArray = nil; 
 
	self:Load() 
	
	print("Changed", self.CurrentWeapon.Name)
	 
end 

function Combat:ChangeAbility(Item: string)

	print("CHANGE ABILITY FUNCTION CALLED")

	if RoundManager.CurrentRound.RoundState ~= "Active" then 

		self.CurrentAbility = Item;
		self.Data.Ability = Item;

		Net.ReferenceBridge("HUD"):Fire(Net.Players({self.Player}), {

			Element = "Ability";
			Action = "AbilityChanged";
			Arguments = {

				_ability = Item;

			}
	
		})

	else
		print("cant change ability during round going on.")
	end
end

function Combat:ResetPower()
	self.Character.Humanoid.WalkSpeed = 25;
	self.Cooldown = 1.25;
	self.Knockback = 230; 

end

function Combat:Reset()

	-- // cleanup HUD:

	Net.ReferenceBridge("HUD"):Fire(Net.Players({self.Player}), {

		Element = "HUD";
		Action = "Cleanup";
		Arguments = {}

	})

end

local Replication = require(script.Replication)
 
function Combat:ExecuteM1() 
 
	self._M1 = function() 

		if self.Character.Humanoid.Health == 0 then return end

		Replicator.ReplicateToAll("Combat", "M1", { 
				
			Player = self.Player, 
			Power = self.Stamina;
		
		}) 

		self.Debounce = true; 
		self.Character:SetAttribute("Active", true) 
		
		--self:DecreaseStamina(20);

		-- // Play Slash VFX, SFX and Swing the weapon on the client. 
 
		if self.Player == RoundManager.CurrentRound.Berserker or self.Player == RoundManager.CurrentRound.Champion then

			local role, opponent = RoundManager.CurrentRound:CheckPlayerOpponent(self.Player)
			local Position = (opponent.HumanoidRootPart.Position - self.Character.HumanoidRootPart.Position).Magnitude;

			if Position > 25 then

				self.Boosts -= 1;
				print(self.Boosts)

				self.Character.Humanoid.Animator:LoadAnimation(Animations.Boost):Play();

				Net.ReferenceBridge("HUD"):Fire(Net.Players({self.Player}), {

					Element = "Stamina";
					Action = "DecreaseBoost";
					Arguments = {Boosts = self.Boosts}
		
				})

				if self.Boosts == 0 then
					self.Boosts = 5;
					print('boosts refilled', self.Boosts);

					Net.ReferenceBridge("HUD"):Fire(Net.Players({self.Player}), {

						Element = "Stamina";
						Action = "RefillStamina";
						Arguments = {}--{Boosts = self.Boosts}
			
					})
				end

				self.Character.Humanoid.WalkSpeed += 105;

				task.delay(0.2, function()
					self.Character.Humanoid.WalkSpeed -= 105;
				end)

			end
		end

		Net.ReferenceBridge("HUD"):Fire(Net.Players({self.Player}), {

			Element = "M1";
			Action = "Cooldown";
			Arguments = {Duration = self.Cooldown}

		})

		-- // Hit Detection: 
 
		local Hit, Result = self:HitDetection() 
 
		-- // waiting: 
 
		self.cooldownHandler = task.spawn(function() 

			task.wait(self.Cooldown) 
			print(self.Debounce, self.Player.Name) 
 
			self.Debounce = false 
			self.Character:SetAttribute("Active", false) 

			print("COOLDOWN RESET.")

		end)

		return Hit, Result;

	end 
 
	if self.Debounce == false and RoundManager.CurrentRound.RoundState == "Active" then 
		task.spawn(function() 
			if self._OnM1Handler then 
				print("handler called") 
				self._OnM1Handler() 
			else 
				self._M1(); 
			end 
		end)
	end	
end
 
function Combat:ExecuteAbility() 

	if self.Character.Humanoid.Health == 0 then return end

	if RoundManager.CurrentRound.RoundState == "Active" then 
		Abilities.Execute({ 
			_self = self 
		}) -- kwargs 
	else 
		print("Round be kinda inactive ngl.") 
	end
end

return Combat