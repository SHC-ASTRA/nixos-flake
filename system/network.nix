{ pkgs, ... }:
{
  environment.systemPackages = with pkgs.xorg; [
    xauth # required for x forwarding to configure security
  ];
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
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
      addresses = true;
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", KERNEL=="can*", \
      RUN+="${pkgs.iproute2}/bin/ip link set %k type can bitrate 1000000", \
      RUN+="${pkgs.iproute2}/bin/ip link set up %k"
  '';
}
