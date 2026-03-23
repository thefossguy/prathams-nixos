{
  pratham = {
    username = "pratham";
    fullname = "Pratham Patel";
    hashedPassword = "$y$j9T$S3vYlSr3Fc.Q4s3khoj5R0$.ZaDUNDFl1/./thA2AdilcvtzoVO1IafiC7AcgUAGC6";
    isRealUser = true;
  };

  # The `ppatel` user is on the nix-community builders
  # So no attributes other than `username` and `isRealUser` need to be defined.
  thefossguy = {
    username = "thefossguy";
    isRealUser = true;
  };

  # The `ppatel` user is on my work MBP which is an `aarch64-darwin` machine.
  # So no attributes other than `username` and `isRealUser` need to be defined.
  ppatel = {
    username = "ppatel";
    isRealUser = true;
  };

  # User for the NixOS ISO
  iso = {
    username = "nixos";
    hashedPassword = "$y$j9T$JHdlW4/3NS8UrjquQX6WE0$Y37cfGSMQS5QhIvJG02dtb96hzjrkr8HhsvuCwdznaA";
    isRealUser = false;
  };
}
