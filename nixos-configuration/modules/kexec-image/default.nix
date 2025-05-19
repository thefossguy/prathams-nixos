{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  options = {
    customOptions.finalBuildTarget = lib.mkOption {
      description = "A shorthand build target that builds the final target for NixOS system and the ISO.";
      type = lib.types.package;
      default = config.system.build.kexecTree;
    };

  };

  # A lot of these options are duplicated but the initial attempt is to
  # get a working configuration.
  config = {
    boot.kernelParams = [
      # Helps on aarch64-linux **and** x86_64-linux
      "console=tty0"
      "console=ttyS0"
    ];

    environment.systemPackages = pkgs.callPackage ../iso/packages.nix { inherit pkgs; };
    services.openssh.enable = true;
    users.users."root".initialHashedPassword = lib.mkForce config.users.users."root".hashedPassword;
    users.users."root".hashedPassword =
      lib.mkForce "$y$j9T$UWnNglmaKUq7/srkYYfl5/$mPq5GlbqmxRKuOMOYrgEa4O.M48g40OVIB0xpfftZhC";
    nix = {

      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        max-jobs = 1;
        sandbox = true;
        show-trace = true;
      };
    };
  };
}
