{ pkgs, lib, ... }:
{
  programs.zsh.enable = true;

  # Addl. plugins
  home.packages = with pkgs; [
    zsh-nix-shell
  ];

  # Shell
  programs.zsh = {
    enableCompletion = true;
    enableVteIntegration = true;
    autocd = false;
    autosuggestion.enable = true;
    defaultKeymap = "viins";
    history = {
      append = true;
      expireDuplicatesFirst = true;
      extended = true;
      ignoreSpace = true;
      share = true;
    };
    historySubstringSearch.enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "brackets"
      ];
    };

    initContent =
      let
        zshConfig =
          lib.mkOrder 1000 # sh
            ''
              # Exit shell on Ctrl+D even if the command line is filled
              exit_zsh() { exit }
              zle -N exit_zsh
              bindkey '^D' exit_zsh

              bindkey -v
              bindkey '^R' history-incremental-search-backward

              # oh-my-zsh/directories defines these for some reason
              unalias md
              unalias rd
            '';
        zshConfigAfter =
          lib.mkOrder 1500 # sh
            ''
              # All following is ran after oh-my-zsh

              # Ctrl+D exits terminal even when typing command
              exit_zsh() { exit }
              zle -N exit_zsh
              bindkey '^D' exit_zsh

              # Command completions
              if command -v register-python-argcomplete >/dev/null 2>&1; then
                  eval "$(register-python-argcomplete ros2)"
                  eval "$(register-python-argcomplete colcon)"
              fi
            '';
      in
      lib.mkMerge [
        zshConfig
        zshConfigAfter
      ];

    localVariables = {
      HYPHEN_INSENSITIVE = "true";
      ZLE_RPROMPT_INDENT = 0;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "colored-man-pages"
        "colorize"
        "command-not-found"
        "copyfile"
        "ssh"
        "safe-paste"
        "gitignore"
        "copybuffer"
        "direnv"
      ];
    };

    plugins = [
      {
        name = "zsh-nix-shell";
        src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell/";
        file = "nix-shell.plugin.zsh";
      }
    ];

    # The following option was added in 25.11
    # setOptions = [
    #   "INTERACTIVE_COMMENTS"
    # ];

  };

  # Direnv
  xdg.configFile."direnv/direnv.toml".text = ''
    # https://esham.io/2023/10/direnv
    [global]
    log_format = "\u001B[2mdirenv: %s\u001B[0m"
    hide_env_diff = true
  '';

}
