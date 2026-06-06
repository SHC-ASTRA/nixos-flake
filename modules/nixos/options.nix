{ lib, ... }:
{
  options.astra = {
    role = {
      rover.enable = lib.mkEnableOption "rover (clucky/testbed): NVIDIA, ROS2 autostart, no-sleep, static IP on enp85s0, hostapd";
      antenna.enable = lib.mkEnableOption "tracking antenna: PTZ restream, no-sleep";
      basestation.enable = lib.mkEnableOption "basestation (deck/panda): Hyprland + GNOME desktop";
    };

    hosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.ip = lib.mkOption { type = lib.types.str; };
        }
      );
      default = { };
      description = "Known astra hosts and their LAN IPs.";
    };
  };
}
