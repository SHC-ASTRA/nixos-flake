{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "antenna";
  astra.role.antenna.enable = true;
}
