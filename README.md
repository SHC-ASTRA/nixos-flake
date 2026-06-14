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

### Software Prerequisites 

You must have the [Nix](https://nixos.org/download/) package manager installed to work
on this repository. I recommend using the multi-user install script. If you are on a
system with SELinux, you must either disable enforcement (not recommended) or use your
system's package manager if available to install Nix.

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

1. Pick a host.[^1]
2. Pick the target disk.[^2]
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

## Footnotes

[^1]: The hosts are as follows:
  - `antenna`: The Latte Panda Delta 3 installed within the Tracking Antenna.
  - `clucky`: The Intel NUC installed within the main rover.
  - `deck`: The Valve Steam Deck used with basestation.
  - `panda`: The Latte Panda Delta 3 installed within basestation.
  - `testbed`: The Intel NUC installed within the testing rover.

[^2]: Linux references disks by their block device file which lives in `/dev`. Each
  block device file's name starts with a string corresponding to the type. For example:
  NVME device files start with `/dev/nvme`, SATA and USB device files start with
  `/dev/sd`, and eMMC device files (like on the Pandas) start with `/dev/mmcblk`.

  You can list all available block device files with `sudo fdisk -l`.

  After the type, you will find the device index. This index changes based on the
  order the kernel finds the device. For NVME and eMMC devices, the index is a number
  and for `sd-bus` devices (SATA and USB), the index is a letter. Additionally, NVME
  devices have an additional number that denotes their name, but it is rare to see
  anything other than `n1`. Finally, if the device file you're looking at is for a
  partition, it will have `pX` at the end, where X is a number`.

  Here are some example block device files names:

  - `/dev/nvme0n1` - NVME device. This is what you will select for the installer on
    `deck`.
  - `/dev/nvme0n1p1` - NVME device partition. Do not select this as it is a partition,
    not the whole device!
  - `/dev/mmcblk0` - eMMC device. This is what you will select for `antenna` or
    `panda`.
  - `/dev/sdb` - SATA or USB device. This could either be the SATA SSD inside of one of
    the NUCs, or it could be your installer USB. Double check the size with
    `sudo fdisk -l`.
  - `/dev/sda` - Another candidate for either of the NUCs' SSDs.
  - `/dev/sdb2` - Another partition file. Do not select this!
