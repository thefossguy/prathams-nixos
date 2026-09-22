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
  version = "0.1.5";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "update-uboot-tfg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5GZTOG5OevS6UB6UAoRN6uy/mu5OfGtFh/vk5pp5dCk=";
  };

  cargoHash = "sha256-df7daxjegWMv+blT6+niSxpWtb9HZTViJryQj1c22FQ=";

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
