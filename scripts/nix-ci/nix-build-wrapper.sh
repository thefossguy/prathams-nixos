#!/usr/bin/env bash

set -euf -o pipefail

build_targets=()
host_nix_system="$(uname -m)-$(uname -s | awk '{print tolower($0)}')"
if [[ "${USE_NOM:-0}" -eq 1 ]] && command -v nom >/dev/null; then
    nix_bin='nom'
else
    nix_bin='nix'
fi

bold_font="$(tput bold)"
norm_font="$(tput sgr0)"
function emphasize() { echo "${bold_font}${1}${norm_font}"; }

function nixos_system_expression() { echo ".#nixosConfigurations.$1.config.system.build.toplevel"; }
function home_manager_expression() { echo ".#legacyPackages.${host_nix_system}.homeConfigurations.${1:-${USER}}.activationPackage"; }
function nixos_iso_expression()    { echo ".#nixosConfigurations.z-iso-$(uname -m).config.system.build.isoImage"; }
function package_expression()      { echo ".#packages.${host_nix_system}.$1"; }

function help_text() {
    echo 'I have the following **exclusive** targets:'
    echo "    - [machine]:    \`nix build .#nixosConfigurations.$(emphasize '"${2:-$(hostname)}"').config.system.build.toplevel\`"
    echo "    - [home]:       \`nix build .#legacyPackages.$(emphasize "${host_nix_system}").homeConfigurations.$(emphasize "${USER}").activationPackage\`"
    echo "    - [iso]:        \`nix build .#nixosConfigurations.z-iso-$(emphasize "$(uname -m)").config.system.build.isoImage\`"
    echo "    - [package]:    \`nix build .#packages.$(emphasize "${host_nix_system}").$(emphasize '"$2"')\`"
    echo "    - [machines]:    build all \`nixosConfigurations\` where \`system\` == '$(emphasize "${host_nix_system}")'"
    echo "    - [homes]:       build \`homeConfigurations\` for all users defined in the \`$(emphasize 'realusers')\` set"
    echo "    - [packages]:    build all \`packages\` where \`system\` == '$(emphasize "${host_nix_system}")'"
    echo "    - [everything]:  $(emphasize "machines + homes + iso + packages")"
}

function source_nix_vals() {
    pushd "$(dirname "$0")" > /dev/null

    nix build --quiet .#listOfNixosMachines 2>/dev/null
    # shellcheck disable=SC1091
    source ./result
    readonly all_nixos_machines

    nix build --quiet .#listOfRealUsers 2>/dev/null
    # shellcheck disable=SC1091
    source ./result
    readonly all_users

    nix build --quiet .#listOfRealPackages 2>/dev/null
    # shellcheck disable=SC1091
    source ./result
    readonly all_packages

    rm result
    popd > /dev/null
}

function build_all_machines() {
    for nixos_machine in "${all_nixos_machines[@]}"; do
        if [[ "$(nix eval --raw --quiet ".#nixosConfigurations.${nixos_machine}.pkgs.stdenv.system" 2>/dev/null)" == "${host_nix_system}" ]]; then
            build_targets+=( "$(nixos_system_expression "${nixos_machine}")" )
        fi
    done
}
function build_all_homes() {
    for home_user in "${all_users[@]}"; do
        build_targets+=( "$(home_manager_expression "${home_user}")" )
    done
}
function build_all_packages() {
    [[ -z "${all_packages[*]}" ]] && return 0
    for package in "${all_packages[@]}"; do
        build_targets+=( "$(package_expression "${package}")" )
    done
}

# ugly hack but idk what else to do while still keeping the script "fast enough"
if [[ "${1:-}" == 'machines' ]] || [[ "${1:-}" == 'homes' ]] || [[ "${1:-}" == 'packages' ]] || [[ "${1:-}" == 'everything' ]]; then
    source_nix_vals
fi

if [[ -z "${1:-}" ]]; then
    echo 'ERROR: No build target(s) provided.'
    echo
    help_text
    exit 1

elif [[ "$1" == 'machine' ]]; then
    build_targets+=( "$(nixos_system_expression "${2:-$(hostname)}")" )
elif [[ "$1" == 'machines' ]]; then
    build_all_machines

elif [[ "$1" == 'home' ]]; then
    build_targets+=( "$(home_manager_expression)" )
elif [[ "$1" == 'homes' ]]; then
    build_all_homes

elif [[ "$1" == 'iso' ]]; then
    build_targets+=( "$(nixos_iso_expression)" )

elif [[ "$1" == 'package' ]]; then
    build_targets+=( "$(package_expression "$2")" )
elif [[ "$1" == 'packages' ]]; then
    build_targets+=( "$(build_all_packages)" )

elif [[ "$1" == 'everything' ]]; then
    build_all_machines
    build_all_homes
    build_all_packages
    build_targets+=( "$(nixos_iso_expression)" )

else
    echo "ERROR: '$1' is not a valid build target."
    echo
    help_text
    exit 1

fi

if [[ "$(( "$(( "$(date +%s)" - "$(stat flake.lock -c %Y)" ))" / 3600 ))" -gt 0 ]] && [[ "${UPDATE_LOCKFILE:-1}" -eq 1 ]]; then
    touch flake.lock
    nix_flake_update='nix flake update'
else
    nix_flake_update=''
fi


set -x
$nix_flake_update
time $nix_bin build --print-build-logs --show-trace "${build_targets[@]}"
