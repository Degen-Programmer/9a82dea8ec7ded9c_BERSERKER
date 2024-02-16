
--!nocheck

type Element = {
	
	-- // Constructor and methods:
	
	New : (BasePart : BasePart) -> {Element};
	Deploy : () -> BasePart;
	Cooldown : (Duration : number) -> nil;
	
	Name : string;
	Element : BasePart | Part | Model;
	RunnerThread : thread;
	PositionalOffset : CFrame;	

}

local Inventory : Element = {}
Inventory.__index = Inventory;
Inventory._BASEPART = game.ReplicatedStorage.UI.Inventory;

local Playergui = game.Players.LocalPlayer.PlayerGui
local INVENTORY_FRAME = Playergui:WaitForChild("Inventory");

local Camera : Camera? = workspace.CurrentCamera;
local Tweenservice = game:GetService("TweenService");

local UIS = game:GetService("UserInputService")
local Rep = game:GetService("ReplicatedStorage")

local Net = require(Rep.Packages.BridgeNet2)
local Bridge = Net.ReferenceBridge("ServerCommunication");

function Inventory.New() : Element
	
	local self = {}
	
	self._name = "Inventory";
	self._element = Inventory._BASEPART
	self._runnerThread = nil;
	self._offset = self._element._OFFSET.Value;
	self._GUI = INVENTORY_FRAME;
	self._CurrentlyOpen = nil;
	self._CurrentlySelected = nil;

	return setmetatable(self, Inventory)
	
end

function Inventory:_init_runner_thread()

	local bounds = Vector2.new(-0.5, 0.5)
	local initialoffset = self._offset;

	self._runnerThread = task.spawn(function()
		game:GetService("RunService").RenderStepped:Connect(function()

			local screenSize = Camera.ViewportSize;
			local mousePos = (UIS:GetMouseLocation() - screenSize / 2) * (2 / screenSize)

			local yaw = CFrame.fromEulerAnglesXYZ(

				math.rad(mousePos.Y * bounds.Y),
				math.rad(mousePos.X * bounds.X),
				0

			)
			
			self._element.CFrame = Camera.CFrame * self._offset * yaw;
			
		end)
	end)
end

function Inventory:_cancel_runner_thread()
	task.cancel(self._runnerThread)
end

function Inventory:SetAdornee()
	Playergui.Inventory.Adornee = self._element;
end

function Inventory:CreatBlur()
	
	local blurInstance = Instance.new("BlurEffect", Camera)
	blurInstance.Size = 5;

	self._blur = blurInstance

end

function Inventory:Open()
	
	print("Opening.....")
	
	self:_init_runner_thread()
	Tweenservice:Create(self._element, TweenInfo.new(.1), {Size = Vector3.new(2.276, 0.914, 0.001)}):Play()
	Tweenservice:Create(Camera, TweenInfo.new(.1), {FieldOfView = 75}):Play()
	self:CreatBlur()

end

function Inventory:Close()

	self:_cancel_runner_thread()
	Tweenservice:Create(self._element, TweenInfo.new(.1), {Size = Vector3.new(0, 0, 0)}):Play()
	Tweenservice:Create(Camera, TweenInfo.new(.1), {FieldOfView = 70}):Play()
	if self._blur then self._blur:Destroy() end

end

function Inventory:Deploy()
	
	local element : Part = self._element;
	local newElement = element:Clone()
	newElement.Parent = workspace;

	-- // Attach our UI and create entries in the object for the individual components.

	INVENTORY_FRAME.Adornee = newElement;

	local Containers : Folder = INVENTORY_FRAME:FindFirstChild("Containers")
	local Tabs : Folder = INVENTORY_FRAME:FindFirstChild("Tabs")
	local Sidebar : Folder = INVENTORY_FRAME:FindFirstChild("Sidebar")
	local EquipButton : ImageButton = INVENTORY_FRAME.SelectedItem.Equip;

	EquipButton.MouseEnter:Connect(function(x, y)
		Tweenservice:Create(EquipButton, TweenInfo.new(.15), {Size = UDim2.new(0.6, 0, 0.11, 0)}):Play()
	end)

	EquipButton.MouseLeave:Connect(function(x, y)
		Tweenservice:Create(EquipButton, TweenInfo.new(.15), {Size = UDim2.new(0.55, 0, 0.1, 0)}):Play()
	end)

	EquipButton.Activated:Connect(function(inputObject, clickCount)
		self:EquipItem();
	end)

	self.Tabs, self.Containers = Tabs, Containers;
	self._element = newElement;
	self.Sidebar = Sidebar

	-- // Initialize Opening And Closing Of Tabs:

	for _, Activator : ImageButton in ipairs(self.Sidebar:GetChildren()) do
		Activator.Activated:Connect(function(inputObject, clickCount)
			
			local item : ScrollingFrame = self.Containers:FindFirstChild(Activator.Name)
			
			for _, v in ipairs(self.Containers:GetChildren()) do
				v.Visible = false;
			end

			item.Visible = true
			self._CurrentlyOpen = item.Name;

			print("Opened: "..item.Name)

		end)

		local TabPosition = Activator.Position

		Activator.MouseEnter:Connect(function(x, y)
			Tweenservice:Create(Activator, TweenInfo.new(.15), {Position = Activator.Position - UDim2.new(0.01, 0, 0, 0)}):Play()
		end)

		Activator.MouseLeave:Connect(function(x, y)
			Tweenservice:Create(Activator, TweenInfo.new(.15), {Position = TabPosition}):Play()
		end)
	end

	INVENTORY_FRAME.Close.Activated:Connect(function()
		self:Close()
	end)
