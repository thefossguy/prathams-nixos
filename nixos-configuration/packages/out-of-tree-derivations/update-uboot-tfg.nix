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
  version = "0.1.6";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "update-uboot-tfg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-81Il2Jp6kKZ6OkD/9fX3IsKDtWyuFUV8p20y69hRA58=";
  };

  cargoHash = "sha256-u2LUiobFM6KzQuWnT8QIVMRGtYQ2T6mD9BEsLR3PaOw=";

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
