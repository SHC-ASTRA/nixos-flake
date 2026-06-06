{
  description = "NixOS configurations for ASTRA";

  inputs = {
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";
    hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    basestation-cameras = {
      url = "github:SHC-ASTRA/basestation-cameras";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
      };
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
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
    in
    {
      nixosConfigurations = {
        antenna = mkSystem ./modules/hardware/antenna;
        clucky = mkSystem ./modules/hardware/clucky;
        deck = mkSystem ./modules/hardware/deck;
        panda = mkSystem ./modules/hardware/panda;
        testbed = mkSystem ./modules/hardware/testbed;
        nixos = mkSystem ./modules/hardware/nixos;
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
