# this file provides wifi configurations for both our regular systems and our installer iso
{ lib, pkgs, ... }:
{
  # iwd handles wifi for us
  # we don't use NetworkManager because it is a pain to configure programatically. if you take a look below (in environment.etc) you can see how dummy easy
  #   it is to configure wifi networks with iwd. there is also a great TUI tool called impala that replaces nmtui.
  networking = {
    networkmanager.enable = lib.mkDefault false;
    # the minimal install CD turns wpa_supplicant on by default, force it off so it doesn't fight iwd over the radio
    wireless.enable = lib.mkForce false;

    wireless.iwd = {
      enable = true;
      settings = {
        IPv6.Enabled = true;
        Settings = {
          AutoConnect = true;
          # fixes some issues with wpa2
          ControlPortOverNL80211 = false;
        };
      };
    };
  };

  environment.systemPackages = [ pkgs.impala ]; # iwd TUI

  # dunno about you but i'm tired of putting in the same wifi password over and over.
  # iwd reads .psk files from /var/lib/iwd & wants files to be mode 0600 & owned by root,
  #   so we can't symlink to the store like i want to. instead we just make the files with
  #   an activation script.
  system.activationScripts.iwd-networks.text =
    let
      networks = {
        # uah non-eduroam networks
        "Student5" = "Go Chargers!";
        "Staff5" = "Where is the coffee?";
        "Faculty5" = "You will be tested";
      };
      writePsk = ssid: passphrase: ''
        install -m 0600 /dev/null /var/lib/iwd/${ssid}.psk
        cat > /var/lib/iwd/${ssid}.psk <<'EOF'
        [Security]
        Passphrase=${passphrase}
        EOF
      '';
    in
    ''
      install -d -m 0700 /var/lib/iwd
    ''
    + lib.concatStrings (lib.mapAttrsToList writePsk networks);
}
