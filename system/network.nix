{ ... }:
{
  networking = {
    networkmanager.enable = true;
    firewall.enable = false;
  };
  services.openssh = {
    enable = true;
    settings = {
      UseDns = true;
      PasswordAuthentication = true;
      PermitRootLogin = "no";
      X11Forwarding = true;
      X11UseLocalhost = true;
    };
  };
}
