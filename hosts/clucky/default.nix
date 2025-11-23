{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
  ];

  hardware.nvidia.open = false;

  hardware.nvidia-container-toolkit.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  environment.systemPackages = with pkgs; [
	xorg.xhost
  ];
}
