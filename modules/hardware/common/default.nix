{
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # storage, input, and VM controllers found on our x86 boxes. these don't work on the
  # jetson, but jetpack-nixos configures Tegra equivalents (nvme, xhci-tegra, ...) onits
  # own
  boot.initrd.availableKernelModules = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 [
    "xhci_pci"
    "thunderbolt"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
    "rtsx_usb_sdmmc"
    # only active in VMs
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "virtio_net"
  ];
  boot.initrd.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
