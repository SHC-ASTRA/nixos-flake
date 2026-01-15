# ASTRA NixOS Flake

[NixOS](https://nixos.org) configuration for ASTRA's computers.

## Software Prerequisites

You must have [NixOS](https://nixos.org) installed to use this repository.

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
> These instructions will overwrite your current system configuration with
> the ASTRA one. Only use on a system where you're sure this is okay!

First, connect to wifi and prepare the system for setup.

```bash
# take ownership of the installation path
sudo chown -R $USER /etc/nixos

# remove existing system config
rm -rf /etc/nixos/*

# clone flake to correct path
# we need to use nix-shell here because new systems do not have git installed.
nix-shell -p git --run 'git clone https://github.com/SHC-ASTRA/flake.git /etc/nixos'
```

Second, modify the flake to match your installation. Depending on which system
you're installing on, you'll need to select the correct hostname. Replace
`${hostname}` with the one you select. Here's the list:

- Tracking Antenna: `antenna`
- Clucky: `clucky`
- Steam Deck: `deck`
- Base Station Panda: `panda`
- Testbed: `testbed`

```bash
# generate the hardware configuration and copy it to the right host
nixos-generate-config
mv /etc/nixos/hardware-configuration.nix /etc/nixos/hosts/${hostname}/hardware.nix
```

Third, actually install the flake.

```bash
# rebuild the system, selecting the new hostname
sudo nixos-rebuild switch --flake /etc/nixos/#${hostname}
```

Fourth, reboot and if all went well you should have the system configuration!

> [!NOTE]
> The `astra` user will be created if it doesn't already exist, and the
> hostname will be updated to the one you specified.

You'll also need to rekey the agenix secrets. Instructions for doing so can be
found in [`system/secrets/README.md`](./system/secrets/README.md).

### Testing the Flake

If you're on a non-ASTRA system and you just want to see if it would build, you
can do the following:

```bash
# navigate to wherever you cloned the repo
cd path/to/flake/

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

## Channels

The configured channels can be seen in [`flake.nix`](./flake.nix).

- `nix-ros-overlay`: ROS2
- `nixpkgs`: Main set of packages.
- `hardware`: Hardware-specific configuration, especially for NVIDIA drivers.
- `home-manager`: Manage user-level configurations.
- `basestation-cameras`: Gstreamer cameras app.
- `agenix`: Encrypted secrets management.

## Rationale

Using NixOS lets us ensure we have the same configuration between our various
machines, without having to worry about accumulating state that might cause
differences in the field. This gives us the ability to confidently test on
Testbed and then ship to Clucky without having to worry if some package or
setting might be missing from one of them, and to ensure the experience between
the Steam Deck and the Panda in the Base Station chassis are the same.
