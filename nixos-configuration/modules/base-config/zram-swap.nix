{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  swapDevices = [
    {
      device = "/swapfile";
      size = 1024 * 16; # 16 GiB
    }
  ];

  # zram and zswap better not be used at the same time
  # <https://chrisdown.name/2026/03/24/zswap-vs-zram-when-to-use-what.html>
  zramSwap.enable = lib.mkForce false;
  boot.kernelParams = [
    "zswap.enabled=1"
    # Use zstd in favour of more widely used lz4 to get higher
    # compression ratio by loosing just a little in decompression speed.
    # <https://indico.fnal.gov/event/16264/contributions/36466/attachments/22610/28037/Zstd__LZ4.pdf>
    "zswap.compressor=zstd"
    "zswap.max_pool_percent=20" # maximum percentage of RAM that zswap is allowed to use
    "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
  ];
}
