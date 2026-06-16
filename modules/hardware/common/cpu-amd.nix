{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.kernelModules = [ "kvm-amd" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr.icd
    ];
  };
}
