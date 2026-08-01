{
  callPackage,
  fetch-unsloth-quants,
}:

callPackage fetch-unsloth-quants {
  modelOwner = "unsloth";
  modelName = "DeepSeek-V4-Flash-0731-GGUF";
  revision = "109848da2469efe1f1aab9e11acea08a065ccd4f";
  quantName = "UD-IQ1_S";
  ggufSetList = [
    {
      name = "DeepSeek-V4-Flash-0731-UD-IQ1_S-00001-of-00003.gguf";
      hash = "sha256-L6FS4loUUA5C5tmPINIA7sHpRfNNwc+5gbZRuchrl74=";
    }
    {
      name = "DeepSeek-V4-Flash-0731-UD-IQ1_S-00002-of-00003.gguf";
      hash = "sha256-6fx3VEzUiqDDH78y/fVDLytWC5Kprv/Z9pDZmGfPDl8=";
    }
    {
      name = "DeepSeek-V4-Flash-0731-UD-IQ1_S-00003-of-00003.gguf";
      hash = "sha256-/ZnVzQUD1mi2/rwu7cydto4mTPt53TVe/IjBXqvkJI0=";
    }
  ];
}
