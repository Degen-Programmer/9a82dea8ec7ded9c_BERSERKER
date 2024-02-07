-- # Script that handles the opening and closing of stuff, effects and alldat. 
-- ## Logic of all other systems such as fusing, trading, etc.. is handled in their own scripts.

local Handler = {}
Handler.CurrentlyOpen = nil;

local Player = game.Players.LocalPlayer;
local PlayerGui = Player:WaitForChild("PlayerGui");

-- // Assets:

local Root = PlayerGui:WaitForChild("Root");
local Buttons = Root.Buttons;
--local HUD = Root.HUD;
local Frames = Root.Frames;

-- // Effects:

local TweenService = game:GetService("TweenService");
local Camera = require(script.Parent.Parent.Utilities.Camera);
local net = require(game.ReplicatedStorage.Packages.BridgeNet2)
local AFKBRIDGE = net.ReferenceBridge("AFK")

--[[

    function that handles the opening and closing of Containers and other stuff.
    @function Handler.Initialize

]]

local isAFK = false;


local ActiveFrames = {

    Frames.Items;
    Frames.Quests;
    Frames.Shop;
    Frames.Spinwheel;

}

function Handler.Initialize()

    --print("Client/Handler: LOADED Handler.lua")

    --[[HUD.AFK.MouseLeave:Connect(function()
        TweenService:Create(HUD.AFK, TweenInfo.new(0.2, Enum.EasingStyle.Circular), {Size = UDim2.new(0.319, 0, 0.347, 0)}):Play();
    end)

    HUD.AFK.MouseEnter:Connect(function()
        TweenService:Create(HUD.AFK, TweenInfo.new(0.2, Enum.EasingStyle.Circular), {Size = UDim2.new(0.343, 0, 0.388, 0)}):Play();
    end)

    HUD.AFK.Activated:Connect(function()
        if isAFK == false then

            isAFK = true;
            AFKBRIDGE:Fire(true);

            HUD.AFK.Label.Text = "AFK : ON"
            HUD.AFK.Label.TextColor3 = Color3.new(0, 1, 0);

        else

            isAFK = false;
            AFKBRIDGE:Fire(true);

            HUD.AFK.Label.Text = "AFK : OFF"
            HUD.AFK.Label.TextColor3 = Color3.new(1, 0, 0);

        end
    end)]]

    if workspace.CurrentCamera:FindFirstChild("Blur") then 
        workspace.CurrentCamera.Blur:Destroy();
    end

    local Character : Model = Player.Character;
    local Click, Hover = Character:WaitForChild("Click"), Character:WaitForChild("Hover");
    
    -- // Opening Stuff:

    task.spawn(function()
        for _, Button : ImageButton in ipairs(Buttons:GetChildren()) do
            if Button and Button:IsA("ImageButton") then

                -- // Mouse Enter & Mouse Leave:
                
                Button.MouseEnter:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Circular), {Size = UDim2.new(1, 0, 0.35, 0)}):Play();
                    Hover:Play();
                end)

                Button.MouseLeave:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Circular), {Size = UDim2.new(0.9, 0, 0.197, 0)}):Play();
                end)

                -- // Activated, Check if anything else is open or not:

                Button.Activated:Connect(function()
                    if Handler.CurrentlyOpen == nil then

                        -- # Effects:
                        
                        Click:Play();
                        TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Size = UDim2.new(1.25, 0, 0.55, 0)}):Play();    

                        -- # Silencing Other Buttons:

                        for _, otherButtons : ImageButton in ipairs(Buttons:GetChildren()) do
                            if otherButtons and otherButtons:IsA("ImageButton") and otherButtons.Name ~= Button.Name then
                                otherButtons.Active = false;
                                TweenService:Create(otherButtons, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {ImageTransparency = 0.5}):Play();
                            end
                        end

                        -- # Opening Frame:

                        local _Frame = Frames:FindFirstChild(Button.Name);
                        local blur = Camera.Blur();
                        local AbsoluteSize = _Frame.Size;

                        -- # Effects:

                        _Frame.Size = UDim2.new(0, 0, 0, 0);
                        TweenService:Create(_Frame, TweenInfo.new(0.1, Enum.EasingStyle.Circular), {Size = AbsoluteSize}):Play();
                        Camera.ChangeFOV(workspace.CurrentCamera, {FieldOfView = 75, Time = 0.1});
                        
                        Handler.CurrentlyOpen = Button.Name;
                        _Frame.Visible = true;

                    end
                end)
            end
        end
    end)

    -- // Closing Stuff:

    task.spawn(function()
        for _, Frame : Frame in ipairs(ActiveFrames) do
            if Frame:IsA("ImageLabel") or Frame:IsA("Frame") then
                if Frame:FindFirstChild("Close") then
                    Frame.Close.Activated:Connect(function()

                        for _, otherButtons : ImageButton in ipairs(Buttons:GetChildren()) do
                            if otherButtons:IsA("ImageButton") then
                                otherButtons.Active = true;
                                TweenService:Create(otherButtons, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {ImageTransparency = 0}):Play();
                            end
                        end
    
                        local AbsoluteSize = Frame.Size;
                        local tw = TweenService:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Circular), {Size = UDim2.new(0, 0, 0, 0)})
                        
                        tw:Play()
                        
                        if workspace.CurrentCamera:FindFirstChild("Blur") then
                            workspace.CurrentCamera.Blur:Destroy();
                        end
    
                        tw.Completed:Connect(function()
                            Handler.CurrentlyOpen = nil;
                            Frame.Visible = false;
                            Frame.Size = AbsoluteSize;
                        end)
    
                        Camera.ChangeFOV(workspace.CurrentCamera, {FieldOfView = 70, Time = 0.1});
                        
                        task.spawn(function()
                            TweenService:Create(Buttons:FindFirstChild(Frame.Name), TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Size = UDim2.new(0.9, 0, 0.197, 0)}):Play();
                        end)
    
                    end)
                end
            end
        end
    end)
end

function Handler.DisableHUD()
    --HUD.Visible = false;
end

function Handler.EnableHUD()
   -- HUD.Visible = true;
end

function Handler.Reset()

    Camera.ChangeFOV(workspace.CurrentCamera, {FieldOfView = 70, Time = 0.1});
    Handler.CurrentlyOpen = nil;

    --[[if workspace.CurrentCamera.Blur then
        workspace.CurrentCamera.Blur:Destroy();
    end]]
                        
    for _, Frame : Frame in ipairs(ActiveFrames) do
        if Frame:IsA("ImageLabel") or Frame:IsA("Frame") then

            for _, otherButtons : ImageButton in ipairs(Buttons:GetChildren()) do
                if otherButtons:IsA("ImageButton") then
                    otherButtons.Active = true;
                    TweenService:Create(otherButtons, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {ImageTransparency = 0}):Play();
                end
            end

            local AbsoluteSize = Frame.Size;
            local tw = TweenService:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Circular), {Size = UDim2.new(0, 0, 0, 0)})
            
            tw:Play()
            
            if workspace.CurrentCamera:FindFirstChild("Blur") then
                workspace.CurrentCamera.Blur:Destroy();
            end

            tw.Completed:Connect(function()

                Handler.CurrentlyOpen = nil;
                Frame.Visible = false;
                Frame.Size = AbsoluteSize;
                
            end)

            Camera.ChangeFOV(workspace.CurrentCamera, {FieldOfView = 70, Time = 0.1});
            
            task.spawn(function()
                TweenService:Create(Buttons:FindFirstChild(Frame.Name), TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Size = UDim2.new(0.9, 0, 0.197, 0)}):Play();
            end)
        end
    end
end

return Handler;