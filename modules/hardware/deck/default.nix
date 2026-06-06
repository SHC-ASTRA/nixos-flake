{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./network.nix
  ];

  networking.hostName = "deck";
  astra.role.basestation.enable = true;

  environment.systemPackages = with pkgs; [
    zed-editor
  ];
}
