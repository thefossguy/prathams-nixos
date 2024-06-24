# README

`$NIXOS_MACHINE_HOSTNAME` refers to the value of
`nixosMachines.hosts."${hostname}"` as defined in the `flake.nix` file.


## Install NixOS

```bash
sudo ./install.sh $target_disk $NIXOS_MACHINE_HOSTNAME
```

### Build a NixOS configuration

```bash
nix run .#buildAllNixosSystems # builds all NixOS systems where `system == $(uname -m)-linux`
NIXOS_MACHINE_HOSTNAME=$(hostname) nix run .#buildThisNixosSystem
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
