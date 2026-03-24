{
  den.aspects.gnome = {
    includes = [

    ];

    nixos = 
    { pkgs, ... }:
    {
      services.desktopManager.gnome = {
        enable = true;
      };
      services.gnome.games.enable = false;
      environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];
    };

    homeManager = {
      dconf.enable = true;
    };
  };
}
