{
  imports = [
    ../common
    ../common/cpu-intel.nix
    ../../disko
  ];

  networking.hostName = "bs-nuc";
  astra.role.basestation.enable = true;
}
