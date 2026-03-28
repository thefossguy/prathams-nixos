{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "navya-ci";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "thefossguy";
    repo = "navya-ci";
    tag = "v${finalAttrs.version}";
    hash = "sha256-El9bRjSeA71GJntbGRQf280grYoOxCX3PsNddSdMfto=";
  };

  cargoHash = "sha256-50QcU11nI3WcK6v7PmWSQi98V3lzqqQyHUZhQRJvrkk=";

  meta = {
    homepage = "https://codeberg.org/thefossguy/navya-ci";
    description = "A scriptable Nix CI as a Rust program";
    mainProgram = "navya-ci";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thefossguy ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
