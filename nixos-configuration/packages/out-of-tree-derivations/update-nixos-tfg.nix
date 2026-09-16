{
  rustPlatform,
  fetchFromCodeberg,
  makeWrapper,
  lib,

  # PATH
  git,
  hostname-debian,
  nixos-rebuild-ng,
  util-linux,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "update-nixos-tfg";
  version = "0.1.0-unstable-2026-09-14";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "update-nixos-tfg";
    rev = "c290866444eafb9bc5ae078159baeea1b507d664";
    hash = "sha256-oS/Kl5OkZAC7gxEiyAASeNQVpc6WYSOotudVIEkUqsU=";
  };

  cargoHash = "sha256-/ML5So4h7xLgdOAzTvNAWiNeTPVmWdK7T5zUBfoCM8k=";

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/${finalAttrs.meta.mainProgram} \
      --prefix PATH : ${
        lib.makeBinPath [
          git
          hostname-debian
          nixos-rebuild-ng
          util-linux
        ]
      }
  '';

  meta = {
    homepage = "https://codeberg.org/thefossguy/update-nixos-tfg";
    description = "thefossguy's NixOS updater";
    mainProgram = "update-nixos-tfg";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thefossguy ];
    platforms = lib.platforms.linux;
  };
})
