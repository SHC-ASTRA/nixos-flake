{
  imports = [
    ../common
    ../common/cpu-intel.nix
    ../../disko
  ];

  networking.hostName = "antenna";
  astra.role.antenna.enable = true;
}
