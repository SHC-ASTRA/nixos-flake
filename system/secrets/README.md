# Agenix secrets

We manage secrets on our machines using
[agenix](https://github.com/ryantm/agenix). Most of our setup was created using
Sawyer Shepherd's amazing blog post about agenix which can be found
[here](https://sawyershepherd.org/post/managing-secrets-in-nixos-with-agenix/).

## Adding new secrets

Let's say you're adding an encrypted secret called my secret. To do that, just
run `agenix -e my-secret.age` in the same directory as `secrets.nix`. Once you
save, it will automatically be encrypted in a way that allows all users in `./authorized_keys.nix` and all systems mentioned in `./secrets.nix` to decrypt it.

## Decrypting existing secrets

You can only decrypt secrets that have been encrypted for you. If your public
key isn't in `./authorized_keys.nix`, then you will not be able to decrypt the
key, and must first [add your user](#adding-new-users).

To decrypt a secret, use `agenix -d my-secret.age` and it will print it out.

## Adding new users

To allow a new user to decrypt the keys:

1. Add their [public key](#generating-public-keys) to `./authorized_keys.nix`.
2. Rekey the secrets with `agenix -r`.

You must complete these steps from a device that can already decrupt the
secrets, or else it will not be able to decrupt them in order to rekey them.

