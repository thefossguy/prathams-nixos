{
  rustPlatform,
  fetchFromCodeberg,
  makeWrapper,
  lib,

  # PATH
  coreutils-full,
  mtdutils,
  util-linux,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "update-uboot-tfg";
  version = "0.1.2";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "update-uboot-tfg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-y0aWBB9haJs3Y508lPFTmB3DGQyUeaskWA0jp8ovP94=";
  };

  cargoHash = "sha256-yGE9FKAWxupYxPpm33u+aPGhlL+F5gesNiQck2haxNE=";

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/${finalAttrs.meta.mainProgram} \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils-full
          mtdutils
          util-linux
        ]
      }
  '';

  meta = {
    homepage = "https://codeberg.org/thefossguy/update-uboot-tfg";
    description = "thefossguy's U-Boot updater";
    mainProgram = "update-uboot-tfg";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thefossguy ];
    platforms = lib.platforms.linux;
  };
})
