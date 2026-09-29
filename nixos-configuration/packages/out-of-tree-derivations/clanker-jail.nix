{
  rustPlatform,
  fetchFromCodeberg,
  lib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clanker-jail";
  version = "0.1.2";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "clanker-jail";
    tag = "v${finalAttrs.version}";
    hash = "sha256-c2Z4UxjJmxGx8Nq2HItLlF9wEtQLPobKUa7uDAIka08=";
  };

  cargoHash = "sha256-c6JIaJs9UVyyQSZXWN0ALrd6xCFPnwaXkz77Epq9oZ0=";

  meta = {
    homepage = "https://codeberg.org/thefossguy/clanker-jail";
    description = "Jail a clanker";
    mainProgram = "clanker-jail";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thefossguy ];
    platforms = lib.platforms.linux;
  };
})
