# the Jetson-specific configuration that clucky and its installer ISO both need to have.
# they need the same SOM and carrier board, because that is what picks the kernel and
# the device tree. an ISO built for a different module might not work on the machine you
# are trying to install, though some have had success with the generic aarch64 NixOS
# installer.
{ inputs, ... }:
{
  imports = [
    inputs.jetpack.nixosModules.default
  ];

  # both importers default to x86_64 (via `hardware/common` and `modules/installer`
  #   respectively), and jetpack-nixos' own aarch64 default is a weaker priority than
  #   either, so this has to be set outright.
  nixpkgs.hostPlatform = "aarch64-linux";

  # Jetson Orin Nano Super Developer Kit. `som` and `super` pick the device tree, the
  #   firmware, and the nvpmodel power tables. Use `cat /proc/device-tree/model` on the
  #   jetson if you ever need to double check.
  hardware.nvidia-jetpack = {
    enable = true;
    som = "orin-nano";
    super = true;
    carrierBoard = "devkit";
  };
}
