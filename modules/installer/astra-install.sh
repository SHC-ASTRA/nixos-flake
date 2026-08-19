#!/usr/bin/env bash
set -euo pipefail

HOSTS=(antenna clucky deck panda testbed)
FLAKE_REF="${ASTRA_FLAKE_REF:-github:SHC-ASTRA/nixos-flake}"
GIT_URL="${ASTRA_GIT_URL:-https://github.com/SHC-ASTRA/nixos-flake.git}"
GIT_REF="${ASTRA_GIT_REF:-main}"

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
echo "selected host: $HOST"
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
echo "==> cloning $GIT_URL ($GIT_REF) into /mnt/etc/nixos..."
sudo rm -rf /mnt/etc/nixos
sudo git clone --branch "$GIT_REF" "$GIT_URL" /mnt/etc/nixos

echo
read -rp "install complete. reboot? [y/N]: " reboot_now
if [[ $reboot_now =~ ^[Yy]$ ]]; then
  sudo reboot
fi
