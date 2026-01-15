{ inputs, system, ... }:
# This function creates a NixOS configuration with standardized structure
# It combines NixOS configuration and home-manager in a consistent way
# This code is borrowed, with permission, from <https://github.com/wizardwatch/willow/raw/refs/heads/master/lib/mkHost.nix>
{
  # Required parameters
  name, # Hostname
  username, # Primary user
  # Optional NixOS configuration overrides
  nixosModules ? [ ], # Additional NixOS modules to include (automatically includes hosts/name/default.nix)
  extraSpecialArgs ? { }, # Additional specialArgs to pass to NixOS
  # Optional home-manager configuration overrides (only used when username is set)
  homeModules ? [ ], # Additional home-manager modules to include
  homeSpecialArgs ? { }, # Additional specialArgs to pass to home-manager
  # System type for specialized configuration
  isGraphical ? false, # Whether this is a desktop system (with GUI) or server
  isNvidia ? false, # Whether this is a system with an Nvidia GPU
}:
let
  # Access to nixpkgs lib
  lib = inputs.nixpkgs.lib;

  # Common modules for all machines
  baseNixosModules = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nix-ros-overlay.nixosModules.default
    inputs.agenix.nixosModules.default
    ../system
    {
      networking.hostName = name;
    }
    # Home-manager configuration
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs system;
          host = { inherit name isGraphical; };
        }
        // homeSpecialArgs;

        users.${username} =
          { ... }:
          {
            imports = homeModules ++ [ ../home ];
            # Set a reasonable default
            home.stateVersion = "25.05";
          };
      };
    }
  ]
  ++ (
    if builtins.pathExists ../hardware-configuration.nix then [ ../hardware-configuration.nix ] else [ ]
  );

  # Automatically include the host's default.nix file
  hostDefaultModule =
    if builtins.pathExists ../hosts/${name}/default.nix then [ ../hosts/${name}/default.nix ] else [ ];

  # Combine base modules with machine-specific modules and host default module
  # Flatten the list to remove any nested lists from optionals
  allModules = lib.flatten (baseNixosModules ++ hostDefaultModule ++ nixosModules);

  # Machine-specific special arguments
  allSpecialArgs = {
    inherit inputs system;
    host = { inherit name isGraphical isNvidia; };
  }
  // extraSpecialArgs;
in
{
  # NixOS configuration
  nixosConfig = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = allSpecialArgs;
    modules = allModules;
  };
}
