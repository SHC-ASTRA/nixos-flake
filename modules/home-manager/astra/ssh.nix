{ osConfig, ... }:
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
        hostname = osConfig.astra.hosts.clucky.ip;
        user = "astra";
      };
      "testbed" = {
        hostname = osConfig.astra.hosts.testbed.ip;
        user = "astra";
      };
      "deck" = {
        hostname = osConfig.astra.hosts.deck.ip;
        user = "astra";
      };
      "panda" = {
        hostname = osConfig.astra.hosts.panda.ip;
        user = "astra";
      };
      "antenna" = {
        hostname = osConfig.astra.hosts.antenna.ip;
        user = "astra";
      };
    };
  };
}
