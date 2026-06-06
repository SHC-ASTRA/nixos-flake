{
  imports = [
    ./hardware-configuration.nix
    ./network.nix
  ];

  networking.hostName = "panda";
  astra.role.basestation.enable = true;
}
