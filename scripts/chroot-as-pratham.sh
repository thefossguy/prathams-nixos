#!/usr/bin/env bash

if [[ ${USER} == "pratham" && ${HOME} = "/home/pratham" ]]; then
    # get dotfiles
    git clone --depth 1 --bare https://gitlab.com/thefossguy/dotfiles.git $HOME/.dotfiles
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

    if command -v podman; then
        systemctl --user enable \
            podman-restart.service \
            podman-init.service \
            container-caddy-vishwambhar.service \
            container-hugo-vaikunthnatham.service \
            container-gitea-chitragupta.service \
            container-gitea-govinda.service \
            container-hugo-mahayogi.service \
            container-uptime-vishnu.service \
            container-transmission-raadhe.service \
            #EOF
    fi
fi
