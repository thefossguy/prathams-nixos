{
  pratham = {
    username = "pratham";
    fullname = "Pratham Patel";
    hashedPassword = "$y$j9T$dyQH1g6q6YjT.8lNruhJT.$xU2x3Phl3L6ey6tIWfmBlgHlCMrTnAxn9yD.a2/yS82";
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
    hashedPassword = "$y$j9T$22Zaxg0v1qrAceaTPmlCw1$X45iBxdEyuSN7ip36VNudgth48e1qhqzh5mijivsqR9";
    isRealUser = false;
  };
}
