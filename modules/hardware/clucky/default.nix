{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
  ];

  networking.hostName = "clucky";
  astra.role.rover.enable = true;
}
