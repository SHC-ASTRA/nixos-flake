{ osConfig, lib, ... }:
let
  # map hostname -> ip for the ssh config
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
    # have it try the public key before prompting for a password
    # define the default public key
    extraConfig = ''
      PreferredAuthentications publickey,password
      IdentityFile /home/astra/.ssh/id_ed25519
    '';
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        forwardAgent = true; # useful for ssh-in-ssh
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
