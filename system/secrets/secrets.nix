let
  users = import ./authorized_keys.nix;

  testbed = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPk+0RwYnmHx5jl/b+/jqiGO5l4tNNtPTElXpYsmVbnl root@testbed";
  clucky = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPvjS8AeOg270Y00imwSky4oo+7S7c00O3L1COqZQn6m root@clucky";
  deck = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPGoyey9zJE+hON+W79+lSPIzDjWdeNXG7iXzZP/N0u root@deck";

  systems = [
    testbed
    clucky
    deck
  ];
in
{
  # SSH private key for ASTRA machines
  "id_ed25519-key.age".publicKeys = users ++ systems;
}
