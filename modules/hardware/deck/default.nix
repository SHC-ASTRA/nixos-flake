{ ... }:
{
  imports = [
    ../common
    ../common/cpu-amd.nix
    ../../disko
  ];

  networking.hostName = "deck";
  astra.role.basestation.enable = true;

  # provides Steam Deck controller drivers and on-screen keyboard
  programs.steam.enable = true;

  # sets the bootloader to horizontal (Steam Decks have weird screens)
  boot.loader.systemd-boot.consoleMode = "5";
}
