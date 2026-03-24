{ den, ... }:
{
  # host aspect
  den.aspects.antenna = {
    includes = [
      (den.provides.hostname "antenna")
    ];
    # host NixOS configuration
    nixos =
      { ... }:
      {

      };

    # antenna provides default home environment for its users
    homeManager =
      { ... }:
      {

      };
  };
}
