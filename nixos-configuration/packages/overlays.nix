{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  # more chromium flags in ~/.local/scripts/other-common-scripts/flatpak-manage.sh
  commonChromiumFlags = lib.optionals (config.customOptions.displayServer.waylandEnabled or false) [
    "--disable-sync-preferences" # disable syncing chromium preferences with a sync account
    "--enable-features=TouchpadOverscrollHistoryNavigation" # enable two-finger swipe for forward/backward history navigation
  ];
in
{
  imports = [ ./tmp-fix-overlays.nix ];

  nixpkgs.overlays = [
    # Actual overlays (package modifications) go here.
    (final: prev: {
      mpv = prev.mpv.override { scripts = [ final.mpvScripts.mpris ]; };
      mpv-unwrapped = prev.mpv-unwrapped.override { ffmpeg = final.ffmpeg-full; };

      rustup-bin =
        let
          rustup = final.rustup;
        in
        pkgs.stdenv.mkDerivation {
          pname = "rustup-bin";
          inherit (rustup) version;

          dontUnpack = true;
          dontBuild = true;

          installPhase = ''
            mkdir -p $out/bin
            ln -s ${rustup}/bin/rustup $out/bin/rustup
          '';
        };

      brave = prev.brave.override { commandLineArgs = commonChromiumFlags; };
      chromium = prev.chromium.override {
        commandLineArgs = commonChromiumFlags;
        enableWideVine = false;
      };
      google-chrome = prev.google-chrome.override { commandLineArgs = commonChromiumFlags; };
      ungoogled-chromium = prev.ungoogled-chromium.override {
        commandLineArgs = commonChromiumFlags;
        enableWideVine = false;
      };

      pi-coding-agent = final.callPackage ./out-of-tree-derivations/pi-coding-agent {
        pi-coding-agent = prev.pi-coding-agent;
      };
    })

    # out of tree package definitions go here
    (final: prev: {
      navya-ci = final.callPackage ./out-of-tree-derivations/navya-ci.nix { };
      custom-nixos-upgrade = final.stdenvNoCC.mkDerivation {
        name = "custom-nixos-upgrade";
        src = ../../scripts/nixos/custom-nixos-upgrade.py;

        buildInputs = with pkgs; [
          gitMinimal
          nix
          nixos-rebuild
          python3Minimal
          systemd
        ];

        dontUnpack = true;
        dontBuild = true;

        installPhase = "install -Dm 755 $src $out/bin/custom-nixos-upgrade.py";

        meta.mainProgram = "custom-nixos-upgrade.py";
      };
    })

    #(final: prev: {
    #  # QEMU requires the `librados` library for Ceph support and I don't need
    #  # it. Plus, something is always going on in Python/Ceph space so disable
    #  # Ceph support outright.
    #  qemu =
    #    (prev.qemu.overrideAttrs (oldAttrs: {
    #      configureFlags = (oldAttrs.configureFlags or [ ]) ++ [
    #        "--disable-rbd"
    #      ];
    #    })).override
    #      {
    #        cephSupport = false;
    #        ceph = null;
    #      };
    #
    #  qemu_full = final.qemu.override {
    #    # Since we're building qemu anyways, let's do it only for some ISAs
    #    hostCpuTargets = [
    #      "aarch64-softmmu"
    #      "riscv64-softmmu"
    #      "i386-softmmu" # not directly consumed but present for compatibility reasons
    #      "x86_64-softmmu"
    #    ];
    #  };
    #})

    # Package overrides where no matter what, a given package is always used
    # from the stable channel, goes here.
    (final: prev: {
      google-cloud-sdk-gce = stablePkgs.google-cloud-sdk-gce;
    })

    # Custom (new) packages go here.
    (final: prev: {
      convertSafetensorsToGGUF =
        let
          env_PATH = lib.makeBinPath (
            with final.python3Packages;
            [
              python
              torch
              transformers
            ]
          );
        in
        final.writeScriptBin "convert-safetensors-to-gguf" ''
          #!${lib.getExe final.bash}
          export PATH=${env_PATH}:$PATH
          python3 ${final.llama-cpp.src}/convert_hf_to_gguf.py "$@"
        '';

      run_inference_qwen_3_6__27b =
        let
          fetched_qwen_3_6__27b_safetensors = final.fetchgit {
            url = "https://huggingface.co/Qwen/Qwen3.6-27B";
            rev = "6a9e13bd6fc8f0983b9b99948120bc37f49c13e9";
            hash = "sha256-7lWt9AeuSk9XIgpwVF2OnSoyW2+Tw/Kd46/KFG484Y8=";
            fetchLFS = true;
          };
        in
        final.writeScriptBin "run-inference-qwen3.6-27b" ''
          #!${lib.getExe final.bash}

          ${lib.getExe' final.llama-cpp "llama-server"} \
              --host 0.0.0.0 \
              --port ''${PORT:-8080} \
              --n-gpu-layers all \
              --alias Qwen/Qwen3.6-27B \
              --model ${final.safeTensorsToGGUF fetched_qwen_3_6__27b_safetensors} \
              --temperature 0.6 \
              --top-p 0.95 \
              --top-k 20 \
              --min-p 0.0  \
              --presence-penalty 0.0 \
              --repeat-penalty 1.0 \
              --reasoning off \
              --ctx-size $(( 1024 * 256 )) \
              #${fetched_qwen_3_6__27b_safetensors}
        '';

      ubootRaspberryPiGeneric_64bit = final.buildUBoot {
        defconfig = "rpi_arm64_defconfig";
        extraMeta.platforms = [ "aarch64-linux" ];
        filesToInstall = [ "u-boot.bin" ];
      };

      rpiUbootAndFirmware = final.stdenvNoCC.mkDerivation {
        version = final.ubootRaspberryPiGeneric_64bit.version;
        name = "rpiUbootAndFirmware";
        dontUnpack = true;
        meta.platforms = [ "aarch64-linux" ];

        buildPhase = ''
          set -x

          mkdir $out
          cp -r ${final.raspberrypifw}/share/raspberrypi/boot/* $out
          rm -vf $out/kernel*.img
          cp -r ${final.ubootRaspberryPiGeneric_64bit}/u-boot.bin $out/rpi-u-boot.bin

          cat << EOF > $out/config.txt
          # http://rptl.io/configtxt
          arm_64bit=1
          arm_boost=1
          enable_uart=1
          kernel=rpi-u-boot.bin

          disable_fw_kms_setup=1
          disable_splash=0
          display_auto_detect=1
          dtparam=audio=on
          enable_tvout=0
          max_framebuffers=2

          [pi4]
          hdmi_enable_4kp60=0 # increases power consumption and no longer needed

          [cm4]
          otg_mode=1

          [pi5]
          dtparam=uart0_console # enables UART over the "old" GPIO pins (14 and 15)
          EOF

          set +x
        '';
      };
    })
  ];
}
