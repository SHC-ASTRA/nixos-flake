{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  pkgs-2605 = inputs.nixpkgs-2605.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  config = lib.mkIf config.astra.role.basestation.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = pkgs-2605.hyprland;
      portalPackage = pkgs-2605.xdg-desktop-portal-hyprland;
    };

    hardware.graphics = {
      package = pkgs-2605.mesa;
      package32 = pkgs-2605.pkgsi686Linux.mesa;
    };

    services.greetd = {
      enable = true;
      settings.default_session.command = "${lib.getExe pkgs.tuigreet} --time --remember --cmd start-hyprland";
    };

    environment.systemPackages = with pkgs; [
      rofi
      mako
      pkgs-2605.hyprshot
      tesseract
      pkgs-2605.quickshell
    ];

    fonts.packages = with pkgs; [
      fira-code
      nerd-fonts.symbols-only
    ];

    systemd.packages = [ pkgs.hyprpolkitagent ];

    home-manager.users.astra = {
      xdg.configFile = {
        "hypr/hyprland.lua".source = ./hyprland.lua;
        "quickshell/bar".source = "${inputs.iggys-reasonable-shell}/bar";
      };

      home.pointerCursor = {
        enable = true;
        hyprcursor.enable = true;
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };
    };
  };
}
