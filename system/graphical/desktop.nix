{ ... }:
{
  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };
  services = {
    xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      desktopManager.gnome.enable = true;
    };

    gnome = {
      core-utilities.enable = true;
      core-developer-tools.enable = false;
      games.enable = false;
      gnome-keyring.enable = true;
    };
  };
}
