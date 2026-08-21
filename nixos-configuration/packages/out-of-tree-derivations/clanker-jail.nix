{
  rustPlatform,
  fetchFromCodeberg,
}:

rustPlatform.buildRustPackage {
  pname = "clanker-jail";
  version = "0.1.0-unstable-2026-08-21";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "clanker-jail";
    rev = "231f73fae0ddeed0d4b0a6e3c5987451a37050b1";
    hash = "sha256-LZdS2RqVv5taFBoG7o7KA0LYo9NNw1YH4q0PMwA4JAw=";
  };

  cargoHash = "sha256-+7lbQHuKWjRLtbsDKA0+m598XnIodOlwRgYXkT3cGdM=";

  meta.mainProgram = "clanker-jail";
}
