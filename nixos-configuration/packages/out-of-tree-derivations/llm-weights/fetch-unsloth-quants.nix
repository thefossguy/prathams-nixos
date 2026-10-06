{
  fetchurl,
  linkFarm,

  modelOwner,
  modelName,
  revision,
  quantName,
  ggufSetList,
  extraFiles ? [ ],
}:

let
  fetchFromHuggingFace =
    {
      asset,
      hash,
    }:
    fetchurl {
      url = "https://huggingface.co/${modelOwner}/${modelName}/resolve/${revision}/${asset}";
      inherit hash;
    };

  finalGGUFSetList = builtins.map (ggufSet: {
    inherit (ggufSet) name;
    path = fetchFromHuggingFace {
      asset = "${quantName}/${ggufSet.name}";
      inherit (ggufSet) hash;
    };
  }) ggufSetList;

  finalExtraFilesList = builtins.map (extraFilesSet: {
    inherit (extraFilesSet) name;
    path = fetchFromHuggingFace {
      asset = extraFilesSet.name;
      inherit (extraFilesSet) hash;
    };
  }) extraFiles;

  finalFilesList = finalGGUFSetList ++ finalExtraFilesList;
in
linkFarm "${modelOwner}-${modelName}-${quantName}-${revision}" finalFilesList
