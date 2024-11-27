DOTFILES_DIR="$HOME/.dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone --bare https://gitlab.com/thefossguy/dotfiles.git "$DOTFILES_DIR"
    exec git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout -f
fi
