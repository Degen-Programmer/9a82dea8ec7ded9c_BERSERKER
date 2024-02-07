local Hitbox = {}
Hitbox.__index = Hitbox

local ProximityPromptService = game:GetService("ProximityPromptService")
local Rep = game:GetService("ReplicatedStorage")

local Signal = require(Rep.Packages.GoodSignal)
local RunService = game:GetService("RunService")

function Hitbox.make_hitbox(Size)

	local hitbox = Instance.new("Part")
	hitbox.Size = Size;
	hitbox.Anchored = true;
	hitbox.CanCollide = false;
	hitbox.Transparency = 1 -- set to 1 later.
	hitbox.Massless = true;
	hitbox.Parent = workspace;

	return hitbox
	
end

function Hitbox.Construct(basePart)
	
	local Params = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = {basePart.Parent; workspace.Map} -- Map and Character.
	
	local HitboxConfigs = {}
	
	HitboxConfigs.DetectionObject = basePart
	HitboxConfigs.Connection = nil;
	HitboxConfigs.ReturnList = nil;
	HitboxConfigs.IgnoreList = {}
	HitboxConfigs.OnDetected = Signal.new()
	HitboxConfigs.Params = Params
	
	setmetatable(HitboxConfigs, Hitbox)
	return HitboxConfigs
	
end

function Hitbox:Detect(Time: number, Detection: string)
	
	self.Connection = RunService.Stepped:Connect(function()

		--print("DETECTING...")
		
		self.ReturnList = workspace:GetPartsInPart(self.DetectionObject, self.Params)

		if #self.ReturnList >= 1 then
			
			self:Filter_And_Post(Detection, self.ReturnList)
			
		end
	end)
	
	task.delay(Time, function()
		if self.Connection ~= nil then

			self.Connection:Disconnect()
		else
			return
		end
	end)
end

function Hitbox:Destroy()
	self.DetectionObject:Destroy()
	print("self.DetectionObject destroyed..")
end

function Hitbox:Filter_And_Post(filter)

	for _, v: Part | BasePart in ipairs(self.ReturnList) do
		if v.Name == filter then
			
			if self.Connection then
				self.Connection:Disconnect()
			end
			
			self.Connection = nil

			self.OnDetected:Fire(self.ReturnList, self.ReturnList[1])
			self.ReturnList = {}
			
			break
			
		end
	end
end

function Hitbox.Initialize(character: Model): {}

	if not character then return end

	local humanoidRootPart = character.HumanoidRootPart;

	-- // game world object hitbox configrations:
	
	local hitboxFolder = Instance.new("Folder") ; hitboxFolder.Parent = character;
	hitboxFolder.Name = "_hitboxes"; 

	local detector = Instance.new("Part"); detector.Parent = character;
	detector.Name = "__HITBOX__"; detector.Size = Vector3.new(6, 8, 6); detector.Anchored = false;
	detector.CanCollide = false; detector.Massless = true ; detector.Transparency = 1

	-- // attach hitbox:

	local attacher = Instance.new("Weld")
	attacher.Parent = character; attacher.Part0 = humanoidRootPart; attacher.Part1 = detector
	attacher.C0 = CFrame.new(0, 0, -3)
	-- // construct and configure main hitbox class

	local main = Hitbox.Construct(detector)

	main.IgnoreList = {character, workspace.Map}
	main.OverlapParams = "Default"
	main.Visualizer = true;
	main.MainTarget = "HumanoidRootPart"
	main.Detector = detector;
	
	return main

end

return Hitbox