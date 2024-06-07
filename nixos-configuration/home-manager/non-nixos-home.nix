{ config, lib, pkgs, systemUser, ... }:

{
  imports = [
    ./common-home.nix
    ../systemd-services/upgrade-my-home.nix
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
