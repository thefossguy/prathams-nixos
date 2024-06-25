{ pkgs, ... }:

let
  gitUser = {
    username = "git";
    homeDir = "/home/${gitUser.username}";
  };

  gitUpstreamAuthKeyName = "ssh";
  gitUpstreamAuthKeyPath = "${gitUser.homeDir}/.ssh/${gitUpstreamAuthKeyName}";
  gitRepoStore = "${gitUser.homeDir}/my-git-repos/";

  connectivityCheckScript = origin: import ../../includes/misc-imports/check-network.nix {
    internetEndpoint = "${origin}.com";
    inherit pkgs;
  };

  mkGitPushTimer = origin: {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "now";
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "push-to-origin-${origin}.service";
    };
  };

  mkGitPushService = origin: {
    after = [ "ssh-keys-sanity-check.service" ];
    requires = [ "ssh-keys-sanity-check.service" ];
    serviceConfig = { Type = "oneshot"; User = "${gitUser.username}"; };
    path = with pkgs; [ git openssh iputils ];

    script = ''
      set -xeuf -o pipefail

      ${connectivityCheckScript "${origin}"}

      [[ ! -d ${gitRepoStore} ]] && mkdir -p ${gitRepoStore}
      for gitDir in $(find ${gitRepoStore} -depth -maxdepth 2 -mindepth 2 -type d); do
          pushd "''${gitDir}"

          git config remote.origin.url 2>&1 >/dev/null && \
              git remote rm origin

          ORIGIN_PATH="''${gitDir#${gitRepoStore}}"
          git config remote.${origin}.url 2>&1 >/dev/null || \
              # we use '--mirror=push' to set it as a mirror once and for all
              # and not specify '--mirror' when pushing
              git remote add ${origin} git@${origin}.com:"''${ORIGIN_PATH}" --mirror=push

          # 1. Specify SSH private key to use
          # 2. `StrictHostKeyChecking=no` because we are **pushing** ;)
          GIT_SSH_COMMAND="ssh -i ${gitUpstreamAuthKeyPath} -o StrictHostKeyChecking=no" git push ${origin}
          popd
      done
    '';
  };

in {
  users = {
    groups."${gitUser.username}".name = "${gitUser.username}";
    users."${gitUser.username}" = {
      createHome = true;
      description = "${gitUser.username}";
      group = "${gitUser.username}";
      home = "${gitUser.homeDir}";
      isNormalUser = true;
      isSystemUser = false;
      linger = true;
      useDefaultShell = true;
    };
  };

  systemd.services = {
    "ssh-keys-sanity-check" = {
      serviceConfig = { Type = "oneshot"; User = "${gitUser.username}"; };

      script = ''
        set -xeuf -o pipefail

        mkdir -p ${gitRepoStore}
        find ${gitUser.homeDir}/.ssh -type f -empty -delete
        if [[ ! -f ${gitUpstreamAuthKeyPath} ]]; then
            echo 'ERROR: No SSH key found (${gitUpstreamAuthKeyPath}).'
            exit 1
        fi
      '';
    };

    "push-to-origin-gitlab" = mkGitPushService "gitlab";
    "push-to-origin-github" = mkGitPushService "github";
  };

  systemd.timers = {
    "push-to-origin-gitlab" = mkGitPushTimer "gitlab";
    "push-to-origin-github" = mkGitPushTimer "github";
  };
}
