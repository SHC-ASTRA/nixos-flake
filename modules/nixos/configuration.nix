{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  # options that define our systems.
  # options are accessible in every module which makes them especially useful
  options.astra = {
    # features are provided in sets we call "roles".
    role = {
      rover.enable = lib.mkEnableOption "headless environment with rover stuff";
      antenna.enable = lib.mkEnableOption "headless environment with antenna stuff";
      basestation.enable = lib.mkEnableOption "graphical environment with basestation things";
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
      # these ensure that flakes work properly
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # doing this lets astra accept extra substituters
      trusted-users = [
        "root"
        "astra"
      ];
    };

    # overwrite /etc/shadow, /etc/group, and /etc/passwd so they don't drift from the config
    users.mutableUsers = false;

    # main login user
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

      # allow ssh from all of the same users that can decrypt the secrets
      openssh.authorizedKeys.keys = import ./agenix/authorized_keys.nix;
    };

    # by default, software with unfree licenses will not evaluate. we want some unfree stuff so this fixes that
    nixpkgs.config.allowUnfree = true;

    # dconf is a GNOME dep
    programs = {
      dconf.enable = true;
    };

    # we have used docker off and on for various things. keep this unless you are sure we don't need it.
    virtualisation.docker.enable = true;

    services = {
      # let the logged in user use controllers (thanks valve)
      udev.packages = with pkgs; [
        steam-devices-udev-rules
      ];

      # useful ros tools to have. also opens the firewall.
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
          ++ lib.optionals config.astra.role.basestation.enable [ p.rqt-graph ]
          # we have a systemd service that uses this
          ++ lib.optionals config.astra.role.rover.enable [ p.realsense2-camera ];
      };

      # pipewire is the modern audio stack option, so we disable pulseaudio and enable the compatibility feature.
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # allow remote control over ssh
      openssh = {
        enable = true;
        settings = {
          UseDns = true;
          # generally considered bad practice
          PasswordAuthentication = true;
          PermitRootLogin = "no";
          X11Forwarding = true;
          X11UseLocalhost = true;
        };
      };

      # lets devices be discovered via <hostname>.local. useful when not plugged in over ethernet.
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

    # allow unprivileged users to set higher thread priority (lower niceness)
    security.rtkit.enable = true;

    # this one is pretty straightforward
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
    };

    systemd = {
      # there will be no rest. this is ASTRA.
      targets = {
        sleep.enable = false;
        suspend.enable = false;
        hibernate.enable = false;
        hybrid-sleep.enable = false;
      };

      # this is a weird one. the steam udev rules use the `uaccess` tag, which means they only apply to the user with the active tty. normally this is fine,
      #   but on testbed and clucky there is no logged in user at all, let alone one with an active tty. getty lets us automatically log into tty1 so that
      #   controllers will still work for headless purposes. technically not required for non-rover systems as far as i can tell, but also won't hurt anything.
      services."getty@tty1" = {
        overrideStrategy = "asDropin";
        serviceConfig.ExecStart = [
          ""
          "@${pkgs.util-linux}/sbin/agetty agetty --login-program ${config.services.getty.loginProgram} --autologin astra --noclear --keep-baud %I 115200,38400,9600 $TERM"
        ];
      };

      # networking settings. general info on our networking setup:
      #   - systemd-networkd manages general networking
      #   - iwd manages wifi
      network = {
        # systemd-networkd config
        enable = true;
        networks = {
          # any ethernet interface gets the devices assigned IP on the ASTRA LAN
          "20-astra-lan" = {
            matchConfig = {
              Type = "ether";
              Kind = "!*"; # skip bridges/bonds/etc
            };
            # grab the ip for the current hostname and set the subnet mask to /24
            address = [ "${config.astra.hosts.${config.networking.hostName}.ip}/24" ];
            networkConfig.DHCP = "no";
            linkConfig.RequiredForOnline = "no"; # important for headless & deck (where there might be no ethernet)
          };
          "40-wireless" = {
            matchConfig.Type = "wlan";
            networkConfig.DHCP = "yes";
          };
          "30-can" = {
            # if you ever switch off of systemd-networkd, check out commit c62ca53c1005b1bd7d037d75c688c2700dfa092d
            matchConfig.Name = "can*";
            canConfig.BitRate = "1M";
            linkConfig.RequiredForOnline = "no";
          };
        };
      };
    };

    # iwd handles wifi for us
    # we don't use NetworkManager because it is a pain to configure programatically. if you take a look below (in environment.etc) you can see how dummy easy
    #   it is to configure wifi networks with iwd. there is also a great TUI tool called impala that replaces nmtui.
    networking = {
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

      # TODO: enable this
      firewall.enable = false;

      # map each host's LAN IP to <name>.lan in /etc/hosts
      hosts = lib.mapAttrs' (name: host: {
        name = host.ip;
        value = [ "${name}.lan" ];
      }) config.astra.hosts;
    };

    # dunno about you but i'm tired of putting in the same wifi password over and over.
    # iwd reads .psk files from /var/lib/iwd & wants files to be mode 0600 & owned by root,
    #   so we can't symlink to the store like i want to. instead we just make the files with
    #   an activation script.
    system.activationScripts.iwd-networks.text =
      let
        networks = {
          # uah non-eduroam networks
          "Student5" = "Go Chargers!";
          "Staff5" = "Where is the coffee?";
          "Faculty5" = "You will be tested";
        };
        writePsk = ssid: passphrase: ''
          install -m 0600 /dev/null /var/lib/iwd/${ssid}.psk
          cat > /var/lib/iwd/${ssid}.psk <<'EOF'
          [Security]
          Passphrase=${passphrase}
          EOF
        '';
      in
      ''
        install -d -m 0700 /var/lib/iwd
      ''
      + lib.concatStrings (lib.mapAttrsToList writePsk networks);

    environment = {
      # most of the neovim config is in modules/home-manager
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
          socat # talk to sockets directly
          usbutils # provides lsusb among others
          silver-searcher # ag is a fast file searcher
          wl-clipboard # programatically interact with the wayland clipboard
          btop # pretty system monitor
          tree # prints out directory structures
          ripgrep # another file search tool, this one optimized for regex
          nix-index # create a local, searchable index of nixpkgs
          nix-search # search the aforementioned index
          comma # quickly use packages from, you guessed it, the same index
          bat # prettier cat

          # Programming
          micro # easy to use editor. has the same keybinds as traditional editors
          nil # lsp for nix
          nixd # othermoredifferent lsp for nix
          neovim # vim (more powerful editor, but with a learning curve) with lsp support
          nixfmt # format nix files
          tmux # terminal multiplexer
          platformio # flash MCUs

          # Build stuff
          gcc # GNU C/C++ Compiler
          colcon # ROS2 build system
          gnumake
          python312Packages.pyserial # talk to serial devices in python
        ]
        ++ (with inputs.basestation-cameras.packages.${pkgs.system}; [
          cameracli # cli to list connected cameras
        ])
        ++ [
          inputs.agenix.packages.${pkgs.system}.default # encryption for nix configurations
        ];
    };

    # make /home/astra/.ssh owned by astra so agenix doesn't make it as root when it puts the key in.
    # without this, home-manager can't write the ssh config.
    # `d` will create the directory
    # `Z` will update permissions on an existing directory
    systemd.tmpfiles.rules = [
      "d /home/astra/.ssh 0700 astra users -"
      "Z /home/astra/.ssh 0700 astra users -"
    ];

    # decrypt the ssh private key and symlink it to astra's .ssh
    age.secrets = {
      id_ed25519-key = {
        file = ./agenix/id_ed25519-key.age;
        path = "/home/astra/.ssh/id_ed25519";
        mode = "600";
        owner = "astra";
        group = "users";
      };
    };

    # don't change this unless you've properly migrated the state (or you know you're reinstalling on every version)
    system.stateVersion = "25.05";
  };
}
