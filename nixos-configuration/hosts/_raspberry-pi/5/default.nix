{ lib, pkgs, nixpkgs, ... }:

let
  tag = "stable_20240423";
  linux_rpi5 = pkgs.linux_rpi4.override {
    rpiVersion = 5;

    argsOverride = rec {
      version = "${modDirVersion}-${tag}";
      modDirVersion = "6.6.28";

      defconfig = "bcm2712_defconfig";

      src = pkgs.fetchFromGitHub {
        owner = "raspberrypi";
        repo = "linux";
        rev = tag;
        hash = "sha256-mlsDuVczu0e57BlD/iq7IEEluOIgqbZ+W4Ju30E/zhw=";
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

  #boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor linux_rpi5);
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
}
