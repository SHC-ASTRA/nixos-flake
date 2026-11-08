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
      displayManager.sddm.enable = true;
      desktopManager.plasma6.enable = true;
      xserver = {
        enable = true;
      };
    };
  };
}
