{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.astra.role.antenna.enable {
    services.mediamtx = {
      enable = true;
      allowVideoAccess = true;

      settings = {
        logLevel = "info";
        logDestinations = [ "stdout" ];

        rtspAddress = ":8554";
        rtmp = false;
        hls = false;
        webrtc = false;
        srt = false;

        paths.cam = {
          runOnDemand = ''
            ${lib.getExe pkgs.ffmpeg} -nostdin -hide_banner \
              -f v4l2 -input_format mjpeg -framerate 30 -video_size 1920x1080 \
              -i /dev/video0 \
              -c:v libx264 -preset ultrafast -tune zerolatency -pix_fmt yuv420p \
              -g 60 -b:v 6M -maxrate 6M -bufsize 12M \
              -f rtsp -rtsp_transport tcp rtsp://localhost:$RTSP_PORT/$MTX_PATH
          '';
          runOnDemandRestart = true;
          runOnDemandCloseAfter = "10s";
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ 8554 ]; # rtsp
      allowedUDPPortRanges = [
        { # mediamtx
          from = 8000;
          to = 8001;
        }
      ];
    };
  };
}
