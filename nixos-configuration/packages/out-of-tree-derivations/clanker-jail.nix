{
  rustPlatform,
  fetchFromCodeberg,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "clanker-jail";
  version = "0.1.0-unstable-2026-09-04";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "clanker-jail";
    rev = "a9f9c50dd37bb1d4bee09c68256f9440ebe03122";
    hash = "sha256-ZHwqSiPyrojNxvJKqlUncOoSgHj8wEgLt0hCCDnRViE=";
  };

  cargoHash = "sha256-+7lbQHuKWjRLtbsDKA0+m598XnIodOlwRgYXkT3cGdM=";

  meta = {
    homepage = "https://codeberg.org/thefossguy/clanker-jail";
    description = "Jail a clanker";
    mainProgram = "clanker-jail";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thefossguy ];
    platforms = lib.platforms.linux;
  };
}
