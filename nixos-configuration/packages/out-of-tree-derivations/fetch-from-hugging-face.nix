{
  fetchurl,
  linkFarm,
}:

{
  owner,
  name,
  rev,
  filesToFetch,
}:

assert (filesToFetch != [ ]);

let
  fetchFromHuggingFace' =
    {
      asset,
      hash,
    }:
    fetchurl {
      url = "https://huggingface.co/${owner}}/${name}/resolve/${rev}/${asset}";
      inherit hash;
    };

  mkFetchedAsset = fileToFetchSet: {
    "${fileToFetchSet.target or fileToFetchSet.asset}" = fetchFromHuggingFace' {
      inherit (fileToFetchSet) asset hash;
    };
  };

  fetchedAssets = builtins.map (fileToFetchSet: mkFetchedAsset fileToFetchSet) filesToFetch;
in

linkFarm "${owner}-${name}-${rev}" fetchedAssets
