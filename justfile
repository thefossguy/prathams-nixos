#!/usr/bin/env just --justfile
set shell := [ "bash", "-cu"]

actual-os := if os() == "macos" { "darwin" } else { os() }
actual-arch := env_var_or_default("EMULATED_SYSTEM", arch())

hm-user := env_var_or_default("HM_USER", "pratham")
nixos-machine-hostname := env_var_or_default("NIXOS_MACHINE_HOSTNAME", "")

update-lockfile := env_var_or_default("UPDATE_LOCKFILE", "0")
use-nom-instead := env_var_or_default("USE_NOM_INSTEAD", "0")
do-dry-run := env_var_or_default("DO_DRY_RUN", "0")
building-for-foreign-arch := if actual-arch == arch() { "0" } else { "1" }

nix-cmd := if use-nom-instead == "1" { "nom" } else { "nix" }
common-build-args := " --print-build-logs --show-trace --max-jobs 1 --cores 0"
dry-run-args := if do-dry-run == "1" { " --dry-run" } else { "" }
foreign-arch-env-var := if building-for-foreign-arch == "0" { "" } else { "NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 " }
foreign-arch-args := if building-for-foreign-arch == "0" { "" } else { " --impure" }
nix-build-cmd := foreign-arch-env-var + nix-cmd + " build" + common-build-args + foreign-arch-args + dry-run-args

lockfile-update-cmd := if update-lockfile == "0" { "" } else { "nix flake update" }

[private]
default:
    @just --list --unsorted

[private]
nix-flake-update:
    {{ lockfile-update-cmd }}

[unix]
build-home-manager: nix-flake-update
    {{ nix-build-cmd }} .#legacyPackages.{{ actual-arch }}-{{ actual-os }}.homeConfigurations.{{ hm-user }}.activationPackage

[linux]
build-nixos-system: nix-flake-update
    {{ nix-build-cmd }} .#nixosConfigurations.{{ nixos-machine-hostname }}.config.system.build.toplevel

[linux]
build-iso: nix-flake-update
    {{ nix-build-cmd }} .#nixosConfigurations.iso-{{ actual-arch }}.config.system.build.isoImage
