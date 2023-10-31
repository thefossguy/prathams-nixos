```
nix-env -iA nixos.{bat,btop,git,htop,ripgrep,tmux}
git clone --depth 1 https://gitlab.com/thefossguy/prathams-nixos
cd prathams-nixos

tmux
clear && sudo ./install.sh \
    [drive] \
    [hostname] \
    [desktop|rpi|virt]
```
