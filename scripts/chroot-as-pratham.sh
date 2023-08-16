#!/usr/bin/env bash

if [[ ${USER} == "pratham" && ${HOME} = "/home/pratham" ]]; then
    # get dotfiles
    git clone --depth 1 --bare https://gitlab.com/thefossguy/dotfiles.git $HOME/.dotfiles
    git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout -f

    # generate SSH keys
    chmod 700 $HOME/.ssh
    pushd $HOME/.ssh
    clear -x
    ssh-keygen -t ed25519 -f ssh
    ssh-keygen -t ed25519 -f git
    popd
fi
