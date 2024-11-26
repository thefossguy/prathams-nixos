#!/usr/bin/env bash
set -xeuf -o pipefail

if [[ -n "${HOME}" ]]; then
    # get dotfiles
    git clone --bare https://gitlab.com/thefossguy/dotfiles.git "${HOME}/.dotfiles"
    git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" checkout -f

    # "generate" SSH keys
    chmod 700 "${HOME}/.ssh"
    touch "${HOME}/.ssh"/{ssh,git}{,.pub}
else
    # shellcheck disable=SC2016
    echo 'ERROR: For some reason $HOME is not defined...'
    exit 1
fi
