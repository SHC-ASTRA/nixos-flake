{
  imports =
    if builtins.pathExists ../../../hardware-configuration.nix then
      [ ../../../hardware-configuration.nix ]
    else
      [ ];

  networking.hostName = "nixos";
  astra.role.basestation.enable = true;
}
