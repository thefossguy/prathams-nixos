{ pkgs, ... }:

let
  gitUser = {
    username = "gitSyncUser";
    homeDir = "/home/${gitUser.username}";
    sshDirPath = "${gitUser.homeDir}/.ssh";
  };

  sshKeyPairName = "ssh";
  sshKeyPairPath = "${gitUser.sshDirPath}/${sshKeyPairName}";

  connectivityCheckScript = import ../modules/misc-imports/check-network.nix { inherit pkgs; };

  mkServiceTimer = serviceName: {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "now";
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "${serviceName}.service";
    };
  };

  mkGitPushService = let gitRepoStore = "${gitUser.homeDir}/repos-to-push";
  in {
    after = [ "ssh-keys-sanity-check.service" ];
    requires = [ "ssh-keys-sanity-check.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "${gitUser.username}";
    };
    path = with pkgs; [ gitFull openssh iputils ];

    script = ''
      set -xeuf -o pipefail

      ${connectivityCheckScript}

      [[ ! -d ${gitRepoStore} ]] && mkdir -p ${gitRepoStore}

      for gitDir in $(find ${gitRepoStore} -name "*.git" -depth -maxdepth 2 -mindepth 2 -type d); do
          pushd ''${gitDir}

          gitRemotes=( $(git remote) )
          for gitRemote in "''${gitRemotes[@]}"; do
              # 1. Specify SSH private key to use
              # 2. `StrictHostKeyChecking=no` because we are **pushing** ;)
              GIT_SSH_COMMAND="ssh -i ${sshKeyPairName} -o StrictHostKeyChecking=no" git push ''${gitRemote}
          done
          popd
      done
    '';
  };

  mkGitPullService = let gitRepoStore = "${gitUser.homeDir}/repos-to-pull";
  in {
    after = [ "ssh-keys-sanity-check.service" ];
    requires = [ "ssh-keys-sanity-check.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "${gitUser.username}";
    };
    path = with pkgs; [ gitFull openssh iputils ];

    script = ''
      set -xeuf -o pipefail

      ${connectivityCheckScript}

      [[ ! -d ${gitRepoStore} ]] && mkdir -p ${gitRepoStore}

      for gitDir in $(find ${gitRepoStore} -name "*.git" -depth -maxdepth 2 -mindepth 2 -type d); do
          pushd ''${gitDir}
          # no loop because there's only one true origin

          # 1. Specify SSH private key to use
          # 2. `StrictHostKeyChecking=no` because I already pulled manually ;)
          GIT_SSH_COMMAND="ssh -i ${sshKeyPairName} -o StrictHostKeyChecking=no" git fetch origin "*:*"
          popd
      done
    '';
  };

in {
  users.groups."${gitUser.username}".name = "${gitUser.username}";
  users.users."${gitUser.username}" = {
    createHome = true;
    description = "${gitUser.username}";
    group = "${gitUser.username}";
    home = "${gitUser.homeDir}";
    isNormalUser = true;
    isSystemUser = false;
    linger = true;
    useDefaultShell = true;
  };

  systemd.services = {
    "ssh-keys-sanity-check" = {
      serviceConfig = {
        Type = "oneshot";
        User = "${gitUser.username}";
      };

      script = ''
        set -xeuf -o pipefail

        find ${gitUser.sshDirPath} -type f -empty -delete
        if [[ ! -f ${sshKeyPairPath} ]]; then
            echo 'ERROR: No SSH key found (${sshKeyPairName}).'
            exit 1
        fi
      '';
    };

    "push-to-origin" = mkGitPushService;
    "pull-from-origin" = mkGitPullService;
  };

  systemd.timers = {
    "ssh-keys-sanity-check" = mkServiceTimer "ssh-keys-sanity-check";
    "push-to-origin" = mkServiceTimer "push-to-origin";
    "pull-from-origin" = mkServiceTimer "pull-from-origin";
  };
}
