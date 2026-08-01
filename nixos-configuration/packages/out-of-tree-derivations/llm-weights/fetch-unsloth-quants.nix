{
  extendMkDerivation,
  stdenvNoCC,
  fetchurl,
  linkFarm,
}:

extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;

  extendDrvArgs =
    {
      modelOwner,
      modelName,
      revision,
      quantName,
      ggufSetList,
    }:
    let
      finalGGUFSetList = builtins.map (ggufSet: {
        inherit (ggufSet) name;
        path = fetchurl {
          url = "https://huggingface.co/${modelOwner}/${modelName}/resolve/${revision}/${quantName}/${ggufSet.name}";
          inherit (ggufSet) name hash;
        };
      }) ggufSetList;
    in
    linkFarm "${modelOwner}-${modelName}-${quantName}-${revision}" finalGGUFSetList;
}
