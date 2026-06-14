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
    ];
    text = builtins.readFile ./astra-install.sh;
  };
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  image.baseName = lib.mkForce "astra-installer";

  boot.kernelParams = [
    "console=ttyS0,115200"
    "console=tty1"
  ];

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

  environment.etc."motd".text = ''

    ASTRA installer

    Run `astra-install` to provision this machine.

  '';

  users.users.root.openssh.authorizedKeys.keys = import ../nixos/agenix/authorized_keys.nix;
}
