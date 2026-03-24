{ den, ... }:
{
  den.aspects.system_minimal = {
    includes = [
      den.aspects.localization
      den.aspects.systemd
      den.aspects.network
      den.aspects.ssh
    ];
  };
}
