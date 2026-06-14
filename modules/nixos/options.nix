{ lib, ... }:
{
  options.astra = {
    role = {
      rover.enable = lib.mkEnableOption "clucky and testbed";
      antenna.enable = lib.mkEnableOption "antenna";
      basestation.enable = lib.mkEnableOption "deck and panda";
    };

    hosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.ip = lib.mkOption { type = lib.types.str; };
        }
      );
      default = { };
      description = "Known astra hosts and their LAN IPs.";
    };
  };
}
