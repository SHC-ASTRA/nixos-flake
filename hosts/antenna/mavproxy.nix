{ pkgs, ... }:
let
  device = "/dev/serial/by-id/usb-STMicroelectronics_STM32_Virtual_ComPort_206438A93430-if00";

  start-mavproxy = pkgs.writeShellScript "start-mavproxy" ''
    set -eu
    while [ ! -e ${device} ]; do
      sleep 10
    done
    export PYTHONPATH="${pkgs.python312Packages.future}/${pkgs.python312.sitePackages}:''${PYTHONPATH:-}"
    exec ${pkgs.mavproxy}/bin/mavproxy.py --master=${device}
  '';
in
{
  systemd.user.services.mavproxy = {
    enable = true;
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${start-mavproxy}";
      Restart = "always";
      RestartSec = 10;
    };
  };
}
