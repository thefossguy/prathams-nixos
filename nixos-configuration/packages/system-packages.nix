{ config
, lib
, pkgs
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
in

{
  environment.systemPackages = with pkgs; [
    # base system packages + packages what I *need*
    cloud-utils # provides growpart
    dig # provides dig and nslookup
    dmidecode
    file
    findutils
    gawk
    gettext # for translation (human lang; Eng <-> Hindi)
    gnugrep
    gnused
    hdparm
    inotify-tools
    iproute2
    iputils
    linux-firmware
    lsof
    minisign
    nvme-cli
    parallel
    pciutils # provides lspci and setpci
    pinentry # pkg summary: GnuPG’s interface to passphrase input
    procps # provides pgrep, kill, watch, ps, pidof, uptime, sysctl, free, etc
    psmisc # provides killall, fuser, pslog, pstree, etc
    pv
    python3Minimal
    rsync
    smartmontools
    tree
    usbutils
    util-linux # provides blkid, losetup, lsblk, rfkill, fallocate, dmesg, etc
    vim # it is a necessity
    wol

    # shells
    dash

    # download clients
    curl
    wget

    # compression and decompression
    bzip2
    gnutar
    gzip
    unzip
    xz
    zip
    zstd

    # programming tools + compilers
    #cargo-deb # generate .deb packages solely based on Cargo.toml
    #cargo-ndk # extension for building Android NDK projects
    #binutils # provides readelf, objdump, strip, as, objcopy (GNU; not LLVM)
    #gdb
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
    cargo-valgrind
    cargo-vet # ensure that the third-party dependencies are audited by a trusted source
    cargo-watch # run cargo commands when the src changes
    rustup # provides rustfmt, cargo-clippy, rustup, cargo, rust-lldb, rust-analyzer, rustc, rust-gdb, cargo-fmt

    # e-mail
    aercFull
    protonmail-bridge
    thunderbird

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

    # network monitoring
    iperf # this is iperf3
    iperf2 # this is what is usually 'iperf' on other distros
    nload

    # other utilities
    asciinema
    buildah
    fzf
    parted
    picocom
    ubootTools
    ventoy

    # utilities written in Rust
    choose
    du-dust
    dua
    fd
    hyperfine
    procs
    sd
    tre-command

    # virtualisation
    qemu_kvm

    # tools specific to Nix
    nix-output-monitor
    nvd # diff between NixOS generations
    nix-prefetch
    nix-prefetch-git
    nix-prefetch-github
  ];

  programs = {
    adb.enable = true;
    bandwhich.enable = true;
    ccache.enable = true;
    command-not-found.enable = true;
    dconf.enable = true;
    git.enable = true;
    gnupg.agent.enable = true;
    htop.enable = true;
    iotop.enable = true;
    mtr.enable = true;
    skim.fuzzyCompletion = true;
    sniffnet.enable = true;
    tmux.enable = true;
    traceroute.enable = true;
    trippy.enable = true;
    usbtop.enable = true;

    bash = {
      enableCompletion = true;
      # notifications when long-running terminal commands complete
      undistractMe = {
        enable = true;
        playSound = true;
        timeout = 300; # notify only if said command has been running for this many seconds
      };
      # aliases for the root user
      # doesn't affect 'pratham' since there is an `unalias -a` in $HOME/.bashrc
      shellAliases = {
        "e" = "${pkgs.vim}/bin/vim";
      };
    };

    nano = {
      enable = true;
      syntaxHighlight = true;
    };
  };
}
