{
  callPackage,
  fetch-unsloth-quants,
}:

callPackage fetch-unsloth-quants {
  modelOwner = "unsloth";
  modelName = "DeepSeek-V4-Flash-0731-GGUF";
  revision = "fbbb5b93fb787c21338159b0af3318bb3f4d9768";
  quantName = "UD-Q8_K_XL";
  extraFiles = [
    {
      name = "dspark-DeepSeek-V4-Flash-0731-Q8_0.gguf";
      hash = "sha256-LHrFSwtkqZ3x8Tmp8TcaABmCZeHWphS3dZfSCmVaQkk=";
    }
  ];
  ggufSetList = [
    {
      name = "DeepSeek-V4-Flash-0731-UD-Q8_K_XL-00001-of-00005.gguf";
      hash = "sha256-0Tzo+QhVVHva6+cxL1MaHyxPgiF40xA5UfJ/6IQ5XPo=";
    }
    {
      name = "DeepSeek-V4-Flash-0731-UD-Q8_K_XL-00002-of-00005.gguf";
      hash = "sha256-PaLyRDBj+DY1mG+bZ/p+jj0DxTuBqaCNIAeTZhJCNhA=";
    }
    {
      name = "DeepSeek-V4-Flash-0731-UD-Q8_K_XL-00003-of-00005.gguf";
      hash = "sha256-fWIqd2DTWeySV7NJOtUx478L++b2UzJn4W5t3oFT3c4=";
    }
    {
      name = "DeepSeek-V4-Flash-0731-UD-Q8_K_XL-00004-of-00005.gguf";
      hash = "sha256-btK85FIhTxVrhefF99T8JCowUvQJ0bkKYUIvYGacLeM=";
    }
    {
      name = "DeepSeek-V4-Flash-0731-UD-Q8_K_XL-00005-of-00005.gguf";
      hash = "sha256-6kcnr0iI/coP/3luyBrC8+u0PDELL+tHmPQdgnRLQuo=";
    }
  ];
}
