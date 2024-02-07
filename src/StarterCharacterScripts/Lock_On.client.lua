task.wait()

local player = game.Players.LocalPlayer
local character = player.Character
local camera = workspace.CurrentCamera

local run_service = game:GetService("RunService")
local input = game:GetService("UserInputService")

local is_locked_on = false
local mouse = player:GetMouse()

local packages = game.ReplicatedStorage.Packages
local net = require(packages.BridgeNet2)

local get_server_info = net.ReferenceBridge("InfoRequester")
local main: any = net.ReferenceBridge("Main")

local thread = nil;

local defaultCframe = camera.CFrame
local can = true

--[[net.ReferenceBridge("LockOn"):Connect(function(content)

  print("LOCKING ON...")

    local info = content.Info;

    print(info)

    if info then 

        is_locked_on = true;
               
        local playerToLockOn : Player = game.Players:FindFirstChild(info)
        print(playerToLockOn)

        local lockOnCharacter = info
        local _HRP = lockOnCharacter.HumanoidRootPart;

        local function UpdateCam()
            if lockOnCharacter.Humanoid.Health > 0 and lockOnCharacter then

               -- print("Is alive")

                local hrpPos, dummyPos = character.HumanoidRootPart.CFrame.Position, _HRP.Position
                local CFam = CFrame.new(hrpPos, Vector3.new(dummyPos.X, hrpPos.Y, dummyPos.Z))

                local CamCFam = CFam*CFrame.new(5, 4, 10) 
                workspace.CurrentCamera.CFrame = CamCFam

            else

                --print("Is dead")
                is_locked_on = false;
                thread:Disconnect()

            end
        end
        
        thread = run_service.RenderStepped:Connect(UpdateCam)

    end
end)

input.InputBegan:Connect(function(i, gameProcessedEvent)
    if not gameProcessedEvent and i.KeyCode == Enum.KeyCode.Z then
        if is_locked_on == false then 

            print("activated")
            
            is_locked_on = true
            main:Fire( {Request = "LockOn", Arguments = {is_locked_on}} ) 

            local info = get_server_info:InvokeServerAsync("GetInfo")

            if info then 
               
                local playerToLockOn : Player = game.Players:FindFirstChild(info)
                print(playerToLockOn)

                local lockOnCharacter = playerToLockOn.Character
                local _HRP = lockOnCharacter.HumanoidRootPart;

                local function UpdateCam()
                    if lockOnCharacter.Humanoid.Health > 0 and playerToLockOn then

                        --print("Is alive")

                        local hrpPos, dummyPos = character.HumanoidRootPart.CFrame.Position, _HRP.Position
                        local CFam = CFrame.new(hrpPos, Vector3.new(dummyPos.X, hrpPos.Y, dummyPos.Z))

                        local CamCFam = CFam*CFrame.new(5, 4, 10) 
                        workspace.CurrentCamera.CFrame = CamCFam

                    else

                       -- print("Is dead")
                        is_locked_on = false;
                        thread:Disconnect()

                    end
                end
                
                thread = run_service.RenderStepped:Connect(UpdateCam)
                
            end

        else

            print("deactivating.")

            is_locked_on = false
            main:Fire( {Request = "LockOn", Arguments = {is_locked_on}} ) 
            if thread then thread:Disconnect() end

        end
    end
end)]]