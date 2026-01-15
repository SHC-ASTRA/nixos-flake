{ ... }:
{
  systemd.user.services =
    let
      inShell = f: ''
        /bin/sh -c ". /etc/profile ; cd ~/rover-ros2 ; nix develop --command ${f}"
      '';
    in
    {
      anchor = {
        enable = true;
        description = "Anchor nodes for controlling the rover and its modules (rover-ros2)";
        after = [ "default.target" ];
        requires = [ "default.target" ];
        wantedBy = [ "default.target" ];

        serviceConfig = {
          ExecStart = inShell "~/rover-ros2/auto_start/auto_start_anchor.sh";
          Restart = "always";
          RestartSec = 5;
          Environment = ''
            PYTHONUNBUFFERED=1
          '';
        };
      };
      astra_rosbag = {
        enable = true;
        description = "Record a rosbag on boot to ~/bags/";
        after = [ "default.target" ];
        requires = [ "default.target" ];
        wantedBy = [ "default.target" ];

        serviceConfig = {
          ExecStart = inShell "~/rover-ros2/auto_start/start_rosbag.sh";
          Restart = "always";
          RestartSec = 5;
          Environment = ''
            PYTHONUNBUFFERED=1
          '';
        };
      };
      headless_full = {
        enable = true;
        description = "Headless node to control Core and Arm";
        after = [ "default.target" ];
        requires = [ "default.target" ];
        wantedBy = [ "default.target" ];

        serviceConfig = {
          ExecStart = inShell "~/rover-ros2/auto_start/auto_start_headless_full.sh";
          Restart = "always";
          RestartSec = 5;
          Environment = ''
            PYTHONUNBUFFERED=1
          '';
        };
      };
    };
}
