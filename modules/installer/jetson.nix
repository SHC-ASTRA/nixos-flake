# turns the ASTRA installer ISO into one that boots on clucky's Jetson Orin.
{ lib, ... }:
{
  imports = [
    # same SOM and carrier as the installed system, so the ISO runs the kernel and
    #   device tree clucky will end up with
    ../hardware/clucky/jetpack.nix
  ];

  # small mountain of x86 drivers we don't need so that initrd doesn't explode
  hardware.enableAllHardware = lib.mkForce false;
}
