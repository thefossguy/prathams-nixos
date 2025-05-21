#!/usr/bin/env bash
set -euf -o pipefail
set -x

if ! command -v git > /dev/null 2>&1; then
    nix-env -iA nixos.git
fi

if [[ ! -d "${HOME}/prathams-nixos" ]]; then
    git clone https://gitlab.com/thefossguy/prathams-nixos.git
fi

pushd "${HOME}/prathams-nixos"
if [[ "${LOGNAME}" != 'root' ]]; then
    # Update the flake using `sudo` because the installer runs with `sudo`
    sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes flake update
else
    nix --extra-experimental-features nix-command --extra-experimental-features flakes flake update
fi
popd

nix --extra-experimental-features nix-command --extra-experimental-features flakes develop "${HOME}/prathams-nixos"#devShells."$(uname -m)-linux".nixosInstaller
