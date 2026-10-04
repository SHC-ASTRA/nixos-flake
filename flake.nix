{
  description = "NixOS configurations for ASTRA";

  inputs = {
    # ROS2
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";

    # Main set of packages
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";

    # Hardware-specific configuration, especially for NVIDIA drivers
    hardware.url = "github:nixos/nixos-hardware";

    # Jetson-specific
    jetpack = {
      url = "github:anduril/jetpack-nixos/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declarative drive partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manage user-level configurations.
    # nix-ros-overlay tracks nixpkgs-unstable, so we track home-manager's master rather
    #   than a release branch. mismatched versions make home-manager sad
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Gstreamer cameras app
    basestation-cameras = {
      url = "github:SHC-ASTRA/basestation-cameras";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Encrypted secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
      };
    };

    # Patches VSCode Server to work on NixOS
    vscode-server.url = "github:nix-community/nixos-vscode-server";

    # Formats the project (with `nix fmt`)
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      # so we can work with the repo from both arches. nixosConfigurations does not reference this,
      #   and instead uses `nixpkgs.hostPlatform`
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
          system: f nixpkgs.legacyPackages.${system}
        );

      baseModules = [
        inputs.nix-ros-overlay.nixosModules.default
        { nixpkgs.overlays = [ inputs.nix-ros-overlay.overlays.default ]; }
        inputs.agenix.nixosModules.default
        inputs.vscode-server.nixosModules.default
        inputs.disko.nixosModules.disko
        { services.vscode-server.enable = true; }
        ./modules/nixos
        ./modules/home-manager
      ];

      mkSystem =
        hardwareModule:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = baseModules ++ [ hardwareModule ];
        };

      mkInstaller =
        extraModules:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ ./modules/installer ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        antenna = mkSystem ./modules/hardware/antenna;
        clucky = mkSystem ./modules/hardware/clucky;
        deck = mkSystem ./modules/hardware/deck;
        panda = mkSystem ./modules/hardware/panda;
        testbed = mkSystem ./modules/hardware/testbed;

        # one installer ISO per architecture we install onto. `nixos-install` builds the
        #   system on the machine running it, so an x86 ISO cannot provision clucky.
        installer = mkInstaller [ ];
        installer-jetson = mkInstaller [ ./modules/installer/jetson.nix ];
      };

      # packages are different per arch, so we do not use forAllSystems
      packages = {
        x86_64-linux = {
          installer = self.nixosConfigurations.installer.config.system.build.isoImage;

          # reflashes the Orin's UEFI firmware. recent boards have it already and shouldn't need this.
          #   note: NVIDIA only builds the flashing tools for x86!
          #   see jetpack-nixos' README before running it.
          flash-clucky = self.nixosConfigurations.clucky.config.system.build.flashScript;
        };

        aarch64-linux.installer = self.nixosConfigurations.installer-jetson.config.system.build.isoImage;
      };

      diskoConfigurations.standard = import ./modules/disko;

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            act
            gh
          ];
          shellHook = ''
            if ! command -v docker >/dev/null 2>&1; then
              echo "warning: docker not found. \`act\` requires docker to test workflows" >&2
            fi
          '';
        };
      });

      formatter = forAllSystems (
        pkgs: (inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.wrapper
      );
    };

  nixConfig = {
    # Cache to pull ros packages from
    extra-substituters = [
      "https://ros.cachix.org"
      "https://attic.iid.ciirc.cvut.cz/ros"
    ];
    extra-trusted-public-keys = [
      "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
      "ros:JR95vUYsShSqfA1VTYoFt1Nz6uXasm5QrcOsGry9f6Q="
    ];
  };
}
