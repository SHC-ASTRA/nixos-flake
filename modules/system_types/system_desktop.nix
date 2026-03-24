{ den, ... }:
{
  den.aspects.system_desktop = {
    includes = [
      den.aspects.system_minimal
      den.aspects.audio
      den.aspects.gnome
      den.aspects.gdm
    ];
  };
}
