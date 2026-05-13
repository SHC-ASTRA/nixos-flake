{ hosts, pkgs, ... }:
let
  device = "/dev/serial/by-id/usb-STMicroelectronics_STM32_Virtual_ComPort_206438A93430-if00";

  addr = hosts.antenna.ip;
  port = "14550";

  mavproxy-device-check = pkgs.writeShellScript "mavproxy-device-check" ''
    set -eu
    while [[ ! -e ${device} ]]; do
      sleep 3
    done
  '';

  start-mavproxy = pkgs.writeShellScript "start-mavproxy" ''
    set -eu
    cd /home/astra
    echo "binding to: ${addr}:${port}/udp"
    export PYTHONPATH="${pkgs.python312Packages.future}/${pkgs.python312.sitePackages}:''${PYTHONPATH:-}"
    exec ${pkgs.mavproxy}/bin/mavproxy.py --non-interactive --master=${device} --out ${addr}:${port}
  '';
in
{
  systemd.user.services.mavproxy = {
    enable = true;
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStartPre = "${mavproxy-device-check}";
      ExecStart = "${start-mavproxy}";
      Restart = "always";
      RestartSec = 10;
    };
  };

  networking.firewall.allowedTCPPorts = [
    14550
  ];
}
