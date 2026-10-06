{
  callPackage,
  fetch-unsloth-quants,
}:

callPackage fetch-unsloth-quants {
  modelOwner = "unsloth";
  modelName = "DeepSeek-V4-Flash-0731-GGUF";
  revision = "fbbb5b93fb787c21338159b0af3318bb3f4d9768";
  quantName = "UD-IQ1_M";
  extraFiles = [
    {
      name = "dspark-DeepSeek-V4-Flash-0731-Q8_0.gguf";
      hash = "sha256-LHrFSwtkqZ3x8Tmp8TcaABmCZeHWphS3dZfSCmVaQkk=";
    }
  ];
  ggufSetList = [
    {
      name = "DeepSeek-V4-Flash-0731-UD-IQ1_M-00001-of-00003.gguf";
      hash = "sha256-uZ+iRqEICBRuAKfpCMaFIJik8IOU6r+LN8kmOZOYCmk=";
    }
    {
      name = "DeepSeek-V4-Flash-0731-UD-IQ1_M-00002-of-00003.gguf";
      hash = "sha256-yFNhh7Dl2+cea79ghuDTtJHNMdYNplIt/vB0EzwO4u4=";
    }
    {
      name = "DeepSeek-V4-Flash-0731-UD-IQ1_M-00003-of-00003.gguf";
      hash = "sha256-gKTrTuvFdZjZVZwpJAVNQNafUXc66HNTiTk4LhILPj8=";
    }
  ];
}
