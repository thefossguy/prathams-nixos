{
  rustPlatform,
  fetchFromCodeberg,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "clanker-jail";
  version = "0.1.0-unstable-2026-09-04-e6fbdd";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "clanker-jail";
    rev = "e6fbdde65873ebc7e4e9dadc8ca376b4431be781";
    hash = "sha256-tnQeG2Xc4+F+J/jxwThDODI86r6F6GEw7tJOaX/fXv4=";
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
