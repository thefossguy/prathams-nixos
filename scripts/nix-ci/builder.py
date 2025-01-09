#!/usr/bin/env python3

import asyncio
import json
import os
import pathlib
import subprocess
import sys

ci_variables = {}
ci_variables['impure_build'] = False
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
ci_variables['outPaths'] = {}

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

    if '--use-emulation' in sys.argv:
        binfmt_dir = '/proc/sys/fs/binfmt_misc'
        if pathlib.Path('{}/status'.format(binfmt_dir)).is_file():
            with open('{}/status'.format(binfmt_dir), 'r') as binfmt_status_file:
                if binfmt_status_file.read().strip() == 'enabled':
                    files_in_binfmt_dir = next(os.walk(binfmt_dir), (None, None, []))[2]
                    for emulated_system in files_in_binfmt_dir:
                        print('CI_DEBUG: {}, {}'.format(emulated_system, ci_variables['supported_systems']))
                        if emulated_system in ci_variables['supported_systems']:
                            if emulated_system not in ci_variables['all_supported_systems']:
                                ci_variables['all_supported_systems'].append(emulated_system)

    for cross_system in ci_variables['supported_systems']:
        if '--cross-{}'.format(cross_system) in sys.argv:
            if cross_system not in ci_variables['all_supported_systems']:
                ci_variables['impure_build'] = True
                ci_variables['all_supported_systems'].append(cross_system)

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
    command = [ 'build', '--max-jobs', '1', '--print-build-logs', '--show-trace', '--verbose', ] + nix_build_targets
    if '--use-nom' in sys.argv:
        command = [ 'nix', 'run', 'nixpkgs#nix-output-monitor', '--', ] + command
    else:
        command = [ 'nix', ] + command
    if ci_variables['impure_build']:
        command = command + [ '--impure', ]
    return command

async def get_outPath(nix_build_target) -> None:
    proc = await asyncio.get_event_loop().run_in_executor(
        None,
        lambda: subprocess.run(['nix', 'eval', nix_build_target + '.outPath'], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    )
    # No need to error out if the stdout is empty because failure to evaluate
    # the `outPath` is more to do with fixing the build than what concerns the
    # binary cache.
    if proc.stdout.strip() != "":
        ci_variables['outPaths'][nix_build_target] = proc.stdout.strip().split('"')[1]
    return

async def main():
    tmpFile = open(ci_variables['logfile'], 'w')
    tmpFile.close()

    get_all_supported_systems()

    system_dep_attr_names = []
    if '--nixosConfigurations' in sys.argv:
        get_supported_nixos_systems()
    for supported_system_dep_attr_name in ci_variables['supported_system_dep_attr_names']:
        if '--{}'.format(supported_system_dep_attr_name) in sys.argv:
            system_dep_attr_names.append(supported_system_dep_attr_name)
    get_system_dep_attrs(system_dep_attr_names)
    ci_variables['nix_build_targets'] = ci_variables['nixosConfigurations'] + ci_variables['homeConfigurations'] + ci_variables['packages'] + ci_variables['devShells'] + ci_variables['isoImages']

    if len(ci_variables['nix_build_targets']) > 0:
        if '--link-only' in sys.argv:
            missing_paths = []
            print('DEBUG: Evaluating the `outPath`s for each Nix build target. This may take a while.')
            async_tasks = [ get_outPath(nix_build_target) for nix_build_target in ci_variables['nix_build_targets'] ]
            await asyncio.gather(*async_tasks)
            for i, nix_build_target in enumerate(ci_variables['nix_build_targets']):
                if nix_build_target in ci_variables['outPaths']:
                    eval_out_path = ci_variables['outPaths'][nix_build_target]
                    print('DEBUG: `{}` ==> `{}`'.format(nix_build_target, eval_out_path))
                    if pathlib.Path(eval_out_path).exists():
                        os.symlink(eval_out_path, 'result-' + '{}'.format(i).zfill(2))
                    else:
                        missing_paths.append(eval_out_path)
                        continue
                else:
                    print('WARN: Nix build target `{}` probably cannot be built for some reason, please check.'.format(nix_build_target))
            for missing_path in missing_paths:
                print('WARN: `{}` does not exist on this cache'.format(missing_path))

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

                # Just in case the reason for failure to build multiple nix targets
                # had nothing to do with my nix code and each target, when built
                # individually, did build.
                print('Retrying a rebuild of these targets: `{}`'.format(' '.join(ci_variables['nix_build_targets'])))
                build_all_targets_process = subprocess.run(make_nix_build_command(ci_variables['nix_build_targets']), stdout=sys.stdout, stderr=sys.stderr, text=True, check=False)
                cleanup(build_all_targets_process.returncode)
            else:
                cleanup(0)

    else:
        print('WARN: No Nix build targets were specified so building nothing.')
        cleanup(0)
    return

if __name__ == '__main__':
    asyncio.run(main())
