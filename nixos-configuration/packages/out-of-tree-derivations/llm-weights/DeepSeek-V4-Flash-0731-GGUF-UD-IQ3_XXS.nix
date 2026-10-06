{
  callPackage,
  fetch-unsloth-quants,
}:

callPackage fetch-unsloth-quants {
  modelOwner = "unsloth";
  modelName = "DeepSeek-V4-Flash-0731-GGUF";
  revision = "fbbb5b93fb787c21338159b0af3318bb3f4d9768";
  quantName = "UD-IQ3_XXS";
  extraFiles = [
    {
      name = "dspark-DeepSeek-V4-Flash-0731-Q8_0.gguf";
      hash = "sha256-LHrFSwtkqZ3x8Tmp8TcaABmCZeHWphS3dZfSCmVaQkk=";
    }
  ];
  ggufSetList = [
    {
      name = "DeepSeek-V4-Flash-0731-UD-IQ3_XXS-00001-of-00004.gguf";
      hash = "sha256-3sHO5wSAAmfZ2DbVphrvwzcFvpObuzBY+pAG2YGRV20=";
    }
    {
      name = "DeepSeek-V4-Flash-0731-UD-IQ3_XXS-00002-of-00004.gguf";
      hash = "sha256-MGTTxMHWNj6fmtiOkKPixfstb3rhbKchNcPOalyYTaU=";
    }
    {
      name = "DeepSeek-V4-Flash-0731-UD-IQ3_XXS-00003-of-00004.gguf";
      hash = "sha256-LpsnMuyn2oMk9zFlNiSk9cmEYliSb9n0aMxwOvtRoBk=";
    }
    {
      name = "DeepSeek-V4-Flash-0731-UD-IQ3_XXS-00004-of-00004.gguf";
      hash = "sha256-TKedjlEH3RubtXsXanwJlIg3Ql3uSfDx39ZUejdp/qc=";
    }
  ];
}
