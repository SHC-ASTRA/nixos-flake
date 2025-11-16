{ pkgs, hosts, ... }:
{
  environment.systemPackages = [
    pkgs.hostapd
  ];

  networking.interfaces."enp85s0" = {
    ipv4.addresses = [
      {
        address = hosts.testbed.ip;
        prefixLength = 24;
      }
    ];
  };

  services.hostapd = {
    enable = true;
    radios."wlp0s20fu6u4".networks."wlp0s20fu6u4" = {
      ssid = "testbed";
      apIsolate = false;
      authentication = {
        wpaPassword = "opticslabisclosed";
        mode = "wpa2-sha256";
      };
    };
  };
}
