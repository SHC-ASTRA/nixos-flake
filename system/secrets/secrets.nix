let
  users = import ./authorized_keys.nix;

  antenna = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIwsUyh1bedH185l55BuQCo3Ag98ltApYV8yh7Y3uW21 root@antenna";
  clucky = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID3uLg1EJtz9lOvdT6LplKL8mUEckXOaW7RGC3ND+qi3 root@clucky";
  deck = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPGoyey9zJE+hON+W79+lSPIzDjWdeNXG7iXzZP/N0u root@deck";
  panda = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKW2tl2+6PL1QHRgF6CISeIHcF9cHMzOEFpaPmJ1OlgQ root@panda";
  testbed = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPk+0RwYnmHx5jl/b+/jqiGO5l4tNNtPTElXpYsmVbnl root@testbed";

  systems = [
    antenna
    clucky
    deck
    panda
    testbed
  ];
in
{
  # SSH private key for ASTRA machines
  "id_ed25519-key.age".publicKeys = users ++ systems;
}
