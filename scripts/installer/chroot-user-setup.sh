#!/usr/bin/env bash
set -xeuf -o pipefail

rm -vf "$0"
# get dotfiles
git clone --bare https://gitlab.com/thefossguy/dotfiles.git "${HOME}/.dotfiles"
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" checkout -f

# "generate" SSH keys
chmod 700 "${HOME}/.ssh"
touch "${HOME}/.ssh"/{ssh,git}{,.pub}
