{
  pkgs,
  osConfig,
  lib,
  ...
}:
{
  config = lib.mkIf osConfig.astra.role.basestation.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = "FiraCode Nerd Font";
        package = pkgs.nerd-fonts.fira-code;
      };
    };
  };
}
