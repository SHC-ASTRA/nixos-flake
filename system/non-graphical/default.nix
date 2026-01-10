{ ... }: {
  # no need to check here again because we check for !graphical in ../default.nix
  imports = [ ./autostart.nix ];
}
