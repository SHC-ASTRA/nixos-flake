# ASTRA NixOS Flake

[NixOS](https://nixos.org) configuration for ASTRA's computers.

## Contents

- [Home Manager config `./home/`](./home/)
- [Device-specific config `./hosts/`](./hosts/)
  - [Tracking Antenna `./hosts/antenna/`](./hosts/antenna/)
  - [Clucky `./hosts/clucky/`](./hosts/clucky/)
  - [Steam Deck `./hosts/deck/`](./hosts/deck/)
  - [Base Station Panda `./hosts/panda/`](./hosts/panda/)
  - [Testbed `./hosts/testbed/`](./hosts/testbed/)
- [Global system config `./system/`](./system/)
  - [Graphical system config `./system/graphical/`](./graphical/graphical/)
  - [Encrypted secrets `./system/secrets/`](./system/secrets/)

## Usage

> [!IMPORTANT]
> Slow down! Read through the instructions for what you're doing before you
> start doing it. You can't simply copy commands one-for-one!

### Updating Flake

Grab the latest changes.

```bash
# navigate to the installation location
cd /etc/nixos

# pull the latest changes
git pull
```

If you want to update the system configuration and apply it now, do this:

```bash
sudo nixos-rebuild switch
```

If you would rather apply it on the next boot, do this instead:

```bash
sudo nixos-rebuild boot
```

### Apply Flake on New Installation

> [!CAUTION]
> The installer erases the selected disk. Only run it on a system where this
> is okay.

First, either download the latest ISO from the [actions page](https://github.com/SHC-ASTRA/nixos-flake/actions?query=workflow%3A%22Build+installer+ISO%22+is%3Asuccess+branch%3Amain)
or build it with the following command:

```bash
nix build .#installer
```

The image will end up at `./result/iso/astra-installer-*.iso` after you build it.

Write the image to a USB flash drive that is >=2GB using your favorite flashing
software. I recommend [balenaEtcher](https://etcher.balena.io/) or the `dd` command.

Once booted, run the installer and follow the prompts:

```bash
astra-install
```

You will be asked to:

1. Pick a host (`antenna`, `clucky`, `deck`, `panda`, `testbed`).
2. Pick the target disk.
3. Confirm.

The installer partitions the disk with the ASTRA layout, mounts it, and runs
`nixos-install` for the chosen host. After it finishes, reboot when prompted.

### Testing the Flake

If you're on a non-ASTRA system and you just want to see if it would build, you
can do the following:

```bash
# navigate to wherever you cloned the repo
cd path/to/flake/

# check if the flake is valid
nix flake check

# attempt to build the flake
nixos-rebuild build --flake .#${hostname}
```
If you're on an ASTRA system and you want to see if the configuration works
without adding it to the bootloader, you can do this instead:

```bash
sudo nixos-rebuild test
```

This will rebuild your current hostname's flake and activate the configuration,
but not persist it across reboots.

## Channels

The configured channels can be seen in [`flake.nix`](./flake.nix).

- `nix-ros-overlay`: ROS2
- `nixpkgs`: Main set of packages.
- `hardware`: Hardware-specific configuration, especially for NVIDIA drivers.
- `disko`: Declarative drive partitioning.
- `home-manager`: Manage user-level configurations.
- `basestation-cameras`: Gstreamer cameras app.
- `agenix`: Encrypted secrets management.
- `vscode-server`: Patches VSCode Server to work on NixOS.
- `treefmt-nix`: Formats the project.

## Rationale

Using NixOS lets us ensure we have the same configuration between our various
machines, without having to worry about accumulating state that might cause
differences in the field. This gives us the ability to confidently test on
Testbed and then ship to Clucky without having to worry if some package or
setting might be missing from one of them, and to ensure the experience between
the Steam Deck and the Panda in the Base Station chassis are the same.
