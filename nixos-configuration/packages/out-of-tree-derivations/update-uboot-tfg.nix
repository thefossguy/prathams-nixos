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
  version = "0.1.4";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "update-uboot-tfg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M/rTcUxvuUcyVc94tHXqX8NrC3GJi9z71IZQ2JMEohE=";
  };

  cargoHash = "sha256-0scZaQPBtVpfWwScLP0MoaLH4B2DVxBwBbpN3Px0eWc=";

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
