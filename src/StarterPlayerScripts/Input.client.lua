--// Services:
local repS: ReplicatedStorage = game:GetService("ReplicatedStorage")
local uIS: UserInputService = game:GetService("UserInputService")
local playerS: Players = game:GetService("Players")

--// Assets:
local packages: Folder = repS.Packages

--// Imports:
local net: ModuleScript = require(packages.BridgeNet2)

--// Declarables:
local main: any = net.ReferenceBridge("Main")
local spaceHeld: boolean = false

			-------------------------------
			-- // Utility Connections \\ --
			-------------------------------

--[[
	@Connection:
--	Description: .
--	@param:		Name: i		Type: InputObject		Description: .
--	@param:		Name: gpe		Type: boolean		Description: .
]]
uIS.InputBegan:Connect(function(i: InputObject, gpe: boolean) -- Uis input monitoring.
	if not gpe then -- If gpe is false.
		--	[[ Input for MouseButton1. ]]
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.KeyCode == Enum.KeyCode.F then -- MouseButton1 input.
			main:Fire( {Request = "M1", Arguments = {}} )  -- Fires the array to server.

		--	[[ Input for ability. ]]
		elseif i.KeyCode == Enum.KeyCode.Q then -- Q input.
			main:Fire( {Request = "Ability", Arguments = {}} ) -- Fires the array to server.

		--	[[ Input for single/double jump. ]]
		elseif i.KeyCode == Enum.KeyCode.Z then
			main:Fire( {Request = "LockOn", Arguments = {}} )
		end
	end
end)