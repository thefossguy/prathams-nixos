{
  rustPlatform,
  fetchFromCodeberg,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "rollbacker";
  version = "0.1.0-unstable-2026-09-10";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "rollbacker";
    rev = "bb13b3a124e19ee40bacebcbfa5cc3df5d41cbef";
    hash = "sha256-gzW1Kfm0KOm7S7i8epMCTyAirADC2e2LD2V2IHwiCQE=";
  };

  cargoHash = "sha256-p7x39XJQVrWPCnj8uX29sBiEsXsmAYtpxvYwluhrXKI=";

  meta = {
    homepage = "https://codeberg.org/thefossguy/rollbacker";
    description = "rollbacker? I hardly know 'er!";
    mainProgram = "rollbacker";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thefossguy ];
    platforms = lib.platforms.linux;
  };
}
