{ config, ... }:
{
  networking.interfaces."enp1s0" = {
    ipv4.addresses = [
      {
        address = config.astra.hosts.panda.ip;
        prefixLength = 24;
      }
    ];
  };
}
