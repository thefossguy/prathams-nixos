{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "navya-ci";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "thefossguy";
    repo = "navya-ci";
    tag = "v${finalAttrs.version}";
    hash = "sha256-O9wtZv2NAXq9SMhaNCvnpqiHQlZMAerKHdwXZ7/S3aY=";
  };

  cargoHash = "sha256-YOUx1HoqQbLDQBR8U+ZDoPBcFCXpBk7mic5r/5FU5IA=";

  meta = {
    homepage = "https://codeberg.org/thefossguy/navya-ci";
    description = "A scriptable Nix CI as a Rust program";
    mainProgram = "navya-ci";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thefossguy ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
