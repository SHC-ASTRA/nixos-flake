{
  den.aspects.gdm = {
    includes = [

    ];

    nixos = {
      services.displayManager.gdm.enable = true;
    };

    homeManager = {

    };
  };
}
