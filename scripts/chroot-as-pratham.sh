#!/usr/bin/env bash

if [[ ${USER} == "pratham" && ${HOME} = "/home/pratham" ]]; then
    # get dotfiles
    git clone --depth 1 --bare https://git.thefossguy.com/thefossguy/dotfiles.git $HOME/.dotfiles
    git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout -f
    rm -rf $HOME/.dotfiles

    # generate SSH keys
    mkdir $HOME/.ssh
    chmod 700 $HOME/.ssh
    pushd $HOME/.ssh
    clear -x
    ssh-keygen -t ed25519 -f ssh
    ssh-keygen -t ed25519 -f git
    popd

    # cleanup
    rm $HOME/chroot-as-pratham.sh
fi
