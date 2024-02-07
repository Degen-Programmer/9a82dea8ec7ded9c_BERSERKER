--// Class declareables:
local Replicator = { }

-- // Services:
local Rep = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local players = game:GetService("Players")

-- // Assets:

local Packages = Rep.Packages
local Net = require(Packages.BridgeNet2)
local Get : RemoteEvent = Rep.Get

--// Declareables.

local ReplicationManager = Net.ReferenceBridge("ClientReplicator")

type replication_arguments = {

	Scope: string, -- scope, how many players this should be replicated to.
	Request: string, -- What you want the client to do;
	Action: string,
	Arguments: table -- All your arguments you want to send to the client.

}

function Replicator.GetMousePosition(Player)

	Get:FireClient(Player, "GetMousePosition")

end

--[[

	@function Replicator.ReplicateToAll:

		@param      player          Player             only this player will execute the function. 
		@param      Request         string             the module that needs to be required on the client.
		@param       Action         string             function of said module that needs to be called.
		@param      Arguments       table              arguments that need to be passed to the function.

	Replicates to all players.

]]


function Replicator.ReplicateToPlayer(player : Player, Request: string, Action: string, Arguments)
	ReplicationManager:Fire(Net.Players({player}), {

		Request = Request; -- ability to call.
		Action = Action; -- function to execute.
		Arguments = Arguments;
		
	})
end

	
--[[

	@function Replicator.ReplicateToAll:

		@param      Request         string             the module that needs to be required on the client.
		@param       Action         string             function of said module that needs to be called.
		@param      Arguments       table              arguments that need to be passed to the function.

	Replicates to all players.

]]

function Replicator.ReplicateToAll(Request: string, Action: string, Arguments)
	ReplicationManager:Fire(Net.AllPlayers(), {

		Request = Request; -- ability to call.
		Action = Action; -- function to execute.
		Scope = "All";

		Arguments = Arguments

	})
end

return Replicator