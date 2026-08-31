{
  rustPlatform,
  fetchFromCodeberg,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "clanker-jail";
  version = "0.1.0-unstable-2026-08-31";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "clanker-jail";
    rev = "c71a350dde1c902818933a79208cd0fdc3139292";
    hash = "sha256-CjkF3+4Loe+9S21auiC7ceqg82IqJpcSu5mXiOzfqYc=";
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
