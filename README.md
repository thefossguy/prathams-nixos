# README

`$NIXOS_MACHINE_HOSTNAME` refers to the value of
`nixosMachines.hosts."${hostname}"`.


## Install NixOS

```bash
sudo ./install.sh $target_disk $NIXOS_MACHINE_HOSTNAME
```

### Build a NixOS configuration

Build the NixOS system where the hostname is `$targetHostname`. **It must be
defined the `nixosMachines.hosts` set.**
```bash
NIXOS_MACHINE_HOSTNAME=$targetHostname nix run .#buildThisNixosSystem
```

Builds all NixOS systems which can be natively built by your CPU.
```bash
nix run .#buildAllNixosSystems
```


## Standalone installation of home-manager

```bash
nix run home-manager/master -- switch --flake .
```

### Build a standalone home-manager configuration

Build home-manager for **all users** that are defined in the `realUsers` set.
```bash
nix run .#buildAllHomes
```

Build home-manager for the current user. **It must be defined in the `realUsers` set.**
```bash
nix run .#buildThisHome
```


## Create a NixOS ISO

```bash
nix run .#buildIso
```
