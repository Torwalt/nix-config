# My NixOS config

## First time setting up

- dont forget to copy generated hardware-configuration.nix and include it in configuration.nix
- if full disk encryption was chosen in installer, dont forget to add that part into configuration.nix

## Updating and cleanup

Every host installs a `nixup` command through Home Manager. It knows the
matching NixOS and Home Manager flake outputs for that host.

```console
nixup          # update inputs, check, build, deploy, and clean
nixup apply    # deploy the existing lock file without updating it
nixup check    # check and build without activating anything
nixup clean    # retain four generations and garbage-collect
nixup clean --dry-run # preview which generations would be removed
nixup status   # show update age, generation counts, disk use, and reboot state
```

`nixup` builds both configurations before activating either one. It switches
NixOS first and Home Manager second, and records an update as successful only
after both activations complete. Cleanup retains the latest four NixOS, Home
Manager, and user-profile generations before collecting unreferenced store
paths. Set `NIXUP_SKIP_CLEANUP=1` to skip cleanup for a particular deployment.

The existing `homeswitch` and `sysswitch` aliases remain available for
independent changes and now work from any directory. On a fresh checkout,
bootstrap `nixup` once from the repository with, for example,
`home-manager switch --flake .#workHome` (using the current host's output).

The success record is local to each machine under
`~/.local/state/nixup/last-success`. Interactive Zsh sessions show a reminder
once per day when the last successful deployment is at least 14 days old.

The default update command refuses to update an already-modified `flake.lock`.
Use `nixup apply` to deploy that lock file, or commit it first. After updating
on one host, review and commit `flake.lock`, then pull the commit and use
`nixup apply` on the other hosts so they all deploy the same revisions.
