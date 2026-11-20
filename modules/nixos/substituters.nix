# the caches our systems and the installer ISO pull from. flake.nix's `nixConfig` and the
# workflows' `extra-conf` have to repeat these literally, so keep them in sync.
{
  nix.settings = {
    extra-substituters = [
      # ours. the Tegra kernel, the L4T modules, and CUDA OpenCV are in no public cache
      "https://cache.ryleu.me/astra"
      "https://ros.cachix.org"
      "https://attic.iid.ciirc.cvut.cz/ros"
    ];

    extra-trusted-public-keys = [
      "astra:d9bYlP7iR2odaZA2hYYuZRfaeN89lK+W1hiw6THibeQ="
      "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
      "ros:JR95vUYsShSqfA1VTYoFt1Nz6uXasm5QrcOsGry9f6Q="
    ];
  };
}
