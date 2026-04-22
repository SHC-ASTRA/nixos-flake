{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      nil
    ];

    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  programs = {
    git.settings.core.editor = "nvim";

    neovim = {
      enable = true;
      defaultEditor = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      plugins = with pkgs.vimPlugins; [
        # web
        coc-html

        # python
        coc-pyright

        # other
        coc-sh
        coc-json
        coc-docker
        coc-git
      ];

      coc = {
        enable = true;
        settings = {
          languageserver = {
            nix = {
              command = "nil";
              args = [ ];
              filetypes = [ "nix" ];
            };
          };
          coc.preferences.formatOnType = true;
        };
      };
    };
  };
}