end

local Configs = require(script.Parent.Parent.Configs)

function Inventory:Load(kwargs : {})

	local Data = kwargs.Data;

	for DATA_CONTAINER_NAME : string, ARRAY : {} in pairs(Data) do

		local ContainerBaseObject : ScrollingFrame = self.Containers:FindFirstChild(DATA_CONTAINER_NAME);
		local ConfigsContainer : {} = Configs[DATA_CONTAINER_NAME]
		local Spare : ImageButton = ContainerBaseObject:FindFirstChild("Spare");

		for ItemName : string, ItemCount : number in pairs(ARRAY) do

			print(ItemCount, ItemName)
			
			local ItemConfig = ConfigsContainer[ItemName];
			local NewInstance : ImageButton = Spare:Clone();

			NewInstance.Parent = ContainerBaseObject;
			NewInstance.Visible = true;
			NewInstance:FindFirstChild("Icon").Image = ItemConfig.Icon;
			NewInstance:FindFirstChild("itemName").Text = ItemConfig.DisplayName;
			
			NewInstance.Image = Configs.IconFrameAsset_ID[ItemConfig.Rarity]
			NewInstance.ColorManager.Color = Configs.FrameColor3[ItemConfig.Rarity]
			NewInstance:FindFirstChild("ItemCount").Text = "x"..tostring(ItemCount)
			NewInstance.Name = ItemName;

		end
	end

	for _, BaseContainer : ScrollingFrame in ipairs(INVENTORY_FRAME.Containers:GetChildren()) do
		for _, Item : ImageButton in ipairs(BaseContainer:GetChildren()) do
			if Item:IsA("ImageButton") then
				
				Item.MouseEnter:Connect(function(x, y)
					
				end)

				Item.MouseLeave:Connect(function(x, y)
					
				end)

				Item.Activated:Connect(function(inputObject, clickCount)
					self:UpdateSelectedItem(Item.Name, BaseContainer.Name)
				end)

			end
		end
	end
end

function Inventory:AddItem(Arguments)

	local Container = Arguments.Container;
	local Item = Arguments.Item;
	local Count = Arguments.Count;

	if self.Containers:FindFirstChild(Arguments.Container):FindFirstChild(Item) then
		self.Containers:FindFirstChild(Arguments.Container):FindFirstChild(Item).ItemCount.Text = "x"..tostring(Count)
	else

		print("Item does not exist in the players inventory, creating new entry.")

		local ContainerBaseObject : ScrollingFrame = self.Containers:FindFirstChild(Container);
		local ConfigsContainer : {} = Configs[Container]
		local Spare : ImageButton = ContainerBaseObject:FindFirstChild("Spare");

		local ItemConfig = ConfigsContainer[Item];
		local NewInstance : ImageButton = Spare:Clone();

		NewInstance.Parent = ContainerBaseObject;
		NewInstance.Visible = true;
		NewInstance:FindFirstChild("Icon").Image = ItemConfig.Icon;
		NewInstance:FindFirstChild("itemName").Text = ItemConfig.DisplayName;
		
		NewInstance.Image = Configs.IconFrameAsset_ID[ItemConfig.Rarity]
		NewInstance.ColorManager.Color = Configs.FrameColor3[ItemConfig.Rarity]
		NewInstance:FindFirstChild("ItemCount").Text = "x"..tostring(Count)
		NewInstance.Name = Item;

		NewInstance.Activated:Connect(function(inputObject, clickCount)
			self:UpdateSelectedItem(Item.Name, ContainerBaseObject.Name)
		end)

	end
end

function Inventory:RemoveItem(Arguments)

	local Container = Arguments.Container;
	local Item = Arguments.Item;
	local Count = Arguments.Count;

	self.Containers:FindFirstChild(Arguments.Container):FindFirstChild(Item).ItemCount.Text = tostring(Count)

end

function Inventory:DeleteItem(Arguments)

	local Item = Arguments.Item;

	self.Containers:FindFirstChild(Arguments.Container):FindFirstChild(Item):Destroy()

end

function Inventory:UpdateSelectedItem(Item : string, Container : string)
	
	local ItemDescription : ImageLabel = INVENTORY_FRAME.SelectedItem;
	local EquipButton : ImageButton = ItemDescription.Equip;

	local ItemIcon : ImageLabel = ItemDescription.Icon;
	local ItemFrame : ImageLabel = ItemDescription.Frame
	local ItemName : TextLabel = ItemDescription.itemName
	local Description : TextLabel = ItemDescription.Description;

	local ItemConfig = Configs[Container][Item]
	ItemName.Text = ItemConfig.DisplayName;
	ItemIcon.Image = ItemConfig.Icon;
	Description.Text = ItemConfig.Description

	self._CurrentlySelected = Item;
	self._CurrentlyOpen = Container

end

function Inventory:EquipItem()
	
	if self._CurrentlyOpen == nil and self._CurrentlySelected == nil then return end

	Bridge:Fire({

		Request = "Inventory";
		Action = "Equip";

		Arguments = {

			Item = self._CurrentlySelected;
			Container = self._CurrentlyOpen;

		}
	})

end

function Inventory:Parse(Action, Arguments)
	if Action == "Load" then
		self:Load(Arguments)
	end

	if Action == "RemoveItem" then
		self:RemoveItem(Arguments)
	end

	if Action == "AddItem" then
		self:AddItem(Arguments)
	end

	if Action == "DeleteItem" then
		self:DeleteItem(Arguments)
	end
end


return Inventory;