# README
[![Continuous Build](https://github.com/thefossguy/prathams-nixos/actions/workflows/continuous-build.yaml/badge.svg)](https://github.com/thefossguy/prathams-nixos/actions/workflows/continuous-build.yaml)

 1. `$hostName` is the hostname of a host defined in the `nixosHosts` set,
    inside the flake.nix file
 2. `$(whoami)` should evaluate to the username of a valid user, as
    defined in the `nixosHosts` set, inside the flake.nix file

## Install NixOS

```bash
sudo ./install.sh $targetDrive $hostName
```

### Build a NixOS configuration

```bash
nix build .#machines."$hostName"
```


## Standalone installation of home-manager

```bash
nix run home-manager/master -- switch --flake .
```

### Build a standalone home-manager configuration

```bash
nix build .#homeOf."$(uname -m)-$(uname -s | awk '{print tolower($0)}')"."$(whoami)"
```


## Create a NixOS ISO

```bash
nix build .#isos."$(uname -m)"
```
