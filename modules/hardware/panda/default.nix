{
  imports = [
    ../common
    ../common/cpu-intel.nix
    ../../disko
    ./network.nix
  ];

  networking.hostName = "panda";
  astra.role.basestation.enable = true;
}
