{ pkgs, ... }:

{
  imports = [
    ../modules/services/custom-home-manager-upgrade.nix
    ./common-home.nix
  ];

  nix = {
    package = pkgs.nix;
    checkConfig = true;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  news.display = "silent";
  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false; # no need to re-enable this, '--help' works
  };
}
