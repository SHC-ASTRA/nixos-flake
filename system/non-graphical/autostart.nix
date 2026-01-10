{ ... }:
{
  systemd.user.services = {
    anchor = {
      enable = true;
      description = "Anchor nodes for controlling the rover and its modules (rover-ros2)";
      after = [ "systemd-user-sessions.service" ];
      requires = [ "systemd-user-sessions.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "~/rover-ros2/auto_start/auto_start_anchor.sh";
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
      after = [ "systemd-user-sessions.service" ];
      requires = [ "systemd-user-sessions.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "~/rover-ros2/auto_start/start_rosbag.sh";
        Restart = "always";
        RestartSec = 5;
        Environment = ''
          PYTHONUNBUFFERED=1
        '';
      };
    };
    core_headless = {
      enable = true;
      description = "Autostart headless core node for controlling the rover without a base station";
      after = [ "systemd-user-sessions.service" ];
      requires = [ "systemd-user-sessions.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "~/rover-ros2/auto_start/auto_start_core_headless.sh";
        Restart = "always";
        RestartSec = 10;
        Environment = ''
          PYTHONUNBUFFERED=1
        '';
      };
    };
    headless_full = {
      enable = true;
      description = "Headless node to control Core and Arm";
      after = [ "systemd-user-sessions.service" ];
      requires = [ "systemd-user-sessions.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "~/rover-ros2/auto_start/auto_start_headless_full.sh";
        Restart = "always";
        RestartSec = 10;
        Environment = ''
          PYTHONUNBUFFERED=1
        '';
      };
    };
  };
}
