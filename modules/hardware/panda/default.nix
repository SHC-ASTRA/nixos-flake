{
  imports = [
    ../common
    ../common/cpu-intel.nix
    ../../disko
  ];

  networking.hostName = "panda";
  astra.role.basestation.enable = true;
}
