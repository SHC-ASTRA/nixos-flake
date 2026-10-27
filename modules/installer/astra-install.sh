#!/usr/bin/env bash
set -euo pipefail

HOSTS=(antenna clucky deck panda testbed)
# the platform each host runs, in the same order as HOSTS. clucky is a Jetson AGX Orin;
#   everything else is on x86.
HOST_SYSTEMS=(x86_64-linux aarch64-linux x86_64-linux x86_64-linux x86_64-linux)

# the platform of the ISO this script is running from, substituted in by
# modules/installer/default.nix. nixos-install builds the system on the machine running
# it, so an ISO can only provision hosts that share its architecture.
ISO_SYSTEM="@astraSystem@"

# the flake source and revision this ISO was built from, substituted in by
# modules/installer/default.nix. installing from the copy on the ISO rather than from
# github means the installer provisions exactly the code it shipped with, even if that
# revision was never pushed.
BUILD_SRC="@astraSrc@"
BUILD_REF="@astraRef@"

FLAKE_REF="${ASTRA_FLAKE_REF:-$BUILD_SRC}"
GIT_URL="${ASTRA_GIT_URL:-https://github.com/SHC-ASTRA/nixos-flake.git}"
GIT_REF="${ASTRA_GIT_REF:-$BUILD_REF}"

while [[ $# -gt 0 ]]; do
  case "$1" in
  --flake)
    FLAKE_REF="$2"
    shift 2
    ;;
  --git-url)
    GIT_URL="$2"
    shift 2
    ;;
  --git-ref)
    GIT_REF="$2"
    shift 2
    ;;
  -h | --help)
    cat <<EOF
Usage: astra-install [--flake <flake-ref>] [--git-url <url>] [--git-ref <branch>]

Installs an ASTRA host onto the selected disk and clones the flake source
into /etc/nixos so future \`nixos-rebuild\`s work out of the box.

  --flake <ref>     Flake reference to install from (default: $FLAKE_REF).
                    Set ASTRA_FLAKE_REF to override the default.
  --git-url <url>   Git URL to clone into /etc/nixos (default: $GIT_URL).
                    Set ASTRA_GIT_URL to override the default.
  --git-ref <ref>   Git branch/tag/sha to check out (default: $GIT_REF).
                    Set ASTRA_GIT_REF to override the default.

This installer ISO was built from $FLAKE_REF
EOF
    exit 0
    ;;
  *)
    echo "unknown argument: $1" >&2
    exit 2
    ;;
  esac
done

echo "ASTRA installer"
echo "  built from: $BUILD_REF"
echo "  platform: $ISO_SYSTEM"
echo "  flake:   $FLAKE_REF"
echo "  git url: $GIT_URL"
echo "  git ref: $GIT_REF"
echo
echo "select a host:"
for i in "${!HOSTS[@]}"; do
  printf "  %d) %s\n" $((i + 1)) "${HOSTS[$i]}"
done
echo

read -rp "host number: " host_index
if ! [[ $host_index =~ ^[0-9]+$ ]] || ((host_index < 1)) || ((host_index > ${#HOSTS[@]})); then
  echo "invalid choice" >&2
  exit 1
fi
HOST="${HOSTS[$((host_index - 1))]}"
HOST_SYSTEM="${HOST_SYSTEMS[$((host_index - 1))]}"
echo "selected host: $HOST"

if [[ $HOST_SYSTEM != "$ISO_SYSTEM" ]]; then
  echo "$HOST is $HOST_SYSTEM but this ISO is $ISO_SYSTEM." >&2
  echo "boot the $HOST_SYSTEM installer instead (nix build .#packages.$HOST_SYSTEM.installer)." >&2
  exit 1
fi
echo

echo "available devices:"
lsblk -dno NAME,SIZE,MODEL
echo

read -rp "target disk [/dev/nvme0n1]: " DEVICE
DEVICE="${DEVICE:-/dev/nvme0n1}"

if [[ ! -b $DEVICE ]]; then
  echo "$DEVICE is not a block device" >&2
  exit 1
fi

echo
echo "about to erase $DEVICE and install $HOST from $FLAKE_REF."
lsblk "$DEVICE"
echo
read -rp "type 'yes' to continue: " confirm
if [[ $confirm != "yes" ]]; then
  echo "aborted"
  exit 1
fi

echo
echo "==> partitioning $DEVICE with disko..."
sudo disko \
  --mode disko \
  --flake "${FLAKE_REF}#standard" \
  --arg device "\"$DEVICE\""

echo
echo "==> installing NixOS for host $HOST..."
sudo nixos-install \
  --flake "${FLAKE_REF}#${HOST}" \
  --no-root-passwd

echo
echo "==> populating /mnt/etc/nixos..."
sudo rm -rf /mnt/etc/nixos

# prefer a real clone so future updates can just be `git pull`. checkout rather than
# `clone --branch` so that a bare commit sha works too.
if sudo git clone "$GIT_URL" /mnt/etc/nixos &&
  sudo git -C /mnt/etc/nixos checkout "$GIT_REF"; then
  echo "checked out $GIT_REF from $GIT_URL"
else
  # offline, or $GIT_REF was never pushed. fall back to the source on the ISO so
  # /etc/nixos always matches the system we just installed.
  echo "could not check out $GIT_REF from $GIT_URL, using the copy on this ISO" >&2
  sudo rm -rf /mnt/etc/nixos
  sudo cp -rT "$BUILD_SRC" /mnt/etc/nixos
  # the source came from the read-only nix store
  sudo chmod -R u+w /mnt/etc/nixos
  echo "note: /etc/nixos is a plain copy, not a git checkout. to get history back," >&2
  echo "      push $BUILD_REF and re-clone $GIT_URL over it." >&2
fi

echo
read -rp "install complete. reboot? [y/N]: " reboot_now
if [[ $reboot_now =~ ^[Yy]$ ]]; then
  sudo reboot
fi
