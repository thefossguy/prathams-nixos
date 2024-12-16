#!/usr/bin/env python3

import json
import os
import pathlib
import subprocess
import sys

ci_variables = {}
ci_variables['logfile'] = 'flake-ci-started.log'
ci_variables['supported_systems'] = [
    'aarch64-linux',
    #'riscv64-linux',
    'x86_64-linux',

    'aarch64-darwin',
    'x86_64-darwin',
]
ci_variables['supported_system_dep_attr_names'] = [ 'isoImages', 'homeConfigurations', 'devShells', 'packages', ]
ci_variables['all_supported_systems'] = []
ci_variables['nixosConfigurations'] = []
ci_variables['isoImages'] = []
ci_variables['homeConfigurations'] = []
ci_variables['devShells'] = []
ci_variables['packages'] = []

def cleanup(exit_code) -> None:
    os.remove(ci_variables['logfile'])
    sys.exit(exit_code)

def get_all_supported_systems() -> None:
    system_arch = os.uname().machine.lower()
    system_kernel = os.uname().sysname.lower()
    if system_arch == 'arm64':
        system_arch = 'aarch64'

    native_system = '{}-{}'.format(system_arch, system_kernel)
    if native_system in ci_variables['supported_systems']:
        ci_variables['all_supported_systems'].append(native_system)
    else:
        print('ERROR: Your system `{}` is unsupported.'.format(native_system))
        cleanup(1)

    if '--native-only' not in sys.argv:
        binfmt_dir = '/proc/sys/fs/binfmt_misc'
        if pathlib.Path('{}/status'.format(binfmt_dir)).is_file():
            with open('{}/status'.format(binfmt_dir), 'r') as binfmt_status_file:
                if binfmt_status_file.read().strip() == 'enabled':
                    files_in_binfmt_dir = next(os.walk(binfmt_dir), (None, None, []))[2]
                    for emulated_system in files_in_binfmt_dir:
                        if emulated_system in ci_variables['supported_systems']:
                            ci_variables['all_supported_systems'].append(emulated_system)

    ci_variables['all_supported_systems'].sort()
    return

def get_supported_nixos_systems() -> None:
    nix_eval_command = [ "nix", "eval", "--json", ".#nixosConfigurations", "--apply", "configs: builtins.mapAttrs (name: value: value.config.nixpkgs.hostPlatform.system) configs" ]
    nix_eval_process = subprocess.run(nix_eval_command, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)

    nixosSystems = json.loads(nix_eval_process.stdout)
    for hostname in nixosSystems:
        if nixosSystems[hostname] in ci_variables['all_supported_systems']:
            ci_variables['nixosConfigurations'].append(".#nixosConfigurations.{}.config.system.build.toplevel".format(hostname))
    return

def make_nix_eval_command(attr_name):
    command = [ "nix", "eval", "--json", ".#{}".format(attr_name), "--apply", """{}:
      let
        prefixes = system: builtins.map (name: "${{system}}.${{name}}") (builtins.attrNames {}.${{system}});
        systems = builtins.attrNames {};
      in builtins.concatLists (builtins.map prefixes systems)""".format(attr_name, attr_name, attr_name) ]
    return command

def get_system_dep_attrs(system_dep_attr_names=[]) -> None:
    if system_dep_attr_names == []:
        return

    for attr_name in system_dep_attr_names:
        command = make_nix_eval_command(attr_name)
        process = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
        attr_values = json.loads(process.stdout)

        for attr_value in attr_values:
            nix_build_target = None
            nix_system = attr_value.split('.')[0]
            if nix_system not in ci_variables['all_supported_systems']:
                continue

            if attr_name == 'isoImages':
                nix_build_target = '.#{}.{}.config.system.build.isoImage'.format(attr_name, attr_value)

            elif attr_name == 'homeConfigurations':
                nix_build_target = '.#{}.{}.activationPackage'.format(attr_name, attr_value)

            elif attr_name == 'devShells':
                nix_build_target = '.#{}.{}'.format(attr_name, attr_value)

            elif attr_name == 'packages':
                nix_build_target = '.#{}.{}'.format(attr_name, attr_value)

            if nix_build_target is None:
                print('ERROR: Could not determine the nix build target for some reason.')
                cleanup(1)

            ci_variables[attr_name].append(nix_build_target)

    return

def make_nix_build_command(nix_build_targets):
    command = [ 'build', '--max-jobs', '1' ] + nix_build_targets
    if '--use-nom' in sys.argv:
        command = [ 'nix', 'run', 'nixpkgs#nix-output-monitor', '--', ] + command
    else:
        command = [ 'nix', ] + command
    return command

if __name__ == '__main__':
    tmpFile = open(ci_variables['logfile'], 'w')
    tmpFile.close()

    get_all_supported_systems()

    if '--nixosConfigurations' in sys.argv:
        get_supported_nixos_systems()

    system_dep_attr_names = []
    for supported_system_dep_attr_name in ci_variables['supported_system_dep_attr_names']:
        if '--{}'.format(supported_system_dep_attr_name) in sys.argv:
            system_dep_attr_names.append(supported_system_dep_attr_name)
    get_system_dep_attrs(system_dep_attr_names)


    ci_variables['nix_build_targets'] = ci_variables['nixosConfigurations'] + ci_variables['homeConfigurations'] + ci_variables['packages'] + ci_variables['devShells'] + ci_variables['isoImages']

    if len(ci_variables['nix_build_targets']) > 0:
        if '--link-only' in sys.argv:
            i = 0
            for nix_build_target in ci_variables['nix_build_targets']:
                i = i + 1
                eval_out_path_command = subprocess.run(["nix", "eval", '{}.outPath'.format(nix_build_target)], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
                eval_out_path = eval_out_path_command.stdout.strip().split('"')[1]
                if pathlib.Path(eval_out_path).exists():
                    os.symlink(eval_out_path, 'result-{}'.format(i))
                else:
                    print('WARN: outPath for expression `{}` (`{}`) has not been sent to the store yet.'.format(nix_build_target, eval_out_path))
                    continue

            cleanup(0)

        else:
            print('Building these targets: `{}`'.format(' '.join(ci_variables['nix_build_targets'])))
            build_all_targets_process = subprocess.run(make_nix_build_command(ci_variables['nix_build_targets']), stdout=sys.stdout, stderr=sys.stderr, text=True, check=False)

            if build_all_targets_process.returncode != 0:
                print('ERROR: One or more Nix build targets could not be built. Building each one by one to figure out the fault one.')
                for nix_build_target in ci_variables['nix_build_targets']:
                    actual_command = make_nix_build_command([nix_build_target])
                    print('Building `{}`'.format(' '.join(actual_command)))
                    process = subprocess.run(actual_command, stdout=sys.stdout, stderr=sys.stderr, text=True)
                    if process.returncode != 0:
                        print('ERROR: Could not build `{}`.'.format(nix_build_target))
                        cleanup(process.returncode)

        print('WARN: No Nix build targets were specified so building nothing.')
        cleanup(0)
