local Offsets = {}

export type Offset = {
	
	Target: string;
	Unequipped: CFrame;
	Equipped: CFrame
	
}

function Offsets.Get(name)
	return Offsets[name] :: Offset
end

Offsets["BattleAx"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["ViridianSword"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["ViridianDagger"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["SwordOfHonor"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["Sundial"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["Stonesword"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["RustedCleaver"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["RunicXiphos"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["RedsteelDagger"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["PinkyPower"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["IronBroadsword"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["HookedDagger"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["GoldenCleaver"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["GoblinsMachette"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["Endsword"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["DraconicRapier"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["DivineClaymore"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["Darksword"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["Cleaver"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["Badsword"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["FlankedGreatsword"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets.Hammer = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.076, -1.199, -0.122) * CFrame.Angles(0, math.rad(-90), math.rad(180));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}


Offsets["WoodenSword"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.217, -0.962, -1.583) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["StoneKnife"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(-180), 0);
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["BoStaff"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.817, -1.931, 0.566) * CFrame.Angles(0, 0, math.rad(-45));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets.Bat = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.162, -0.974, -0.921) * CFrame.Angles(math.rad(75), math.rad(180), math.rad(180));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["WoodenGreatsword"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.942, -1.825, 0.694) * CFrame.Angles(0, 0, math.rad(-45));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}


Offsets["MagesStaff"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-0.68, -1.333, 0.585) * CFrame.Angles(0, 0, math.rad(-35));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets.Katana = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.044, -0.887, -1.312) * CFrame.Angles(0, math.rad(-90), math.rad(-110.928));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["GreatHammer"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-0.711, -1.358, 0.792) * CFrame.Angles(0, 0, math.rad(-40));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets.Shield = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-0.008, 0.18, 0.737);
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets.Lifebreaker = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.151, -0.674, -1.172) * CFrame.Angles(math.rad(-70), 0, math.rad(180));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["AncientDagger"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.126, -1.15, -0.219) * CFrame.Angles(0, math.rad(90), math.rad(112.461));
	Equipped = CFrame.new(0, -1.149, -0.154) * CFrame.Angles(0, math.rad(-84.675), math.rad(87.561));
	
}

Offsets["WatchersDagger"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.129, -1.186, -0.149) * CFrame.Angles(0, math.rad(-90), math.rad(-105));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets["JotunnGreatsword"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-2.861, -2.362, 0.563) * CFrame.Angles(0, 0, math.rad(-50));
	Equipped = CFrame.new(0.006, -1.019, -0.216) * CFrame.Angles(math.rad(-90), 0, 0)
	
}

Offsets.Doomcaller = {
	
	Target = "Torso";
	Unequipped = CFrame.new(1.481, -1.884, 0.64) * CFrame.Angles(0, 0, math.rad(40));
	Equipped = CFrame.new(0.032, -1.14, 0.08) * CFrame.Angles(0, math.rad(90), math.rad(-90))
	
}

Offsets["DryadsThorn"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.062, -0.85, -1.271) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0, -1.054, 0.63) * CFrame.Angles(0, math.rad(-90), math.rad(90))
	
}


Offsets.Lifeweaver = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.247, -0.921, -1.071) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0, -1.051, -0.024) * CFrame.Angles(0, math.rad(-90), math.rad(90))
	
}


Offsets["RitualSword"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-1.104, -1.126, 0.012) * CFrame.Angles(0, math.rad(90), math.rad(105));
	Equipped = CFrame.new(0, -1.126, 0.012) * CFrame.Angles(0, math.rad(90), math.rad(-90))
	
}


Offsets.Greatsword = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-2.537, -2.421, 0.691) * CFrame.Angles(0, 0, math.rad(-45));
	Equipped = CFrame.new(0, -1.04, 0.42) * CFrame.Angles(0, math.rad(-90), math.rad(90))
	
}

Offsets["LotusStaff"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(-0.898, -1.216, 0.581) * CFrame.Angles(0, 0, math.rad(-35));
	Equipped = CFrame.new(0, -1.021, -0.023) * CFrame.Angles(math.rad(-55), math.rad(90), math.rad(-90))
	
}

Offsets["TechnoKatana"] = {
	
	Target = "Torso";
	Unequipped = CFrame.new(2.164, 2.072, 0.575) * CFrame.Angles(0, math.rad(180), math.rad(-135));
	Equipped = CFrame.new(-0.016, -1.099, 0.209) * CFrame.Angles(0, math.rad(90), math.rad(-85))
	
}


return Offsets