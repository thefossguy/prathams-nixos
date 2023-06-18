{ config, pkgs, ... }:

{
  users = {
    mutableUsers = true;
    allowNoPasswordLogin = false;
    defaultUserShell = pkgs.bash;
    enforceIdUniqueness = true;

    users = {
      root = {
        hashedPassword = "$6$cxSzljtGpFNLRhx1$0HvOs4faEzUw9FYUF8ifOwBPwHsGVL7HenQMCOBNwqknBFHSlA6NIDO7U36HeQ/C9FN/B.dP.WBg3MzqQcubr0";
      };
      pratham = {
        isNormalUser = true;
        description = "Pratham Patel";
        createHome = true;
        home = "/home/pratham";
        group = "pratham";
        shell = pkgs.fish;
        hashedPassword = "$6$QLxAJcAeYARWFnnh$MaicewslNWkf/D8o6lDAWA1ECLMZLL3KWgIqPKuu/Qgt3iDBCEbEFjt3CUI4ENifvXW/blpze8IYeWhDjaKgS1";
        extraGroups = [
          "adm"
          "ftp"
          "games"
          "http"
          "kvm"
          "libvirt"
          "libvirtd"
          "log"
          "networkmanager"
          "podman"
          "rfkill"
          "sys"
          "systemd-journal"
          "thefossguy"
          "uucp"
          "video"
          "wheel"
          "zfs-read"
        ];
        packages = with pkgs; [
          fish
          fishPlugins.async-prompt
          fishPlugins.colored-man-pages
          fishPlugins.puffer # expand stuff like '....' to '../..', '!!' to prev cmd and more
          fishPlugins.sponge # only saves commands in history that exited with 0
        ];
      };
      thefossguy = {
        isNormalUser = true;
        description = "The F. Guy";
        createHome = true;
        home = "/home/thefossguy";
        group = "thefossguy";
        hashedPassword = "$6$8YXuC06/uXEs.ZrP$6MbED.kQ8rM/ry2f6tofn13uN5gNiQBtXuAjrxpCjo.ztohPgUg3oH8o0ZThF3j18Uh3oHFJY4hjG9M0tC8Sa/";
        extraGroups = [
          "podman"
          "zfs-read"
        ];
      };
    };
    groups.pratham.name = "pratham";
    groups.thefossguy.name = "thefossguy";
  };

  programs.fish.enable = true;
  programs.zsh.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
    extraRules = [{
      users = [ "pratham" ];
      commands = [
        {
          command = "${pkgs.util-linux}/bin/dmesg";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/systemctl";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.picocom}/bin/picocom";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.nix}/bin/nix-collect-garbage";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.hdparm}/bin/hdparm";
          options = [ "NOPASSWD" ];
        }
        #{
        #  command = "ALL";
        #  options = [ "NOPASSWD" ];
        #}
      ];
    }];
  };
}
