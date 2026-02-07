{
  pkgs,
  config,
  host,
  ...
}:
{
  # Bootloader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  environment.sessionVariables.EDITOR = "nvim";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "astra"
    ];
  };

  users.mutableUsers = false;

  users.users.astra = {
    isNormalUser = true;
    description = "ASTRA";
    extraGroups = [
      "wheel" # allows the use of sudo
      "networkmanager" # allows network management
      "hostapd" # allows hotspot configuration
      "docker" # allows docker
      "dialout" # allows serial
      "input" # allows access to Human Interface Devices (HID) like controllers
      "usb" # allows access to other USB devices
    ];

    # this is technically bad practice to publish, but everyone already knows this password anyways
    hashedPassword = "$y$j9T$esraCMpX2wws6dAC7ypZO.$mz7g5Fgu42MGy/AS56x9IcytnK1LgG4YSUIZGcvbRm9";
  };

  nixpkgs.config.allowUnfree = true;

  programs.dconf.enable = true;

  virtualisation.docker.enable = true;

  services = {
    udev.packages = with pkgs; [
      steam-devices-udev-rules
    ];
    ros2 = {
      enable = true;
      distro = "humble";

      systemPackages =
        p:
        (
          with p;
          [
            ament-cmake-core
            python-cmake-module
            ros-core
            ros2cli
            ros2run
          ]
          ++ (if host.isGraphical then [ rqt-graph ] else [ ])
        );
    };

    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  security.rtkit.enable = true;

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  systemd.services."getty@tty1" = {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStart = [
      ""
      "@${pkgs.util-linux}/sbin/agetty agetty --login-program ${config.services.getty.loginProgram} --autologin astra --noclear --keep-baud %I 115200,38400,9600 $TERM"
    ];
  };

  system.stateVersion = "25.05";
}
