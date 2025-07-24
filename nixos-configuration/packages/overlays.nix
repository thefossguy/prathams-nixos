{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  stablePkgs = pkgsChannels.stable;
  unstablePkgs = pkgsChannels.unstable;

  # more chromium flags in ~/.local/scripts/other-common-scripts/flatpak-manage.sh
  commonChromiumFlags = lib.optionals config.customOptions.displayServer.waylandEnabled [
    "--disable-sync-preferences" # disable syncing chromium preferences with a sync account
    "--enable-features=TouchpadOverscrollHistoryNavigation" # enable two-finger swipe for forward/backward history navigation
  ];
in
{
  imports = [ ./tmp-fix-overlays.nix ];

  nixpkgs.overlays = [
    # Actual overlays (package modifications) go here.
    (final: prev: {
      mpv = prev.mpv.override { scripts = [ prev.mpvScripts.mpris ]; };
      mpv-unwrapped = prev.mpv-unwrapped.override { ffmpeg = prev.ffmpeg-full; };

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
    })

    (final: prev: {
      # QEMU requires the `librados` library for Ceph support and I don't need
      # it. Plus, something is always going on in Python/Ceph space so disable
      # Ceph support outright.
      qemu =
        (prev.qemu.overrideAttrs (oldAttrs: {
          configureFlags = (oldAttrs.configureFlags or [ ]) ++ [
            "--disable-rbd"
          ];
        })).override
          {
            cephSupport = false;
            ceph = null;
          };

      qemu_full = final.qemu.override {
        # Since we're building qemu anyways, let's do it only for some ISAs
        hostCpuTargets = [
          "aarch64-softmmu"
          "riscv64-softmmu"
          "i386-softmmu" # not directly consumed but present for compatibility reasons
          "x86_64-softmmu"
        ];
      };
    })

    # Package overrides where no matter what, a given package is always used
    # from the stable channel, goes here.
    (final: prev: {
      google-cloud-sdk-gce = stablePkgs.google-cloud-sdk-gce;
    })

    # Custom (new) packages go here.
    (final: prev: {
      ubootRaspberryPiGeneric_64bit = prev.buildUBoot {
        defconfig = "rpi_arm64_defconfig";
        extraMeta.platforms = [ "aarch64-linux" ];
        filesToInstall = [ "u-boot.bin" ];
      };

      rpiUbootAndFirmware = prev.stdenvNoCC.mkDerivation {
        version = final.ubootRaspberryPiGeneric_64bit.version;
        name = "rpiUbootAndFirmware";
        dontUnpack = true;
        meta.platforms = [ "aarch64-linux" ];

        buildPhase = ''
          set -x

          mkdir $out
          cp -r ${prev.raspberrypifw}/share/raspberrypi/boot/* $out
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
