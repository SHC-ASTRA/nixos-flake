{ config, lib, ... }:
{
  config = lib.mkIf config.astra.role.rover.enable {
    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };
}
