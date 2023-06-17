```
nix-env -iA nixos.btop nixos.git nixos.tmux nixos.wget
git clone --depth 1 https://git.thefossguy.com/thefossguy/prathams-nixos
cd prathams-nixos

tmux
clear && sudo ./install.sh \
    [drive] \
    [hostname] \
    [desktop|rpi|virt]
```
