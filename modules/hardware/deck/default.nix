{ ... }:
{
  imports = [
    ../common
    ../common/cpu-amd.nix
    ../../disko
  ];

  networking.hostName = "deck";
  astra.role.basestation.enable = true;
}
