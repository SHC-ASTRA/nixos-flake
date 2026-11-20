{ inputs, pkgs, ... }:
{
  imports = [
    ../common
    ../common/cpu-intel.nix
    ../../disko
    inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
  ];

  networking.hostName = "testbed";
  astra.role.rover.enable = true;

  # everything below drives the desktop/datacenter NVIDIA driver. it is here rather
  #   than in the rover role because clucky is a Jetson, which has its own quirks
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;

  # Docker & nvidia Runtime config
  virtualisation.docker.daemon.settings = {
    runtimes = {
      nvidia = {
        path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
        runtimeArgs = [ ];
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
}
