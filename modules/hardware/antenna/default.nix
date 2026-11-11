# antenna is an Orange Pi Zero 3 (Allwinner H618).
#
# unlike the x86 hosts it has no UEFI firmware and no internal storage, so it is not
#   provisioned with disko and the installer ISO. instead we build a bootable SD image
#   and flash it:
#
#     nix build .#packages.aarch64-linux.antenna
#     zstdcat result/sd-image/antenna.img.zst \
#       | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
#
#   the image grows its root partition to fill the card on the first boot.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    ../common
    (modulesPath + "/installer/sd-card/sd-image.nix")
  ];

  networking.hostName = "antenna";
  astra.role.antenna.enable = true;

  nixpkgs.hostPlatform = "aarch64-linux";

  # name the artifact after the host. `image.fileName` and `image.filePath` are derived
  #   from this plus the extension sd-image picks (`.img.zst`).
  image.baseName = "antenna";

  boot = {
    loader = {
      # the H618 has no UEFI. u-boot reads /boot/extlinux/extlinux.conf off the root
      #   partition instead, so turn off the EFI bootloader `modules/nixos` sets up.
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = lib.mkForce false;
      # grub defaults to on whenever systemd-boot is off, and then asserts that it was
      #   given a device to install itself onto. we want neither of them here.
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    # UART0, broken out on the 3-pin debug header next to the USB-C jack
    kernelParams = [
      "console=ttyS0,115200n8"
      "console=tty0"
    ];
    consoleLogLevel = lib.mkDefault 7;
  };

  # the board has between 1G and 4G of RAM and no swap partition (the SD layout has no
  #   room for one), and ROS2 nodes plus the ffmpeg restream are happy to use all of it.
  zramSwap.enable = true;

  sdImage = {
    # the FAT firmware partition only exists to hold Raspberry Pi firmware. the H618
    #   boots from raw sectors instead (see `postBuildCommands`), so leave it empty.
    populateFirmwareCommands = "";

    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';

    # the H618 boot ROM looks for the u-boot SPL 8 KiB into the SD card. sd-image leaves
    #   `sdImage.firmwarePartitionOffset` (8 MiB) empty in front of the first partition,
    #   which is room to spare for the SPL and the u-boot proper appended to it.
    postBuildCommands = ''
      dd if=${pkgs.ubootOrangePiZero3}/u-boot-sunxi-with-spl.bin of=$img bs=1024 seek=8 conv=notrunc
    '';
  };
}
