{ inputs, ... }:
{
  imports = [
    ./hardware.nix
    inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
  ];

  hardware.nvidia.open = false;
}
