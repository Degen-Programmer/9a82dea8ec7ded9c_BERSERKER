type GACHA = {

     ---------------------------------------------------

    -- // Base Properities inherited from ELEMENT:

    ---------------------------------------------------

    _name : string;
    _element : Part;

    _GUI : {

        Container : {

            Weapons : {

            };

            Abilities : {

            };

            DeathEffects : {

            };

            Auras: {

            };
        }

    };

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

    PostRequest : () -> nil; --


}