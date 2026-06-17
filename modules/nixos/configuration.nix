{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  uahNetworks = {
    "Student5" = "Go Chargers!";
    "Staff5" = "Where is the coffee?";
    "Faculty5" = "You will be tested";
  };
  mkPsk = passphrase: ''
    [Security]
    Passphrase=${passphrase}
  '';
in
{
  options.astra = {
    role = {
      rover.enable = lib.mkEnableOption "clucky and testbed";
      antenna.enable = lib.mkEnableOption "antenna";
      basestation.enable = lib.mkEnableOption "deck and panda";
    };

    hosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.ip = lib.mkOption { type = lib.types.str; };
        }
      );
      default = { };
      description = "Known astra hosts and their LAN IPs.";
    };
  };

  config = {
    astra.hosts = {
      antenna.ip = "192.168.1.33";
      clucky.ip = "192.168.1.69";
      deck.ip = "192.168.1.31";
      panda.ip = "192.168.1.32";
      testbed.ip = "192.168.1.70";
    };

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
        "docker" # allows docker
        "dialout" # allows serial
        "input" # allows access to Human Interface Devices (HID) like controllers
        "usb" # allows access to other USB devices
      ];

      # this is technically bad practice to publish, but everyone already knows this password anyways
      hashedPassword = "$y$j9T$esraCMpX2wws6dAC7ypZO.$mz7g5Fgu42MGy/AS56x9IcytnK1LgG4YSUIZGcvbRm9";

      openssh.authorizedKeys.keys = import ./agenix/authorized_keys.nix;
    };

    nixpkgs.config.allowUnfree = true;

    programs = {
      dconf.enable = true;
    };

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
          (with p; [
            ament-cmake-core
            python-cmake-module
            ros-core
            ros2cli
            ros2run
          ])
          ++ lib.optionals config.astra.role.rover.enable [ p.realsense2-camera ]
          ++ lib.optionals config.astra.role.basestation.enable [ p.rqt-graph ];
      };

      pulseaudio.enable = false;

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      openssh = {
        enable = true;
        settings = {
          UseDns = true;
          PasswordAuthentication = true;
          PermitRootLogin = "no";
          X11Forwarding = true;
          X11UseLocalhost = true;
        };
      };

      avahi = {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = true;
        openFirewall = true;
        publish = {
          enable = true;
          userServices = true;
          addresses = true;
        };
      };
    };

    security.rtkit.enable = true;

    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
    };

    systemd = {
      targets = {
        sleep.enable = false;
        suspend.enable = false;
        hibernate.enable = false;
        hybrid-sleep.enable = false;
      };

      services."getty@tty1" = {
        overrideStrategy = "asDropin";
        serviceConfig.ExecStart = [
          ""
          "@${pkgs.util-linux}/sbin/agetty agetty --login-program ${config.services.getty.loginProgram} --autologin astra --noclear --keep-baud %I 115200,38400,9600 $TERM"
        ];
      };

      network = {
        enable = true;
        networks = {
          # any ethernet interface gets the devices assigned IP on the ASTRA LAN
          "20-astra-lan" = {
            matchConfig = {
              Type = "ether";
              Kind = "!*"; # skip bridges/bonds/etc
            };
            address = [ "${config.astra.hosts.${config.networking.hostName}.ip}/24" ];
            networkConfig.DHCP = "no";
            linkConfig.RequiredForOnline = "no";
          };
          "40-wireless" = {
            matchConfig.Type = "wlan";
            networkConfig.DHCP = "yes";
          };
          "30-can" = {
            matchConfig.Name = "can*";
            canConfig.BitRate = "1M";
            linkConfig.RequiredForOnline = "no";
          };
        };
      };
    };

    # hardcoded UAH wifi PSKs go into /var/lib/iwd at activation
    environment = {
      etc = lib.mapAttrs' (ssid: passphrase: {
        name = "iwd/${ssid}.psk";
        value = {
          text = mkPsk passphrase;
          mode = "0600";
        };
      }) uahNetworks;

      sessionVariables.EDITOR = "nvim";

      shellAliases = {
        vim = "nvim";
      };

      systemPackages =
        with pkgs;
        [
          # Network
          xorg.xauth # required for x forwarding to configure security
          impala # iwd TUI

          # System
          gh
          socat
          usbutils
          silver-searcher
          wl-clipboard
          btop
          tree
          ripgrep
          comma
          bat

          # Programming
          micro
          nil
          nixd
          neovim
          ripgrep
          nixfmt-rfc-style
          tmux
          platformio

          # Build stuff
          gcc
          colcon
          gnumake
          python312Packages.pyserial
        ]
        ++ (with inputs.basestation-cameras.packages.${pkgs.system}; [
          cameracli
          pkgs.parallel # i don't know how to fix this
        ])
        ++ [
          inputs.agenix.packages.${pkgs.system}.default
        ];
    };

    system.activationScripts.iwd-networks.text = ''
      install -d -m 0700 /var/lib/iwd
      install -m 0600 /etc/iwd/*.psk /var/lib/iwd/
    '';

    networking = {
      # use systemd-networkd and iwd
      networkmanager.enable = false;
      useDHCP = false;
      wireless.enable = false;

      wireless.iwd = {
        enable = true;
        settings = {
          IPv6.Enabled = true;
          Settings = {
            AutoConnect = true;
            # fixes some issues with wpa2
            ControlPortOverNL80211 = false;
          };
        };
      };

      firewall.enable = false;

      # map each host's LAN IP to <name>.lan in /etc/hosts
      hosts = lib.mapAttrs' (name: host: {
        name = host.ip;
        value = [ "${name}.lan" ];
      }) config.astra.hosts;
    };

    age.secrets = {
      id_ed25519-key = {
        file = ./agenix/id_ed25519-key.age;
        path = "/home/astra/.ssh/id_ed25519";
        mode = "600";
        owner = "astra";
        group = "users";
      };
    };

    system.stateVersion = "25.05";
  };
}
