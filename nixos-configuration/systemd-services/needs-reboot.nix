{ pkgs, ... }:

{
  systemd = {
    services."needs-reboot" = {
      enable = true;
      after = [ "custom-nixos-upgrade.service" ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      path = with pkgs; [
        nix
      ];

      script = ''
        set -xuf -o pipefail

        old_paths=$(nix-store --query --requisites /run/booted-system           | cut -c45- | uniq | sort)
        new_paths=$(nix-store --query --requisites /nix/var/nix/profiles/system | cut -c45- | uniq | sort)

        packages_to_check=(
            'linux'
            'neovim'
            'openssh'
            'systemd'
        )

        linux_regex='^linux-[0-9]\+.[0-9]\+.[0-9]\+$'
        neovim_regex='^neovim-[0-9]\+.[0-9]\+.[0-9]\+$'
        openssh_regex='^openssh-[0-9]\+.[0-9]\+\(p[0-9]\+\)\?$'
        systemd_regex='^systemd-[0-9]\+.[0-9]\+$'

        for package in "''${packages_to_check[@]}"; do
            current_regex="''${package}_regex"
            old_version="$(echo "''${old_paths}" | grep "''${!current_regex}")"
            new_version="$(echo "''${new_paths}" | grep "''${!current_regex}")"

            if [[ "''${old_version}" != "''${new_version}" ]]; then
                echo "''${package}" | tee /var/run/reboot-required
                exit 0
            fi
        done
      '';
    };
  };
}
