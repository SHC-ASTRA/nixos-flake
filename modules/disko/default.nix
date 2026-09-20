{
  device,
  ...
}:
{
  disko.devices.disk.main = {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          # boot partition
          priority = 1;
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              # this works out to 755 (u:rwx, g:r-x, o:r-x)
              "fmask=0022"
              "dmask=0022"
            ];
            extraArgs = [
              # sets the partition label
              "-n"
              "ASTRABOOT"
            ];
          };
        };
        root = {
          # root partition
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [
              # sets the partition label
              "-L"
              "ASTRAROOT"
              "-f"
              # the Jetson runs a 5.15 Tegra kernel, but mkfs.btrfs turns on
              #   block-group-tree by default as of btrfs-progs 6.19 and that feature
              #   needs kernel 6.1+. without this the installer formats a filesystem it
              #   cannot mount ("cannot mount read-write because of unsupported optional
              #   features (0x8)"). bgt only speeds up mount time, so it's not a big deal
              #   to turn it off everywhere (and keep the filesystems identical).
              "-O"
              "^block-group-tree"
            ];
            subvolumes = {
              "@" = {
                # main subvolume
                mountpoint = "/";
                mountOptions = [
                  "compress=zstd" # compress the filesystem
                  "noatime" # disable access time tracking (because who cares)
                ];
              };
              "@nix" = {
                # nix subvolume (incl store)
                mountpoint = "/nix";
                mountOptions = [
                  "compress=zstd" # compress the filesystem
                  "noatime" # disable access time tracking
                ];
              };
              "@home" = {
                # home subvolume
                mountpoint = "/home";
                mountOptions = [
                  "compress=zstd" # compress the filesystem
                  "noatime" # disable access time tracking
                ];
              };
              "@swap" = {
                # swapfile subvolume
                mountpoint = "/swap";
                swap.swapfile.size = "4G";
              };
            };
          };
        };
      };
    };
  };
}
