{
  fetchFromHuggingFace,
}:

fetchFromHuggingFace {
  owner = "unsloth";
  model = "DeepSeek-V4-Flash-0731-GGUF";
  rev = "fbbb5b93fb787c21338159b0af3318bb3f4d9768";

  assetsToFetch = [
    {
      asset = "dspark-DeepSeek-V4-Flash-0731-Q8_0.gguf";
      hash = "sha256-LHrFSwtkqZ3x8Tmp8TcaABmCZeHWphS3dZfSCmVaQkk=";
    }
    {
      asset = "UD-IQ3_XXS/DeepSeek-V4-Flash-0731-UD-IQ3_XXS-00001-of-00004.gguf";
      hash = "sha256-3sHO5wSAAmfZ2DbVphrvwzcFvpObuzBY+pAG2YGRV20=";
    }
    {
      asset = "UD-IQ3_XXS/DeepSeek-V4-Flash-0731-UD-IQ3_XXS-00002-of-00004.gguf";
      hash = "sha256-MGTTxMHWNj6fmtiOkKPixfstb3rhbKchNcPOalyYTaU=";
    }
    {
      asset = "UD-IQ3_XXS/DeepSeek-V4-Flash-0731-UD-IQ3_XXS-00003-of-00004.gguf";
      hash = "sha256-LpsnMuyn2oMk9zFlNiSk9cmEYliSb9n0aMxwOvtRoBk=";
    }
    {
      asset = "UD-IQ3_XXS/DeepSeek-V4-Flash-0731-UD-IQ3_XXS-00004-of-00004.gguf";
      hash = "sha256-TKedjlEH3RubtXsXanwJlIg3Ql3uSfDx39ZUejdp/qc=";
    }
  ];
}
