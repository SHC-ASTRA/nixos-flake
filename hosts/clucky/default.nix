{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
  ];

  nixpkgs.config.allowUnfree = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;
  hardware.nvidia-container-toolkit.enable = true;
  

  # Docker & nvidia Runtime config
  virtualisation.docker.enable = true;

  virtualisation.docker.daemon.settings = {
    runtimes = {
      nvidia = {
        path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
        runtimeArgs = [];
      };
    };

    # Enable CDI support
    features = {
      cdi = true;
    };
  };

  # Ensure /etc/cdi exists
  systemd.tmpfiles.rules = [
    "d /etc/cdi 0755 root root -"
  ];

  systemd.services.nvidia-cdi-generator = {
    description = "Generate NVIDIA CDI spec for containers";
    wantedBy = [ "multi-user.target" ];
    before = [ "docker.service" ];
    after = [ "systemd-modules-load.service" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml";
    };
  };

  environment.systemPackages = with pkgs; [
	  xorg.xhost
    nvidia-container-toolkit
  ];
}
