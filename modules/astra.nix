{ den, ... }:
{
  # user aspect
  den.aspects.astra = {
    includes = [
      den.provides.primary-user
      (den.provides.user-shell "bash")

      den.aspects.git
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.btop ];
      };

    # user can provide NixOS configurations
    # to any host it is included on
    # nixos = { pkgs, ... }: { };
  };
}
