{
  pkgs,
  inputs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.astra.role.basestation.enable {
    environment.systemPackages =
      with pkgs;
      [
        # Apps
        vlc
        mpv
        kitty
        nautilus
        keepassxc
        vscode-fhs # Needed for basestation-classic
        gnome-keyring
        zed-editor

        # GStreamer
        gst_all_1.gstreamer
        # Common plugins like "filesrc" to combine within e.g. gst-launch
        gst_all_1.gst-plugins-base
        # Specialized plugins separated by quality
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        # Plugins to reuse ffmpeg to play almost every video format
        gst_all_1.gst-libav
        # Support the Video Audio (Hardware) Acceleration API
        gst_all_1.gst-vaapi
      ]
      ++ (with inputs.basestation-cameras.packages.${pkgs.system}; [
        default
        launch-cameras
      ]);
  };
}
