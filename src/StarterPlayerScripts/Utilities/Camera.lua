local camera = {}

local ProximityPromptService = game:GetService("ProximityPromptService")
local Tweenserivce = game:GetService("TweenService")
local CameraShaker = require(game.ReplicatedStorage.Packages.CameraShaker);

local player = game.Players.LocalPlayer;
local current_camera = workspace.CurrentCamera;
local character = player.Character;
local humanoid = character.Humanoid;

function camera.ChangeFOV(_CAM: Camera, Properties: {})
    task.spawn(function()
        local _tween = Tweenserivce:Create(_CAM, TweenInfo.new(Properties.Time), {FieldOfView = Properties.FieldOfView})
        _tween:Play()
    end)
end

function camera.ShakeSustained(preset: string, duration : number)
    
    local shaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
        current_camera.CFrame = current_camera.CFrame * shakeCFrame
    end)

    shaker:Start()
    shaker:ShakeSustain(CameraShaker.Presets[preset])

    task.delay(duration, function()
        shaker:StopSustained()
    end)
end

function camera.ChangeOffset(Return: boolean, Offset: Vector3, Time : number)
    
    local cameraOffset = humanoid.CameraOffset;
    local tweeninfo = TweenInfo.new(Time, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, Return, 0);
    local goals = {CameraOffset = Offset};

    Tweenserivce:Create(humanoid, tweeninfo, goals):Play();

end

function camera.Blur()

    local blur = Instance.new("BlurEffect")
    blur.Parent = workspace.CurrentCamera;

    return blur;
    
end

function camera.Shake(preset: string)
    local shaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
        workspace.CurrentCamera.CFrame =  workspace.CurrentCamera.CFrame * shakeCFrame
    end)

    shaker:Start()
    shaker:Shake(CameraShaker.Presets[preset])

end

function camera.Warp(kwargs, ...)
	
	local Distortion = game.ReplicatedStorage.Mesh:Clone()
	Distortion.Parent = workspace;
	
	Distortion.Size = kwargs.Size;
	Distortion.Transparency = kwargs.Transparency;

	local thread = task.spawn(function()
		game:GetService("RunService").RenderStepped:Connect(function(dt)
			Distortion.Position = workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector * kwargs.Multiplier;
		end)
	end)
	
	table.pack(...)[1](Distortion, thread)
	
end

return camera