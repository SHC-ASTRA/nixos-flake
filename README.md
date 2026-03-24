# Getting Started Guide

- Be sure to read the [den documentation](https://vic.github.io/den)

- Update den input.

```console
nix flake update den
```

- Build

```console
# default action is build
nix run .#deck

# pass any other nh action
nix run .#deck -- switch
```

- Run the VM

See [modules/vm.nix](modules/vm.nix)

```console
nix run .#vm
```
