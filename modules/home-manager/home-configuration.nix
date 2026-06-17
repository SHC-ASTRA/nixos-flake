{
  pkgs,
  lib,
  osConfig,
  ...
}:
{
  home = {
    packages = with pkgs; [
      nil
      zsh-nix-shell
    ];

    sessionVariables = {
      EDITOR = "nvim";
    };

    shell.enableBashIntegration = true;
  };

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = {
        la = "ls -alh";
        neofetch = "fastfetch";
      };
      profileExtra = ''
        eval `ssh-agent`
        [[ -e ~/.ssh/id_ed25519 ]] && ssh-add ~/.ssh/id_ed25519 &> /dev/null
      '';
    };

    bat.enable = true;

    pay-respects.enable = true;

    eza = {
      enable = true;
      colors = "auto";
      icons = "auto";
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

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
        core.editor = "nvim";
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = false;
    };

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

    ssh =
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

    starship = {
      enable = true;
      enableBashIntegration = true;
      settings = {

      };
    };

    tmux = {
      enable = true;
      clock24 = true;
      historyLimit = 5000;
      mouse = true;
      secureSocket = false;

      plugins = with pkgs; [
        tmuxPlugins.resurrect
      ];

      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "screen-256color";
    };

    zsh = {
      enable = true;
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

      setOptions = [
        "INTERACTIVE_COMMENTS"
      ];
    };

    firefox = lib.mkIf osConfig.astra.role.basestation.enable {
      enable = true;

      nativeMessagingHosts = [ pkgs.firefoxpwa ];

      policies = {
        AutoFillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = true;
        DisableSetDesktopBackground = true;

        SearchEngines = {
          Add = [
            {
              "Name" = "Unduck";
              "URLTemplate" = "https://s.dunkirk.sh?q={searchTerms}";
              "Method" = "GET";
              "IconURL" = "https://s.dunkirk.sh/favicon.ico";
              "Alias" = "undk";
              "Description" = "ddg bangs pwa";
            }
          ];
          Default = "Unduck";
          PreventInstalls = true;
        };

        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "addon@darkreader.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            installation_mode = "force_installed";
          };
          "keepassxc-browser@keepassxc.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc_browser/latest.xpi";
            installation_mode = "force_installed";
          };
        };

        Preferences =
          let
            lock-false = {
              Value = false;
              Status = "locked";
            };
            lock-true = {
              Value = true;
              Status = "locked";
            };
          in
          {
            "browser.warnOnQuitShortcut" = lock-false;
            "browser.ctrlTab.sortByRecentlyUsed" = lock-true;
            "browser.newtabpage.activity-stream.trendingSearch.defaultSearchEngine" = {
              "Value" = "Unduck";
              "Status" = "locked";
            };
            "browser.urlbar.suggest.clipboard" = lock-false;

            "dom.security.https_only_mode" = lock-true;

            "layers.acceleration.disabled" = lock-true;
          };
      };
    };

    kitty = lib.mkIf osConfig.astra.role.basestation.enable {
      enable = true;
      font = {
        name = "FiraCode Nerd Font";
        package = pkgs.nerd-fonts.fira-code;
      };
    };
  };

  xdg.configFile."direnv/direnv.toml".text = ''
    # https://esham.io/2023/10/direnv
    [global]
    log_format = "\u001B[2mdirenv: %s\u001B[0m"
    hide_env_diff = true
  '';
}
