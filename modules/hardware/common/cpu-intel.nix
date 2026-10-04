{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.kernelModules = [ "kvm-intel" ];
  boot.initrd.kernelModules = [ "i915" ];
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };
}
