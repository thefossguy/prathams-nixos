#!/usr/bin/env nix-shell
#!nix-shell -i dash --packages dash bash git

set -xeuf -o pipefail

if [ "${USER}" = 'pratham' ] && [ -n "${HOME}" ]; then
    # get dotfiles
    git clone --bare https://gitlab.com/thefossguy/dotfiles.git "${HOME}/.dotfiles"
    git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" checkout -f

    # generate SSH keys
    chmod 700 "${HOME}/.ssh"
    pushd "${HOME}/.ssh"
    clear -x
    ssh-keygen -t ed25519 -f git
    ssh-keygen -t ed25519 -f ssh
    popd

    # get nixos config
    mkdir -vp "${HOME}/my-git-repos/pratham"
    pushd "${HOME}/my-git-repos/pratham"
    git clone https://gitlab.com/thefossguy/prathams-nixos
    popd
else
    >&2 echo "$0: You are not me"
    exit 1
fi
