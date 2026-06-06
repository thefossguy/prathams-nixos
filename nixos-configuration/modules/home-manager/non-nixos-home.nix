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
    ../base-config/nix-config.nix
    ./common-home.nix
    ./darwin-home.nix
    ./linux-home.nix
  ];

  nixpkgs.config.allowUnfreePredicate = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "google-chrome"
      "keka"
    ]
  );

  news.display = "silent"; # I'll fix it when a build fails.
  manual = {
    html.enable = lib.mkForce false;
    json.enable = lib.mkForce false;
    manpages.enable = lib.mkForce false; # The `--help` option works.
  };

  nix.gc.dates = "weekly";
}
