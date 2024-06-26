{ lib, pkgs, nixpkgs, ... }:

let
  linux_rpi5 = pkgs.linux_rpi4.override {
    rpiVersion = 5;

    argsOverride = rec {
      version = "${modDirVersion}-vendor-rpi5-16k";
      modDirVersion = "6.6.35";

      defconfig = "bcm2712_defconfig"; # only difference between this and 'bcm2711_defconfig' is 16K pages

      src = pkgs.fetchFromGitHub {
        owner = "raspberrypi";
        repo = "linux";
        rev = "d2813c02131b9ddf938277f4123da7ccbd113ea7";
        hash = "sha256-pzjgCWG9FhMU3LCZnvz5N4jYfaaJQDT6Pv5lD/3zsm4=";
      };

      kernelPatches = [
        { name = "bridge_stp_helper";  patch = (nixpkgs.outPath + "/pkgs/os-specific/linux/kernel/bridge-stp-helper.patch"); }
        { name = "request_key_helper"; patch = (nixpkgs.outPath + "/pkgs/os-specific/linux/kernel/request-key-helper.patch"); }
      ];

      features.efiBootStub = lib.mkForce false;
    };
  };
in {
  imports = [ ../common/default.nix ];

  boot = {
    kernelPackages = lib.mkForce (pkgs.linuxPackagesFor linux_rpi5);
    initrd.availableKernelModules = [
      "nvme"
      "usbhid"
      "usb_storage"
    ];
  };
}
