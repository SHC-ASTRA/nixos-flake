{
  description = "NixOS configurations for ASTRA";

  inputs = {
    # ROS2
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";

    # Main set of packages
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";

    # Hardware-specific configuration, especially for NVIDIA drivers
    hardware.url = "github:nixos/nixos-hardware";

    # Declarative drive partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manage user-level configurations
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
      system = "x86_64-linux";

      baseModules = [
        inputs.nix-ros-overlay.nixosModules.default
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
          inherit system;
          specialArgs = { inherit inputs; };
          modules = baseModules ++ [ hardwareModule ];
        };

      mkInstaller =
        module:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [ module ];
        };
    in
    {
      nixosConfigurations = {
        antenna = mkSystem ./modules/hardware/antenna;
        clucky = mkSystem ./modules/hardware/clucky;
        deck = mkSystem ./modules/hardware/deck;
        panda = mkSystem ./modules/hardware/panda;
        testbed = mkSystem ./modules/hardware/testbed;
        installer = mkInstaller ./modules/installer;
      };

      packages.${system}.installer = self.nixosConfigurations.installer.config.system.build.isoImage;

      diskoConfigurations.standard = import ./modules/disko;

      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShellNoCC {
        packages = with nixpkgs.legacyPackages.${system}; [
          act
          gh
        ];
      };

      formatter.${system} =
        (inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix)
        .config.build.wrapper;
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
