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
      asset = "UD-IQ1_M/DeepSeek-V4-Flash-0731-UD-IQ1_M-00001-of-00003.gguf";
      hash = "sha256-uZ+iRqEICBRuAKfpCMaFIJik8IOU6r+LN8kmOZOYCmk=";
    }
    {
      asset = "UD-IQ1_M/DeepSeek-V4-Flash-0731-UD-IQ1_M-00002-of-00003.gguf";
      hash = "sha256-yFNhh7Dl2+cea79ghuDTtJHNMdYNplIt/vB0EzwO4u4=";
    }
    {
      asset = "UD-IQ1_M/DeepSeek-V4-Flash-0731-UD-IQ1_M-00003-of-00003.gguf";
      hash = "sha256-gKTrTuvFdZjZVZwpJAVNQNafUXc66HNTiTk4LhILPj8=";
    }
  ];
}
