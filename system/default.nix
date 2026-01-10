{ config, host, ... }:
{
  imports = [
    ./configuration.nix
    ./packages.nix
    ./network.nix
    ./age.nix
  ]
  ++ (if host.isGraphical then [ ./graphical ] else [ ./non-graphical ]);

  boot.extraModulePackages = [
    config.boot.kernelPackages.rtl88xxau-aircrack
  ];
}
