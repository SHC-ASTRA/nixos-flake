{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.astra.role.rover.enable {
    # exposes the GPU to containers as `--device=nvidia.com/gpu=all`. how the CDI spec
    #   gets generated is different per host. clucky's comes from jetpack-nixos, while
    #   testbed's comes from the desktop driver.
    hardware.nvidia-container-toolkit.enable = true;

    environment.systemPackages = with pkgs; [
      xhost
      nvidia-container-toolkit
    ];
  };
}
