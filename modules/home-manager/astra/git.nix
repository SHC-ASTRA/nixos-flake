{ ... }:
{
  programs = {
    git = {
      enable = true;
      settings = {
        commit.gpgsign = true;
        gpg.format = "ssh";
        user = {
          signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbYdXIBnBm/Rkc55UKnfhGWxgZkz5khrd4rcYkw4Dl+";
          email = "90978381+ASTRA-SHC@users.noreply.github.com";
          name = "SHC-ASTRA";
        };
        init.defaultBranch = "main";
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = false;
    };
  };
}
