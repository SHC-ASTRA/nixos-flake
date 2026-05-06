{ pkgs, ... }:
let
  device = "/dev/serial/by-id/usb-STMicroelectronics_STM32_Virtual_ComPort_206438A93430-if00";
in
{
  systemd.user.services.mavproxy = {
    enable = true;
    after = [ "default.target" ];
    requires = [ "default.target" ];
    wantedBy = [ "default.target" ];

    serviceConfig = {
      ExecStart = ''
        bash -c "
                while [[ ! -e ${device} ]]; do
        	  sleep 10
        	done

                export PYTHONPATH="${pkgs.python312Packages.future}/${pkgs.python312.sitePackages}:''$PYTHONPATH"
        	${pkgs.mavproxy}/bin/mavproxy.py
              "'';
      Restart = "always";
      RestartSec = 10;

    };
  };
}
