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
}
