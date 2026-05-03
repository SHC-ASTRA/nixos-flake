{ ... }:
{
  home.file.".gnomerc".text = ''
    #!/bin/sh
    IFS=
    echo \"Press the 'n' key to launch basestation, any other key to go to the DM\"
    read -n 1 key
    echo \"\"
    if [ \"$key\" !== \"n\" ]; then
        cd ~/Documents/basestation-game && nix-develop --command \"godot-mono\"
    fi &
  '';
}
