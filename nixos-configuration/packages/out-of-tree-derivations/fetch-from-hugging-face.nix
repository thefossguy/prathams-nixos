{
  lib,
  fetchurl,
  linkFarm,
}:

{
  owner,
  name,
  rev,
  assetsToFetch,
}:

assert (assetsToFetch != [ ]);

let
  fetchFromHuggingFace' =
    {
      asset,
      hash,
    }:
    fetchurl {
      url = "https://huggingface.co/${owner}/${name}/resolve/${rev}/${asset}";
      inherit hash;
    };

  mkFetchedAsset = assetToFetchSet: {
    "${assetToFetchSet.target or assetToFetchSet.asset}" = fetchFromHuggingFace' {
      inherit (assetToFetchSet) asset hash;
    };
  };

  fetchedAssets = builtins.map (assetToFetchSet: mkFetchedAsset assetToFetchSet) assetsToFetch;

  linkFarmSet = builtins.foldl' lib.attrsets.unionOfDisjoint { } fetchedAssets;
in

linkFarm "${owner}-${name}-${rev}" linkFarmSet
