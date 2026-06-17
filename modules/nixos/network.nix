{
  pkgs,
  lib,
  config,
  ...
}:
let
  uahNetworks = {
    "Student5" = "Go Chargers!";
    "Staff5" = "Where is the coffee?";
    "Faculty5" = "You will be tested";
  };
  mkPsk = passphrase: ''
    [Security]
    Passphrase=${passphrase}
  '';
in
{
  environment.systemPackages = with pkgs; [
    xorg.xauth # required for x forwarding to configure security
    impala # iwd TUI
  ];

  # hardcoded UAH wifi PSKs go into /var/lib/iwd at activation
  environment.etc = lib.mapAttrs' (ssid: passphrase: {
    name = "iwd/${ssid}.psk";
    value = {
      text = mkPsk passphrase;
      mode = "0600";
    };
  }) uahNetworks;

  system.activationScripts.iwd-networks.text = ''
    install -d -m 0700 /var/lib/iwd
    install -m 0600 /etc/iwd/*.psk /var/lib/iwd/
  '';

  systemd.network.enable = true;

  networking = {
    # use systemd-networkd and iwd
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

    firewall.enable = false;
  };

  systemd.network.networks = {
    # any ethernet interface gets the devices assigned IP on the ASTRA LAN
    "20-astra-lan" = {
      matchConfig = {
        Type = "ether";
        Kind = "!*"; # skip bridges/bonds/etc
      };
      address = [ "${config.astra.hosts.${config.networking.hostName}.ip}/24" ];
      networkConfig.DHCP = "no";
      linkConfig.RequiredForOnline = "no";
    };
    "40-wireless" = {
      matchConfig.Type = "wlan";
      networkConfig.DHCP = "yes";
    };
    "30-can" = {
      matchConfig.Name = "can*";
      canConfig.BitRate = "1M";
      linkConfig.RequiredForOnline = "no";
    };
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
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
      addresses = true;
    };
  };

}
