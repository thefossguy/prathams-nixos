#!/usr/bin/env bash
set -xeuf -o pipefail

git clone --bare https://gitlab.com/thefossguy/dotfiles.git "$HOME/.dotfiles"
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout -f

mkdir -vp "$HOME/.ssh"
chmod 700 -v "$HOME/.ssh"

rm -vf "$0"
