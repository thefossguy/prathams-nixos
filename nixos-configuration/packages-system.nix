{ pkgs, ... }:

{
  # packages to be installed _system wide_
  environment.systemPackages = with pkgs; [
    # base system packages + packages what I *need*
    cloud-utils # provides growpart
    coreutils
    dmidecode
    doas
    file
    findutils
    gawk
    gettext # for translation (human lang; Eng <-> Hindi)
    gnugrep
    gnused
    hdparm
    inotify-tools
    iproute
    iputils
    linux-firmware
    lsof
    mlocate
    nvme-cli
    openssh
    openssl
    parallel
    pciutils # provides lspci and setpci
    pinentry # pkg summary: GnuPG’s interface to passphrase input
    procps # provides pgrep, kill, watch, ps, pidof, uptime, sysctl, free, etc
    psmisc # provides killall, fuser, pslog, pstree, etc
    pv
    python3Minimal
    rsync
    shadow
    smartmontools
    tmux
    tree
    usbutils
    util-linux # provides blkid, losetup, lsblk, rfkill, fallocate, dmesg, etc
    wol

    # text editors
    nano
    vim

    # shells
    dash

    # download clients
    aria2
    curl
    wget
    yt-dlp

    # compression and decompression
    bzip2
    gnutar
    gzip
    #rar # absent on aarch64, and not really needed
    unzip
    xz
    zip
    zstd

    # programming tools + compilers
    #cargo-deb # generate .deb packages solely based on Cargo.toml
    #cargo-ndk # extension for building Android NDK projects
    b4 # applying patches from mailing lists
    binutils # provides readelf, objdump, strip, as, objcopy (GNU; not LLVM)
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
    cargo-valgrind
    cargo-vet # ensure that the third-party dependencies are audited by a trusted source
    cargo-watch # run cargo commands when the src changes
    gcc
    rustup # provides rustfmt, cargo-clippy, rustup, cargo, rust-lldb, rust-analyzer, rustc, rust-gdb, cargo-fmt

    # language servers, parsers and other related packages
    clang-tools # provides clangd
    lldb # provides lldb-vscode
    lua-language-server
    nil # language server for Nix
    nodePackages.bash-language-server
    ruff
    shellcheck
    tree-sitter # otherwise nvim complains that the binary 'tree-sitter' is not found

    # power management
    acpi
    lm_sensors

    # dealing with other distro's packages
    dpkg
    rpm

    # for media consumption, manipulation and metadata info
    ffmpeg
    imagemagick
    mediainfo

    # system monitoring
    btop
    htop
    iotop
    iotop-c
    usbtop

    # network monitoring
    iperf # this is iperf3
    iperf2 # this is what is usually 'iperf' on other distros
    nload

    # other utilities
    android-tools
    asciinema
    buildah
    fzf
    parted
    picocom
    ubootTools
    ventoy

    # utilities written in Rust
    bandwhich
    bat
    bottom
    broot
    choose
    du-dust
    dua
    fd
    hyperfine
    procs
    ripgrep
    sd
    skim
    sniffnet
    tealdeer
    tre-command
    zoxide

    # virtualisation
    #OVMF
    #qemu
    #qemu-utils
    qemu_kvm

    # tools specific to NixOS
    nix-output-monitor
    nvd # diff between NixOS generations
  ];

  programs = {
    adb.enable = true;
    bash = {
      enableCompletion = true;
      # notifications when long-running terminal commands complete
      undistractMe = {
        enable = true;
        playSound = true;
        timeout = 60; # notify only if said command has been running for this many seconds
      };
    };
    ccache.enable = true;
    command-not-found.enable = true;
    dconf.enable = true;
    git.enable = true;
    gnupg.agent.enable = true;
    mtr.enable = true;
    neovim.enable = true;
  };
}
