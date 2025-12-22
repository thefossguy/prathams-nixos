{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.gitMirroring;
in
{
  systemd.user = {
    timers."${serviceConfig.unitName}" = {
      requiredBy = [ "timers.target" ];
      timerConfig = {
        Unit = "${serviceConfig.unitName}.service";
        OnCalendar = serviceConfig.onCalendar;
        OnBootSec = "10m";
      };
    };

    paths."${serviceConfig.unitName}" = {
      requiredBy = [ "paths.target" ];
      pathConfig = {
        PathChanged = "/home/git/my-git-repos";
        TriggerLimitIntervalSec = "60s";
        Unit = "${serviceConfig.unitName}.service";
      };
    };

    services."${serviceConfig.unitName}" = {
      path = with pkgs; [
        bash
        coreutils
        git
        iputils
        openssh
        openssl
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "${serviceConfig.unitName}-ExecStart.sh" ''
          set -xeuf -o pipefail

          if [[ "$(id -un)" != 'git' ]]; then
              exit 0
          fi
          set +x

          GIT_REPOS_TO_SYNC=($(find "''${HOME}/my-git-repos" -type d -name '*.git' ! -name '.git' -exec realpath {} \; | tr '\n' ' '))
          echo "Found these git repos: ''${GIT_REPOS_TO_SYNC[*]}"

          for GIT_REPO in "''${GIT_REPOS_TO_SYNC[@]}"; do
              LOCAL_BRANCHES=( $(git -C "''${GIT_REPO}" branch --no-column --format='%(refname:short)' | tr '\n' ' ') )
              GIT_MIRRORS=( $(git -C "''${GIT_REPO}" remote show | tr '\n' ' ') )

              echo "Found branches for ''${GIT_REPO}: ''${LOCAL_BRANCHES[*]}"
              echo "Found remotes for ''${GIT_REPO}: ''${GIT_MIRRORS[*]}"

              for GIT_REMOTE in "''${GIT_MIRRORS[@]}"; do
                  for GIT_BRANCH in "''${LOCAL_BRANCHES[@]}"; do
                      echo "GIT_SSH_COMMAND=\"ssh -o ConnectTimeout=10 -i ''${HOME}/.ssh/''${GIT_REMOTE}\" git -C ''${GIT_REPO} push ''${GIT_REMOTE} ''${GIT_BRANCH}"
                      GIT_SSH_COMMAND="ssh -o ConnectTimeout=10 -i ''${HOME}/.ssh/''${GIT_REMOTE}" git -C "''${GIT_REPO}" push "''${GIT_REMOTE}" "''${GIT_BRANCH}"
                  done
              done
          done
        ''}";
      };
    };
  };
}
