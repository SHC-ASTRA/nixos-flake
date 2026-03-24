{ den, ... }:
{
  den.aspects.system_desktop = {
    includes = [
      den.aspects.system_minimal
      den.aspects.gnome
      den.aspects.gdm
    ];
  };
}
