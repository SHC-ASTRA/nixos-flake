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
                  # disabling time tracking can save a bit of storage and cpu time
                  "noatime" # disable access time tracking
                  "noctime" # disable create time tracking
                  "nomtime" # disable modify time tracking
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
