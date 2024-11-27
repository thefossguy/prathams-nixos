if [ ! -f "$HOME/.bashrc" ]; then
    rm -f "$HOME/.profile"
    bash "$HOME/chroot-user-setup.sh"
fi
