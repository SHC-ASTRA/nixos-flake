{ inputs, ... }:
{
  imports = [
    ../common
    ../common/cpu-intel.nix
    ../../disko
    inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
  ];

  networking.hostName = "clucky";
  astra.role.rover.enable = true;
}
