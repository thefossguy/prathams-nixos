{ config
, lib
, pkgs
, ...
}:

let
  userLocale = "en_IN";
  envLocale = "${userLocale}.UTF-8";
in

{
  time = {
    timeZone = "Asia/Kolkata";
    hardwareClockInLocalTime = true;
  };

  console = {
    enable = true;
    earlySetup = true;
  };

  i18n = {
    defaultLocale = "${userLocale}";
    extraLocaleSettings = {
      LC_ADDRESS = "${userLocale}";
      LC_IDENTIFICATION = "${userLocale}";
      LC_MEASUREMENT = "${userLocale}";
      LC_MONETARY = "${userLocale}";
      LC_NAME = "${userLocale}";
      LC_NUMERIC = "${userLocale}";
      LC_PAPER = "${userLocale}";
      LC_TELEPHONE = "${userLocale}";
      LC_TIME = "${userLocale}";
    };
  };

  environment = {
    homeBinInPath = true;
    localBinInPath = true;
    variables = {
      # for 'sudo -e'
      EDITOR = "nvim";
      VISUAL = "nvim";

      # systemd
      SYSTEMD_PAGER = "";
      SYSTEMD_EDITOR = "nvim";
      TERM = "xterm-256color";

      # set locale manually because even though NixOS handles the 'en_IN' locale
      # it doesn't append the string '.UTF-8' to LC_*
      # but, UTF-8 **is supported**, so just go ahead and set it manually
      LANG = lib.mkDefault "${envLocale}";
      LC_ADDRESS = lib.mkDefault "${envLocale}";
      LC_COLLATE = "${envLocale}";
      LC_CTYPE = "${envLocale}";
      LC_IDENTIFICATION = lib.mkDefault "${envLocale}";
      LC_MEASUREMENT = lib.mkDefault "${envLocale}";
      LC_MESSAGES = "${envLocale}";
      LC_MONETARY = lib.mkDefault "${envLocale}";
      LC_NAME = lib.mkDefault "${envLocale}";
      LC_NUMERIC = lib.mkDefault "${envLocale}";
      LC_PAPER = lib.mkDefault "${envLocale}";
      LC_TELEPHONE = lib.mkDefault "${envLocale}";
      LC_TIME = lib.mkDefault "${envLocale}";
      LC_ALL = "";

      # idk why, but some XDG vars aren't set, the missing ones are now set according to the
      # spec: (https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_STATE_HOME = "$HOME/.local/state";
      XDG_CACHE_HOME = "$HOME/.cache";

      NIXOS_MACHINE_HOSTNAME = config.networking.hostName;
      # for times when I am more adventurous than usual
      #KDIR_NIXOS = "${config.boot.kernelPackages.kernel.dev}/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/build";
    };
  };

  # yes, I want docs
  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    man = {
      enable = true;
      generateCaches = true;
    };
  };
}
