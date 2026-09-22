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
  version = "0.1.3";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "update-uboot-tfg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IBFQwxHFtaMMWzvvQQqF4Gqf1nZr6Res+FxXI7eK77Q=";
  };

  cargoHash = "sha256-pS4u1zyERFSjTpcfVyAHT3F3RT8DoAk5BvlCUpnU/Wc=";

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
