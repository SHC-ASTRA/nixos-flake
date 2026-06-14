{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.astra.role.rover.enable {
    networking.interfaces."enp85s0" = {
      ipv4.addresses = [
        {
          address = config.astra.hosts.${config.networking.hostName}.ip;
          prefixLength = 24;
        }
      ];
    };
  };
}
