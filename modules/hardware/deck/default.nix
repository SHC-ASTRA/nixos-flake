{ ... }:
{
  imports = [
    ../common
    ../common/cpu-amd.nix
    ../../disko
    ./network.nix
  ];

  networking.hostName = "deck";
  astra.role.basestation.enable = true;
}
