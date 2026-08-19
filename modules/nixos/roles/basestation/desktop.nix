{ config, lib, ... }:
{
  config = lib.mkIf config.astra.role.basestation.enable {
    programs = {
      hyprland = {
        enable = true;
        xwayland.enable = true;
      };
    };
    services = {
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      desktopManager.gnome.enable = true;
      xserver = {
        enable = true;
      };

      gnome = {
        core-apps.enable = true;
        core-developer-tools.enable = false;
        games.enable = false;
        gnome-keyring.enable = true;
      };
    };
  };
}
