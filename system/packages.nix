{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # System
    gh
    socat
    usbutils
    silver-searcher
    wl-clipboard

    # Programming
    micro
    nil
    nixd
    neovim
    ripgrep
    nixfmt-rfc-style
    tmux

    # Build stuff
    gcc
    colcon
    gnumake
    python312Packages.pyserial
  ];
}
