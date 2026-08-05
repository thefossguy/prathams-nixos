{
  callPackage,
  fetch-unsloth-quants,
}:

callPackage fetch-unsloth-quants {
  modelOwner = "unsloth";
  modelName = "DeepSeek-V4-Flash-0731-GGUF";
  revision = "109848da2469efe1f1aab9e11acea08a065ccd4f";
  quantName = "UD-IQ1_M";
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
