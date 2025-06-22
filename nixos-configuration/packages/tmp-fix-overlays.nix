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
in
{
  # These overlays are meant to be temporary.
  # They are in this file to not pollute the `git-blame` on the actual
  # `overlay.nix` file.
  nixpkgs.overlays = [
    (final: prev: {
    })
  ];
}
