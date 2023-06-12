```
nix-shell -p btop git tmux wget
git clone --depth 1 https://git.thefossguy.com/thefossguy/prathams-nixos
cd prathams-nixos

tmux
sudo ./install.sh <drive> <hostname> <desktop|rpi|virt>
```
