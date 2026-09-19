{ ... }:
{
  imports = [
    ../common
    ../../disko
  ];

  # the shared hardware module defaults to x86_64, but the Orin is aarch64
  nixpkgs.hostPlatform = "aarch64-linux";

  networking.hostName = "clucky";
  astra.role.rover.enable = true;

  # Jetson-specific
  hardware.nvidia-jetpack.enable = true;
  hardware.nvidia-jetpack.som = "orin-agx";
  hardware.nvidia-jetpack.carrierBoard = "devkit";

  # Enable GPU support - needed even for CUDA and containers
  hardware.graphics.enable = true;
}
