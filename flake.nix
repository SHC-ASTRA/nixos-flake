{
  description = "Home Manager configuration of ASTRA";

  inputs = {
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.05";
      follows = "nix-ros-overlay/nixpkgs";
    };
    hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    basestation-cameras.url = "github:SHC-ASTRA/basestation-cameras";
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
      };
    };
  };

  outputs =
    inputs@{
      self,
      nix-ros-overlay,
      nixpkgs,
      home-manager,
      basestation-cameras,
      hardware,
      ...
    }:
    let
      system = "x86_64-linux";
      username = "astra";

      # Obtains the function mkHost passing 'inputs' and 'system'
      mkHost = import ./lib/mkHost.nix { inherit inputs system; };

      hostsConfig = {
        antenna = {
          ip = "192.168.1.33";
          isGraphical = false;
        };
        clucky = {
          ip = "192.168.1.69";
          isGraphical = false;
        };
        deck = {
          ip = "192.168.1.31";
          isGraphical = true;
        };
        panda = {
          ip = "192.168.1.32";
          isGraphical = true;
        };
        testbed = {
          ip = "192.168.1.70";
          isGraphical = false;
        };
      };

      # Generates hosts for each system based on hostsConfig
      hosts = {
        antenna = mkHost {
          name = "antenna";
          inherit username;

          extraSpecialArgs = {
            inherit self inputs;
            host = hostsConfig.antenna;
            hosts = hostsConfig;
          };
          homeSpecialArgs = {
            inherit self inputs;
            host = hostsConfig.antenna;
            hosts = hostsConfig;
          };
          isGraphical = hostsConfig.antenna.isGraphical;
        };

        clucky = mkHost {
          name = "clucky";
          inherit username;

          extraSpecialArgs = {
            inherit self inputs;
            host = hostsConfig.clucky;
            hosts = hostsConfig;
          };
          homeSpecialArgs = {
            inherit self inputs;
            host = hostsConfig.clucky;
            hosts = hostsConfig;
          };
          isGraphical = hostsConfig.clucky.isGraphical;

          nixosModules = [
            hardware.nixosModules.common-gpu-nvidia
          ];
        };

        testbed = mkHost {
          name = "testbed";
          inherit username;

          extraSpecialArgs = {
            inherit self inputs;
            host = hostsConfig.testbed;
            hosts = hostsConfig;
          };
          homeSpecialArgs = {
            inherit self inputs;
            host = hostsConfig.testbed;
            hosts = hostsConfig;
          };
          isGraphical = hostsConfig.testbed.isGraphical;
        };

        deck = mkHost {
          name = "deck";
          inherit username;

          extraSpecialArgs = {
            inherit self inputs;
            host = hostsConfig.deck;
            hosts = hostsConfig;
          };
          homeSpecialArgs = {
            inherit self inputs;
            host = hostsConfig.deck;
            hosts = hostsConfig;
          };
          isGraphical = hostsConfig.deck.isGraphical;
        };

        panda = mkHost {
          name = "panda";
          inherit username;

          extraSpecialArgs = {
            inherit self inputs;
            host = hostsConfig.panda;
            hosts = hostsConfig;
          };
          homeSpecialArgs = {
            inherit self inputs;
            host = hostsConfig.panda;
            hosts = hostsConfig;
          };
          isGraphical = hostsConfig.panda.isGraphical;
        };
      };
    in
    {
      nixosConfigurations = builtins.mapAttrs (name: host: host.nixosConfig) hosts;
    };

  nixConfig = {
    # Cache to pull ros packages from
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };
}
