{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.system}.default
  ];
  age.secrets = {
    id_ed25519-key = {
      file = ./id_ed25519-key.age;
      path = "/home/astra/.ssh/id_ed25519";
      mode = "600";
      owner = "astra";
      group = "users";
    };
  };
}
