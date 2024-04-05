{ config
, lib
, pkgs
, systemUser
, ...
}:

{
  programs = {
    aria2.enable = true;
    bat.enable = true;
    bottom.enable = true;
    broot.enable = true;
    btop.enable = true;
    ripgrep.enable = true;
    tealdeer.enable = true;
    yt-dlp.enable = true;
    zoxide.enable = true;

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    neovim = {
      enable = true;
      extraPackages = with pkgs; [
        clang-tools # provides clangd
        gcc # for nvim-tree's parsers
        lldb # provides lldb-vscode
        lua-language-server
        nil # language server for Nix
        nixpkgs-fmt
        nodePackages.bash-language-server
        ruff
        shellcheck
        tree-sitter # otherwise nvim complains that the binary 'tree-sitter' is not found
      ];
    };
  };
}
