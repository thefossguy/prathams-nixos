#!/usr/bin/env bash

# shellcheck disable=SC2207
GIT_COMMITS=( $(git log --reverse --since='yesterday' --format='%H'  -- '*.nix' '*.patch') )


# This is the commit where I switched to Flakes. switch this commit because
# the `flake.lock` will always be modified so checking out the very first
# commit using a `git rev-list --max-parents=0 HEAD` wouldn't work quite well
# without a `git restore flake.lock` fuckery. So, instead, just switch a
# specific commit, instead of the _very first one_. Also, the initial switch
# of an unrelated commit is done to "_suppress_" the "detached HEAD" message.
git switch --detach c3a167f5157e712e0bafb21d26140a9b187c36cb
echo '--------------------------------------------------------------------------------'

set -xeuf -o pipefail
for gitCommit in "${GIT_COMMITS[@]}"; do
    git switch --detach "${gitCommit}"
    if ! python3 ./scripts/nix-ci/builder.py --nixosConfigurations --homeConfigurations --devShells --packages; then
        git switch master
        if ! python3 ./scripts/nix-ci/builder.py --nixosConfigurations --homeConfigurations --devShells --packages; then
            echo -e "\nwrapped-builder: The build failed for the git commit ${gitCommit}."
            exit 1
        else
            echo "wrapped-builder: WARNING: ${gitCommit} failed but master passed"
        fi
    fi
done

git switch master
python3 ./scripts/nix-ci/builder.py --nixosConfigurations --homeConfigurations --devShells --packages
