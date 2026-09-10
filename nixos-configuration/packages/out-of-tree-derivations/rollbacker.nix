{
  rustPlatform,
  fetchFromCodeberg,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "rollbacker";
  version = "0.1.0-unstable-2026-09-10-795c41";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "rollbacker";
    rev = "795c41805116a9d734f255a0e4d677167618e0ea";
    hash = "sha256-ZGc4JlGv6p7wRmRYcBmGjcYsYvy9SYaJ0DEfyI3Yojc=";
  };

  cargoHash = "sha256-p7x39XJQVrWPCnj8uX29sBiEsXsmAYtpxvYwluhrXKI=";

  postInstall = ''
    install -Dm644 nixos/module.nix $out/nixos/module.nix
  '';

  meta = {
    homepage = "https://codeberg.org/thefossguy/rollbacker";
    description = "rollbacker? I hardly know 'er!";
    mainProgram = "rollbacker";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thefossguy ];
    platforms = lib.platforms.linux;
  };
}
