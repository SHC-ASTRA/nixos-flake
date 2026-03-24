{
  den.aspects.network = {
    nixos = {
      networking = {
        networkmanager.enable = true;
        firewall.enable = false;
      };
    };
  };
}
