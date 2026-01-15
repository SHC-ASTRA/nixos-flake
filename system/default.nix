{ config, host, ... }:
{
  imports = [
    ./configuration.nix
    ./packages.nix
    ./network.nix
    ./age.nix
  ]
  ++ (if host.isGraphical then [ ./graphical ./non-graphical ] else [ ./non-graphical ])
  ++ (if host.isNvidia then [ ./nvidia ] else []);

  boot.extraModulePackages = [
    config.boot.kernelPackages.rtl88xxau-aircrack
  ];
}
