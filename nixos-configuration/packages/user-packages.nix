{ config
, lib
, pkgs
, systemUser
, ...
}:

let
  packagesInPathForAerc = with pkgs; [ bat catimg pandoc ];
  aercFull = pkgs.aerc.overrideAttrs (final: prev: {
    nativeBuildInputs = prev.nativeBuildInputs or [] ++ (with pkgs; [ makeWrapper ]);
    postInstall = (prev.postInstall or "") + ''
      wrapProgram $out/bin/aerc \
        --prefix PATH : ${pkgs.lib.makeBinPath packagesInPathForAerc}
    '';
  });

  linuxPackages =  lib.optionals (pkgs.stdenv.isLinux) (with pkgs; [
    cargo-valgrind
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
in

{
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
    cargo-deps # build dependency graph of Rust projects
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
    aercFull
    protonmail-bridge

    # misc utilities + shells
    asciinema
    buildah
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
    imagemagick
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
    wget
    zip

    # utilities specific to Nix
    nix-prefetch
    nix-prefetch-git
    nix-prefetch-github
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
