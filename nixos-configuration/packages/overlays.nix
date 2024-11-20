{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  stablePkgs = pkgsChannels.stable;
  unstablePkgs = pkgsChannels.unstable;

  # more chromium flags in ~/.local/scripts/other-common-scripts/flatpak-manage.sh
  commonChromiumFlags = if (!config.customOptions.displayServer.waylandEnabled) then [] else [
    "--disable-sync-preferences" # disable syncing chromium preferences with a sync account
    "--enable-features=TouchpadOverscrollHistoryNavigation" # enable two-finger swipe for forward/backward history navigation
    "--enable-features=UseOzonePlatform" # enable the Ozone Wayland thingy
  ];
in {
  nixpkgs.overlays = [
    # Actual overlays (package modifications) go here.
    (final: prev: {
      nerdfonts-tfg = prev.nerdfonts.override { fonts = [ "FiraCode" "Overpass" "SourceCodePro" ]; };

      mpv = prev.mpv.override { scripts = [ prev.mpvScripts.mpris ]; };
      mpv-unwrapped = prev.mpv-unwrapped.override { ffmpeg = prev.ffmpeg-full; };

      brave = prev.brave.override { commandLineArgs = commonChromiumFlags; };
      chromium = prev.chromium.override { commandLineArgs = commonChromiumFlags; enableWideVine = false; };
      ungoogled-chromium = prev.ungoogled-chromium.override { commandLineArgs = commonChromiumFlags; enableWideVine = false; };
    })


    # Package overrides where no matter what, a given package is always used
    # from the stable channel, goes here.
    (final: prev: {
      google-cloud-sdk-gce = stablePkgs.google-cloud-sdk-gce;
    })


    # Custom (new) packages go here.
    (final: prev: {
      ubootRaspberryPiGeneric_64bit = let
        version = "v2025.01-rc2";
        in unstablePkgs.buildUBoot {
          defconfig = "rpi_arm64_defconfig";
          extraMeta.platforms = [ "aarch64-linux" ];
          filesToInstall = [ "u-boot.bin" ];

          inherit version;
          src = prev.fetchFromGitHub {
            owner = "u-boot";
            repo = "u-boot";
            rev = version;
            hash = "sha256-ZdrPuOsWSvSZXP0dyJ6ROo52OJyaHpsISb2xcud0iEQ=";
          };
        };

      rpiUbootAndFirmware = prev.stdenvNoCC.mkDerivation {
        name = "rpiUbootAndFirmware";
        dontUnpack = true;
        meta.platforms = [ "aarch64-linux" ];

        buildPhase = ''
          set -x

          mkdir $out
          cp -r ${unstablePkgs.raspberrypifw}/share/raspberrypi/boot/* $out
          rm -vf $out/kernel*.img
          cp -r ${final.ubootRaspberryPiGeneric_64bit}/u-boot.bin $out/u-boot.bin

          cat << EOF > $out/config.txt
          # http://rptl.io/configtxt
          arm_64bit=1
          enable_uart=1
          kernel=u-boot.bin
          disable_fw_kms_setup=1
          disable_splash=0
          display_auto_detect=1
          dtoverlay=vc4-kms-v3d
          dtparam=audio=on
          enable_tvout=0
          max_framebuffers=2

          [pi4]
          arm_boost=1
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