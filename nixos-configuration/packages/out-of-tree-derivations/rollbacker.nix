{
  rustPlatform,
  fetchFromCodeberg,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "rollbacker";
  version = "0.1.0-unstable-2026-09-09";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "rollbacker";
    rev = "c2523337302d7598d332aa41dbf3fe3d3fe1ab14";
    hash = "sha256-m52ANe3bj16SPogH7i4JsTHsOqH3tdWeq4zI8dvhnI4=";
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
