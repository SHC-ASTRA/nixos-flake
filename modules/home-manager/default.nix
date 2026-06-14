{ inputs, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.astra = {
      imports = [ ./astra ];
      home.stateVersion = "25.05";
    };
  };
}
