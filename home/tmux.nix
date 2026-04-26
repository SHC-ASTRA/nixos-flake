{ pkgs, ... }:
{
  programs.tmux.enable = true;

  programs.tmux = {
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
}
