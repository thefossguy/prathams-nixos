{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  osConfig ? { },
  ...
}:

let
  useMinimalConfig = (osConfig.customOptions.useMinimalConfig or false);
  enableHomelabServices = (osConfig.customOptions.podmanContainers.enableHomelabServices or false);

  devPackages = {
    kernel = lib.optionals (!useMinimalConfig && config.customOptions.kernelDevelopment.enable) (
      with pkgs;
      [
        b4
      ]
    );

    rust = lib.optionals (!useMinimalConfig) (
      with pkgs;
      [
        #cargo-deb # generate .deb packages solely based on Cargo.toml
        #cargo-ndk # extension for building Android NDK projects
        #cargo-audit # audit crates for security vulnerabilities
        #cargo-benchcmp # compare Rust micro-benchmarks
        #cargo-binstall # install Rust binaries instead of building them from src
        #cargo-bisect-rustc # find exactly which rustc commit/release-version which prevents your code from building now
        #cargo-bloat # find what takes the most space in the executable
        cargo-cache # manage cargo cache (${CARGO_HOME}); print and remove dirs selectively
        #cargo-chef # for speeding up container builds using layer caching
        #cargo-dist # distribute on crates.io
        #cargo-flamegraph # flamegraphs without Perl or pipes
        #cargo-hack # build project with all the possible variations of options/flags and check which ones fail and/or succeed
        #cargo-outdated # show outdated deps
        #cargo-profiler # profile Rust binaries
        #cargo-public-api # detect breaking API changes and semver violations
        #cargo-show-asm # display ASM, LLVM-IR, MIR and WASM for the Rust src
        #cargo-sweep # cleanup unused build files
        #cargo-udeps # find unused dependencies
        #cargo-update # update installed binaries
        #cargo-vet # ensure that the third-party dependencies are audited by a trusted source
        cargo-watch # run cargo commands when the src changes
        rustup-bin
      ]
      ++ (lib.optionals (pkgs.stdenv.isLinux) [ cargo-valgrind ])
    );
  };

  packageSets = {
    email = lib.optionals (!useMinimalConfig && (!darwinPackagesCheck)) (
      with pkgs;
      [
        #aerc
        catimg # fur email (aerc); print image on ze terminal
        protonmail-bridge
      ]
    );
    misc = lib.optionals (!useMinimalConfig && nixosPackagesCheck) (
      with pkgs;
      [
        dpkg
        imagemagick
        inotify-tools
        rpm
        #ventoy
      ]
    );
    mozilla = lib.optionals (!useMinimalConfig && nixosPackagesCheck) (
      with pkgs;
      [
        #firefox-esr
        thunderbird
      ]
    );
    podman = lib.optionals enableHomelabServices (
      with pkgs;
      [
        ctop
        podman
        podman-compose
        podman-tui
      ]
    );
  };

  nixosPackagesCheck = (nixosSystemConfig.coreConfig.isNixOS);
  nixosPackagesMinimal = lib.optionals nixosPackagesCheck (
    with pkgs;
    [
      dconf
      wol
    ]
  );
  nixosPackages = lib.optionals (!useMinimalConfig && nixosPackagesCheck) (
    with pkgs;
    [
    ]
    ++ lib.optionals (osConfig.customOptions.virtualisation.enable or false) [ pykickstart ]
  );

  tuxPackagesCheck = (pkgs.stdenv.isLinux && (!nixosSystemConfig.coreConfig.isNixOS));
  tuxPackagesMinimal = lib.optionals tuxPackagesCheck (
    with pkgs;
    [
    ]
  );
  tuxPackages = lib.optionals (!useMinimalConfig && tuxPackagesCheck) (
    with pkgs;
    [
    ]
  );

  darwinPackagesCheck = (pkgs.stdenv.isDarwin);
  darwinPackages = lib.optionals darwinPackagesCheck (
    with pkgs;
    [
      coreutils-prefixed
      gawk
      gnugrep
      gnused
      nerd-fonts._0xproto
      nerd-fonts.fira-code
      nerd-fonts.overpass
      nerd-fonts.sauce-code-pro
      noto-fonts-color-emoji
      tmux # It is in `system-packages.nix` and `${scriptsDir}/other-common-scripts/unix-setup.sh`
      watch
    ]
  );

  commonPackagesMinimal = with pkgs; [
    # utilities specific to Nix
    gcc # added to prevent adding a $CC to the PATH to compile with cargo and to neovim for treesitter
    home-manager
    hydra-check
    jq
    yq # like `jq` but for TOML, XML and YAML

    # utilities specific to Nix
    nix-diff # a better `nvd`
    nix-du
    nix-output-monitor
    nix-top
    nix-tree
    nixfmt-rfc-style
    nvd # diff between NixOS generations
  ];
  commonPackages = lib.optionals (!useMinimalConfig) (
    with pkgs;
    [
      # misc utilities + shells
      asciinema
      choose
      dash
      delta
      dig # provides `dig` and `nslookup`
      dpkg
      du-dust
      dua
      fd
      fzf
      hyperfine
      iperf # this is `iperf3`
      iperf2 # this is what is usually `iperf` on other distros
      mediainfo
      nload
      parallel
      picocom
      procs
      python3
      sd
      tre-command
      unzip
      wget2
      zip

      # utilities specific to Nix
      nix-prefetch
      nix-prefetch-git
      nix-prefetch-github
      nixpkgs-review
    ]
    ++ lib.optionals ((pkgs.stdenv.isx86_64 && pkgs.stdenv.isLinux) || (pkgs.stdenv.isAarch64 && pkgs.stdenv.isDarwin)) [
      ffmpeg
    ]
  );
in
{
  imports = lib.optionals (!nixosSystemConfig.coreConfig.isNixOS) [ ./overlays.nix ];

  home.packages =
    nixosPackagesMinimal
    ++ nixosPackages
    ++ tuxPackagesMinimal
    ++ tuxPackages
    ++ darwinPackages
    ++ commonPackagesMinimal
    ++ commonPackages
    ++ devPackages.kernel
    ++ devPackages.rust
    ++ packageSets.misc
    ++ packageSets.mozilla
    ++ packageSets.podman
    ++ packageSets.email;

  programs = {
    # `aria2` is an exception because even though it can easily be replaced
    # with `wget` or `wget2`, `aria2` has, in my experience, higher chance of
    # completing a download faster than `wget` or `wget2`.
    aria2.enable = true;
    bat.enable = true;
    bottom.enable = !useMinimalConfig;
    broot.enable = !useMinimalConfig && pkgs.stdenv.isx86_64;
    btop.enable = true;
    ripgrep.enable = true;
    tealdeer.enable = !useMinimalConfig;
    # I randomly select a server to "download" a big [set] of video file(s)
    # so enabling `yt-dlp` is necessary.
    yt-dlp.enable = true;
    zoxide.enable = true;

    direnv = lib.attrsets.optionalAttrs (!useMinimalConfig) {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    neovim = {
      enable = true;
      package = pkgsChannels.unstable.neovim-unwrapped;
      extraPackages =
        with pkgs;
        [
          # language servers
          clang-tools # provides clangd
          gcc
          lldb # provides lldb-vscode
          lua-language-server
          nil # language server for Nix
          nodePackages.bash-language-server
          pyrefly
          shellcheck

          # misc
          tree-sitter # otherwise nvim complains that the binary 'tree-sitter' is not found
        ]
        ++ [ pkgsChannels.stable.dict ];
    };
  };
}
