{ den, ... }:
{
  # host aspect
  den.aspects.deck = {
    includes = [
      den.aspects.deckHardware
      den.aspects.system_desktop
      den.aspects.zed
    ];

    # host NixOS configuration
    nixos =
      { pkgs, lib, config, ... }:
      {
        # Packages

        # Networking
        networking = {
          interfaces."enp4s0f3u1u2" = {
            ipv4.addresses = [{
              address = "192.168.1.31";
              prefixLength = 24;
            }];
          };
        };
      };

    # host provides default home environment for its users
    homeManager =
      { ... }:
      {

      };
  };
}
