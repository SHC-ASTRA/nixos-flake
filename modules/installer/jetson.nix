# turns the ASTRA installer ISO into one that boots on clucky's Jetson Orin.
{ inputs, lib, ... }:
let
  cluckyPkgs = inputs.self.nixosConfigurations.clucky.pkgs;
in
{
  imports = [
    # same SOM and carrier as the installed system, so the ISO runs the kernel and
    #   device tree clucky will end up with
    ../hardware/clucky/jetpack.nix
  ];

  # small mountain of x86 drivers we don't need so that initrd doesn't explode
  hardware.enableAllHardware = lib.mkForce false;

  # the CD profile turns ZFS on, which builds its kernel module against the Tegra kernel.
  #   we install btrfs, so this only costs us importing a ZFS pool from the rescue ISO.
  boot.supportedFilesystems.zfs = false;

  # ros-humble-cv-bridge depends on opencv, which takes more RAM to compile than
  #   the jetson has available. pre-compile so it doesn't explode.
  # the python bindings are in this same path, see `modules/nixos/opencv.nix`
  isoImage.storeContents = [
    cluckyPkgs.opencv.out
    cluckyPkgs.opencv.cxxdev
  ];
}
