{
  rustPlatform,
  fetchFromCodeberg,
  lib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clanker-jail";
  version = "0.1.1";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "clanker-jail";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MT0dCYhtLEoTsgPsiD9/K3yKlLBlsXsjCBRheILggDI=";
  };

  cargoHash = "sha256-cu6INMWAIaFYrV7gLsuSEGoAlEsjB0ntACnVqZbvdek=";

  meta = {
    homepage = "https://codeberg.org/thefossguy/clanker-jail";
    description = "Jail a clanker";
    mainProgram = "clanker-jail";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thefossguy ];
    platforms = lib.platforms.linux;
  };
})
