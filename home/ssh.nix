{ hosts, ... }:
{
  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;
    extraConfig = ''
      PreferredAuthentications publickey,password
      IdentityFile /home/astra/.ssh/id_ed25519
    '';
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        forwardAgent = true;
        compression = true;
      };
      "git@github.com" = {
        hostname = "github.com";
        user = "git";
      };
      "clucky" = {
        hostname = hosts.clucky.ip;
        user = "astra";
      };
      "testbed" = {
        hostname = hosts.testbed.ip;
        user = "astra";
      };
      "deck" = {
        hostname = hosts.deck.ip;
        user = "astra";
      };
      "panda" = {
        hostname = hosts.panda.ip;
        user = "astra";
      };
      "antenna" = {
        hostname = hosts.antenna.ip;
        user = "astra";
      };
    };
  };
}
