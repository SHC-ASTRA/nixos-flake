{
  den.aspects.hyprland = {
    includes = [

    ];

    nixos = {
      programs.hyprland = {
        enable = true;
        xwayland = true;
      };
    };

    homeManager = {
      wayland.windowManager.hyprland.enable = true;
    };
  };
}
