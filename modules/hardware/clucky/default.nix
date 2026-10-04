{
  imports = [
    ../common
    ../../disko
    ./jetpack.nix
  ];

  networking.hostName = "clucky";
  astra.role.rover.enable = true;

  # Enable GPU support - needed even for CUDA and containers
  hardware.graphics.enable = true;
}
