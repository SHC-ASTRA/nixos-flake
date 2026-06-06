{ osConfig, lib, ... }:
let
  mkHostBlocks = name: cfg: {
    "${name}" = {
      hostname = cfg.ip;
      user = "astra";
    };
    "${name}.local" = {
      hostname = "${name}.local";
      user = "astra";
    };
  };

  hostBlocks = lib.concatMapAttrs mkHostBlocks osConfig.astra.hosts;
in
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
    }
    // hostBlocks;
  };
}
