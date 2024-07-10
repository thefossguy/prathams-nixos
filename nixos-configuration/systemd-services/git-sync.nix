{ pkgs, ... }:

let
  gitUser = {
    username = "git";
    homeDir = "/home/${gitUser.username}";
  };

  gitUpstreamAuthKeyName = "ssh";
  gitUpstreamAuthKeyPath = "${gitUser.homeDir}/.ssh/${gitUpstreamAuthKeyName}";

  connectivityCheckScript = origin: import ../includes/misc-imports/check-network.nix {
    internetEndpoint = "${origin}.com";
    inherit pkgs;
  };

  mkServiceTimer = service: {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "now";
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "${service}.service";
    };
  };

  mkGitPushService = origin: let
    gitRepoStore = "${gitUser.homeDir}/repos-to-push/";
  in {
    after = [ "ssh-keys-sanity-check.service" ];
    requires = [ "ssh-keys-sanity-check.service" ];
    serviceConfig = { Type = "oneshot"; User = "${gitUser.username}"; };
    path = with pkgs; [ git openssh iputils ];

    script = ''
      set -xeuf -o pipefail

      ${connectivityCheckScript "${origin}"}

      [[ ! -d ${gitRepoStore} ]] && mkdir -p ${gitRepoStore}
      for gitDir in $(find ${gitRepoStore} -name "*.git" -depth -maxdepth 2 -mindepth 2 -type d); do
          pushd "''${gitDir}"
          gitOrigins=( $(git remote) )
          for gitOrigin in "''${gitOrigins[@]}"; do
              # 1. Specify SSH private key to use
              # 2. `StrictHostKeyChecking=no` because we are **pushing** ;)
              GIT_SSH_COMMAND="ssh -i ${gitUpstreamAuthKeyPath} -o StrictHostKeyChecking=no" git push ${origin}
          done
          popd
      done
    '';
  };

  mkGitPullService = let
    gitRepoStore = "${gitUser.homeDir}/repos-to-pull/";
  in {
    after = [ "ssh-keys-sanity-check.service" ];
    requires = [ "ssh-keys-sanity-check.service" ];
    serviceConfig = { Type = "oneshot"; User = "${gitUser.username}"; };
    path = with pkgs; [ git openssh iputils ];

    script = ''
      set -xeuf -o pipefail

      [[ ! -d ${gitRepoStore} ]] && mkdir -p ${gitRepoStore}
      for gitDir in $(find ${gitRepoStore} -name "*.git" -depth -maxdepth 2 -mindepth 2 -type d); do
          pushd "''${gitDir}"
          # no loop because the pull origin will always remain singular

          # 1. Specify SSH private key to use
          # 2. `StrictHostKeyChecking=no` because I already pulled manually ;)
          GIT_SSH_COMMAND="ssh -i ${gitUpstreamAuthKeyPath} -o StrictHostKeyChecking=no" git pull
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

        find ${gitUser.homeDir}/.ssh -type f -empty -delete
        if [[ ! -f ${gitUpstreamAuthKeyPath} ]]; then
            echo 'ERROR: No SSH key found (${gitUpstreamAuthKeyPath}).'
            exit 1
        fi
      '';
    };

    "push-to-gitlab"   = mkGitPushService "gitlab";
    "push-to-github"   = mkGitPushService "github";
    "pull-from-origin" = mkGitPullService;
  };

  systemd.timers = {
    "push-to-gitlab"   = mkServiceTimer "push-to-gitlab";
    "push-to-github"   = mkServiceTimer "push-to-github";
    "pull-from-origin" = mkServiceTimer "pull-from-origin";
  };
}
