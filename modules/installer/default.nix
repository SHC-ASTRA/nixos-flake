{
  inputs,
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  # flake source to be copied into the ISO
  astraSrc = inputs.self.outPath;

  # revision the source came from
  astraRef =
    if inputs.self ? rev then
      # if the source is clean, we can just use the revision
      inputs.self.rev
    else if inputs.self ? dirtyRev then
      # if the source is not clean, we have to remove the -dirty suffix
      lib.removeSuffix "-dirty" inputs.self.dirtyRev
    else
      # if there is no rev attribute (not a git repo for whatever reason, use main
      "main";

  astra-install = pkgs.writeShellApplication {
    name = "astra-install";
    runtimeInputs = with pkgs; [
      util-linux
      disko
      nixos-install-tools
      git
    ];
    # substitute in the source, the ref, and the architecture of this ISO
    text =
      builtins.replaceStrings
        [ "@astraSrc@" "@astraRef@" "@astraSystem@" ]
        [ astraSrc astraRef pkgs.stdenv.hostPlatform.system ]
        (builtins.readFile ./astra-install.sh);
  };
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../nixos/wifi.nix
  ];

  image.baseName = lib.mkForce "astra-installer-${pkgs.stdenv.hostPlatform.linuxArch}";

  # every host but clucky is x86. `modules/installer/jetson.nix` overrides this.
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # useful tools to have on a recovery / reinstall ISO
  environment.systemPackages = with pkgs; [
    astra-install
    disko
    git
    gnutar
    gptfdisk
    parted
    pciutils
    tmux
    util-linux
    usbutils
    vim
  ];

  services.openssh.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://ros.cachix.org"
      "https://attic.iid.ciirc.cvut.cz/ros"
    ];
    extra-trusted-public-keys = [
      "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
      "ros:JR95vUYsShSqfA1VTYoFt1Nz6uXasm5QrcOsGry9f6Q="
    ];
    trusted-users = [
      "root"
      "nixos"
    ];
  };

  services.getty.helpLine = lib.mkForce ''
    The "nixos" and "root" accounts have empty passwords.

    To log in over ssh as "root", use one of the team's authorized keys (these
    are already installed). To log in as "nixos" over ssh, set a password with
    `passwd` or add your public key to /home/nixos/.ssh/authorized_keys.

    To set up a wireless connection, run `impala`.

    To provision this machine, run `astra-install`.
  '';

  users.users.root.openssh.authorizedKeys.keys = import ../nixos/agenix/authorized_keys.nix;
}
