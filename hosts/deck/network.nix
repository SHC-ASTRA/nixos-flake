{ hosts, ... }:
{
  networking.interfaces."enp4s0f3u1u3c2" = {
    ipv4.addresses = [
      {
        address = hosts.deck.ip;
        prefixLength = 24;
      }
    ];
  };

  services.create_ap = {
    enable = true;
    settings = {
      INTERNET_IFACE = "enp4s0f3u1u3c2";
      WIFI_IFACE = "wlo1";
      PASSPHRASE = "spaceiscool639";
      SSID = "ASTRA-BASESTATION";
    };
  };
}
