{
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  astra-install = pkgs.writeShellApplication {
    name = "astra-install";
    runtimeInputs = with pkgs; [
      util-linux
      disko
      nixos-install-tools
      git
    ];
    text = builtins.readFile ./astra-install.sh;
  };
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../nixos/wifi.nix
  ];

  image.baseName = lib.mkForce "astra-installer";

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
