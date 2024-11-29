set -x
DOTFILES_DIR="$HOME/.dotfiles"

if ! ping -c 5 'gitlab.com' 1>/dev/null 2>&1; then
    set +x
    echo 'You do not appear to be connected to the internet.'
    echo 'Please clone the dotfiles directory manually.'
    exec bash
fi

git clone --bare https://gitlab.com/thefossguy/dotfiles.git "$DOTFILES_DIR" || \
    (rm -rf "$DOTFILES_DIR" && git clone --bare https://gitlab.com/thefossguy/dotfiles.git "$DOTFILES_DIR")
git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout -f
set +x
exec bash
