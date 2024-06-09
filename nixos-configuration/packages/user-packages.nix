{ lib, pkgs, pkgs0UnstableSmall, ... }:

let
  neovimPackage = if lib.versionAtLeast pkgs.neovim-unwrapped.version "0.10"
    then pkgs.neovim-unwrapped
    else pkgs0UnstableSmall.neovim-unwrapped;

  linuxPackages = lib.optionals (pkgs.stdenv.isLinux) (with pkgs; [
    buildah
    cargo-valgrind
    dict
    imagemagick
    inotify-tools
    rpm
    thunderbird
    ventoy
    wol
  ]);

  darwinPackages = lib.optionals (pkgs.stdenv.isDarwin) (with pkgs; [
    coreutils-prefixed
    gawk
    gnugrep
    gnused
    tmux
    watch

    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "Overpass"
        "SourceCodePro"
      ];
    })
  ]);

in {
  home.packages = linuxPackages ++ darwinPackages ++ (with pkgs; [
    # programming tools + compilers
    #cargo-deb # generate .deb packages solely based on Cargo.toml
    #cargo-ndk # extension for building Android NDK projects
    b4 # applying patches from mailing lists
    cargo-audit # audit crates for security vulnerabilities
    cargo-benchcmp # compare Rust micro-benchmarks
    cargo-binstall # install Rust binaries instead of building them from src
    cargo-bisect-rustc # find exactly which rustc commit/release-version which prevents your code from building now
    cargo-bloat # find what takes the most space in the executable
    cargo-cache # manage cargo cache (${CARGO_HOME}); print and remove dirs selectively
    cargo-chef # for speeding up container builds using layer caching
    cargo-dist # distribute on crates.io
    cargo-flamegraph # flamegraphs without Perl or pipes
    cargo-hack # build project with all the possible variations of options/flags and check which ones fail and/or succeed
    cargo-outdated # show outdated deps
    cargo-profiler # profile Rust binaries
    cargo-public-api # detect breaking API changes and semver violations
    cargo-show-asm # display ASM, LLVM-IR, MIR and WASM for the Rust src
    cargo-sweep # cleanup unused build files
    cargo-udeps # find unused dependencies
    cargo-update # update installed binaries
    cargo-vet # ensure that the third-party dependencies are audited by a trusted source
    cargo-watch # run cargo commands when the src changes
    rustup # provides rustfmt, cargo-clippy, rustup, cargo, rust-lldb, rust-analyzer, rustc, rust-gdb, cargo-fmt

    # e-mail
    aerc
    protonmail-bridge

    # misc utilities + shells
    asciinema
    catimg # fur email (aerc); print image on ze terminal
    choose
    dash
    dig # provides dig and nslookup
    dpkg
    du-dust
    dua
    fd
    ffmpeg
    file
    fzf
    hyperfine
    iperf # this is iperf3
    iperf2 # this is what is usually 'iperf' on other distros
    mediainfo
    nload
    parallel
    picocom
    procs
    python3Minimal
    sd
    tre-command
    tree
    unzip
    wget2
    zip

    # utilities specific to Nix
    home-manager
    nix-output-monitor
    nix-prefetch
    nix-prefetch-git
    nix-prefetch-github
    nixfmt-classic

    # these projects were deleted
    #cargo-deps # build dependency graph of Rust projects # https://github.com/NixOS/nixpkgs/pull/302970#issuecomment-2046592104
  ]);

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
    pandoc.enable = true;

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    neovim = {
      enable = true;
      package = neovimPackage;
      extraPackages = with pkgs; [
        clang-tools # provides clangd
        gcc # for nvim-tree's parsers
        lldb # provides lldb-vscode
        lua-language-server
        nil # language server for Nix
        nodePackages.bash-language-server
        ruff
        shellcheck
        tree-sitter # otherwise nvim complains that the binary 'tree-sitter' is not found
      ];
    };
  };
}
