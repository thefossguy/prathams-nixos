{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  # These overlays are meant to be temporary.
  # They are in this file to not pollute the `git-blame` on the actual
  # `overlay.nix` file.
  nixpkgs.overlays = [
    (final: prev: {
      landrun = prev.landrun.overrideAttrs (oldAttrs: {
        patches = (prev.patches or [ ]) ++ [
          (pkgs.fetchpatch {
            url = "https://github.com/Zouuup/landrun/commit/b7100d0a3adb86c0374f161f862e3067efacc790.patch";
            hash = "sha256-umFaSjfxfr82ORVGD7DmsLbziJq8zdMp4q199yySWWI=";
          })
        ];
      });
    })
  ];
}
