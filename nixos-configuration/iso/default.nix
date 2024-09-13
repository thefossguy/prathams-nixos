{ config, lib, modulesPath, pkgs, nixosSystem, ... }:

let
  isoZfsString = if nixosSystem.enableZfs
    then "zfs-"
    else "";
  isoKernelPackage = if nixosSystem.enableZfs
    then pkgs."${nixosSystem.latestLtsKernel}"
    else pkgs."${nixosSystem.latestStableKernel}";
  isoSupportedFilesystems = nixosSystem.supportedFilesystemsSansZFS ++ (if nixosSystem.enableZfs
    then [ "zfs" ]
    else []);
in {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../modules/qemu/qemu-guest.nix
    ../modules/local-nix-cache/nix-conf.nix
    ../modules/misc-imports/ether-dev-names-with-mac-addr.nix
  ];

  environment.systemPackages = pkgs.callPackage ./packages.nix {};
  boot = {
    kernelPackages = isoKernelPackage;
    supportedFilesystems = lib.mkForce isoSupportedFilesystems;
    blacklistedKernelModules = [ "nvidia" "nouveau" ]; # since it's hard to combine copytoram+nomodeset
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.max-jobs = 1;
  time.timeZone = "Asia/Kolkata";
  users.users."nixos".initialHashedPassword = lib.mkForce "$y$j9T$dNGwIUpZQhc0aS5003TW/0$odAB.8V8YPU15.FVHCY8IcnxFWUrxuDcUxyPjoYke80";
  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkForce false; # this enabled 'wpa_supplicant', use networkmanager instead
  isoImage.isoName = lib.mkForce "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${config.boot.kernelPackages.kernel.version}-${isoZfsString}${pkgs.stdenv.hostPlatform.system}.iso";

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    swapDevices = 2;
  };

  #isoImage.squashfsCompression = "zstd -Xcompression-level 22"; # for prod
  isoImage.squashfsCompression = "lz4 -b 32768"; # for dev
}
