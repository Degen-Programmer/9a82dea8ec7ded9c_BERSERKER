type FUSING = {

    _name : string;
    _element : BasePart;

    _GUI: {

        Container : Frame;
        Close : ImageButton;
        Fuse : ImageButton;

    };

    -- // Unique properties:

    _fusingTBL : {}; -- The list that holds all the selected items

     ---------------------------------------------------

    -- // Base Methods inherited from ELEMENT:

    -----------------------------------------------------

    New : () -> nil; -- creates a new Gacha class object. called only once.

    CreateBlur : () -> nil;  -- creates a blur in the camera background. saves the blur as (self._blur)

    Open : (Menu : string) -> nil;  -- Opens the menu selected (Weapons/Abilities...etc)

    Close : () -> nil;  -- Gets the currently open meny and closes it.
    
    Deploy : () -> nil;  -- creates a new _element instance. called only once.

    ParseRequest : (kwargs : {}) -> (any?); -- parses any request incoming from the server.

    ---------------------------------------------------

    -- // Unique class-specific methods:

    -----------------------------------------------------

    PostRequest : () -> nil; -- method that requests the server to fuse the items

    PlayAnimation : (Arguments : {SelectedItem : string}) -> nil; -- Plays the fusing animation if the server validates the request.

    SelectItem : (Item : string) -> string; -- Called when an m1 connection is triggered.

    RemoveItem : (Item : string) -> string; -- Called upon SelectItem() is called, if the item has already been selected, remove it.
    
    AddItem : (Item : string) -> string; -- Called upon SelectItem(), if item does not exist than add it.

};

local Fusing = {} :: FUSING
Fusing.__index = Fusing;

local Playergui = game.Players.LocalPlayer.PlayerGui
local FUSING_FRAME : Frame = Playergui.Root.Fusing;

local Camera : Camera? = workspace.CurrentCamera;
local Tweenservice = game:GetService("TweenService");

local UIS = game:GetService("UserInputService")
local Rep = game:GetService("ReplicatedStorage")

local Net = require(Rep.Packages.BridgeNet2)
local Bridge = Net.ReferenceBridge("ServerCommunication");


return Fusing
