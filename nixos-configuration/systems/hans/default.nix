{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  imports = [
    ../../modules/host-modules/firewall-rules.nix
    ../../modules/qemu/qemu-guest.nix
    ../../modules/services/user/git-mirroring.nix
    ./hardware-configuration.nix
  ];

  boot.kernelParams = [ "console=tty" ];
  services.nix-serve.secretKeyFile = lib.mkForce null;
  zramSwap.enable = lib.mkForce false;

  # setup secondary user for SSH pushes
  users = {
    groups."git" = {
      name = "git";
      gid = 9000;
    };
    users."git" = {
      createHome = true;
      group = "git";
      hashedPassword = "!"; # disable password loggin in
      home = "/home/git";
      isNormalUser = true;
      isSystemUser = false;
      linger = true;
      uid = 9000;
      useDefaultShell = true;
    };
  };

  customOptions = {
    dhcpConfig = "ipv6";
    localCaching.servesNixDerivations = true;
    useAlternativeSSHPort = true;
    useMinimalConfig = lib.mkForce false;
  };
}
