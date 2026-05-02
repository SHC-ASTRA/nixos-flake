{ pkgs, host, ... }:
{
  programs.kitty = {
    enable = host.isGraphical;
    font = {
      name = "FiraCode Nerd Font";
      package = pkgs.nerd-fonts.fira-code;
    };
  };
}
