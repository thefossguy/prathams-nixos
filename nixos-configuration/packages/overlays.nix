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

  addChromiumFlags =
    { chromiumDrv, final }:
    final.symlinkJoin {
      inherit (chromiumDrv) pname version;
      paths = [ chromiumDrv ];

      nativeBuildInputs = [ final.makeWrapper ];

      postBuild =
        let
          finalChromiumFlags = builtins.map (chromiumFlag: "--add-flags ${chromiumFlag}") commonChromiumFlags;
        in
        ''
          wrapProgram $out/bin/${chromiumDrv.meta.mainProgram} \
            ${builtins.concatStringsSep " " finalChromiumFlags}
        '';
    };
in
{
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

      landrun = prev.landrun.overrideAttrs (oldAttrs: {
        meta.broken = true;
      });

      brave = addChromiumFlags {
        chromiumDrv = prev.brave;
        inherit final;
      };
      brave-origin = addChromiumFlags {
        chromiumDrv = prev.brave-origin;
        inherit final;
      };
      chromium = addChromiumFlags {
        chromiumDrv = prev.chromium.override { enableWideVine = false; };
        inherit final;
      };
      google-chrome = addChromiumFlags {
        chromiumDrv = prev.google-chrome;
        inherit final;
      };
      ungoogled-chromium = addChromiumFlags {
        chromiumDrv = prev.ungoogled-chromium.override { enableWideVine = false; };
        inherit final;
      };

      pi-coding-agent = final.callPackage ./out-of-tree-derivations/pi-coding-agent.nix {
        pi-coding-agent = prev.pi-coding-agent;
      };
    })

    # out of tree package definitions go here
    (final: prev: {
      navya-ci = final.callPackage ./out-of-tree-derivations/navya-ci.nix { };
      nixos-install-tfg = final.callPackage ./out-of-tree-derivations/nixos-install-tfg.nix { };
      clanker-jail = final.callPackage ./out-of-tree-derivations/clanker-jail.nix { };
      sandboxed-pi-coding-agent = final.callPackage ./out-of-tree-derivations/sandboxed-pi-coding-agent.nix { };
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
      fetch-unsloth-quants = import ./out-of-tree-derivations/llm-weights/fetch-unsloth-quants.nix;
      convertSafeTensorsToGGUF = final.stdenvNoCC.mkDerivation (finalAttrs: {
        name = "convert-safe-tensors-to-gguf";
        __structuredAttrs = true;
        src = null;

        dontUnpack = true;
        dontPatch = true;
        dontConfigure = true;
        dontFixup = true;

        nativeBuildInputs = with pkgs.python3Packages; [
          python
          torch
          transformers
        ];

        buildPhase = ''
          set -x
          runHook preBuild

          ${
            if (finalAttrs.src == null) then
              "touch model.gguf"
            else
              ''
                python3 ${final.llama-cpp.src}/convert_hf_to_gguf.py \
                    ${finalAttrs.src} \
                    --model-name model \
                    --outfile model.gguf \
                    --verbose
              ''
          }

          runHook postBuild
          set +x
        '';

        installPhase = ''
          set -x
          runHook preInstall

          mv model.gguf $out

          runHook postInstall
          set +x
        '';
      });

      fetched_DeepSeek-V4-Flash-0731-GGUF-UD-Q8_K_XL =
        final.callPackage ./out-of-tree-derivations/llm-weights/DeepSeek-V4-Flash-0731-GGUF-UD-Q8_K_XL.nix
          { };
      fetched_DeepSeek-V4-Flash-0731-GGUF-UD-IQ1_M =
        final.callPackage ./out-of-tree-derivations/llm-weights/DeepSeek-V4-Flash-0731-GGUF-UD-IQ1_M.nix
          { };

      run_inference_qwen_3_6__27b =
        let
          fetched_qwen_3_6__27b_safetensors = final.fetchgit {
            url = "https://huggingface.co/Qwen/Qwen3.6-27B";
            rev = "6a9e13bd6fc8f0983b9b99948120bc37f49c13e9";
            hash = "sha256-7lWt9AeuSk9XIgpwVF2OnSoyW2+Tw/Kd46/KFG484Y8=";
            fetchLFS = true;
          };
          gguf_model_qwen_3_6__27b = final.convertSafeTensorsToGGUF.overrideAttrs (oldAttrs: {
            src = fetched_qwen_3_6__27b_safetensors;
          });
        in
        final.writeScriptBin "run-inference-qwen3.6-27b" ''
          #!${lib.getExe final.bash}

          ${lib.getExe' final.llama-cpp "llama-server"} \
              --host 0.0.0.0 \
              --port ''${PORT:-8080} \
              --n-gpu-layers all \
              --alias Qwen/Qwen3.6-27B \
              --model ${gguf_model_qwen_3_6__27b} \
              --temperature 0.6 \
              --top-p 0.95 \
              --top-k 20 \
              --min-p 0.0  \
              --presence-penalty 0.0 \
              --repeat-penalty 1.0 \
              --reasoning off \
              --ctx-size $(( 1024 * 256 )) \
              #EOF
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
