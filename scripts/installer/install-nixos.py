#!/usr/bin/env python3

import shutil
import os
import sys
import pathlib
import math
import subprocess

nixExperimentalFlags = None
nixExperimentalFlagsUnpopulated = []
nixExperimentalFlagsPopulated = [
    '--extra-experimental-features',
    'nix-command',
    '--extra-experimental-features',
    'flakes',
]
nix3_check = subprocess.run(['nix', 'help'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
if nix3_check.returncode != 0:
    nixExperimentalFlags = nixExperimentalFlagsPopulated
else:
    nixExperimentalFlags = nixExperimentalFlagsUnpopulated

installer_variables = {}

def debugPrint(formatted_string: str) -> None:
    print('DEBUG: {}'.format(formatted_string))
    return

def warnPrint(formatted_string: str) -> None:
    print('WARN: {}'.format(formatted_string))
    return

def errorPrint(formatted_string: str) -> None:
    print('ERROR: {}'.format(formatted_string))
    return


def update_flake_lockfile() -> None:
    flag_file = 'initial-lockfile-update-complete.log'
    if not pathlib.Path(flag_file).exists():
        debugPrint('Updating the `flake.lock` file. This may take a while.')
        nix_flake_update_command = [ 'nix', ] + nixExperimentalFlags + [ 'flake', 'update', ]
        nix_flake_update_process = subprocess.run(nix_flake_update_command, stderr=subprocess.PIPE)
        if nix_flake_update_process.returncode != 0:
            errorPrint('The `nix flake update` command failed with the following error.')
            print('```\n{}\n```'.format(nix_flake_update_process.stderr))
            sys.exit(1)

        flag_file_file = open(flag_file, 'w')
        flag_file_file.write('')
        flag_file_file.close()
    return

def fetch_git_repo_changes() -> None:
    subprocess.run(['git', 'pull', ], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    return

def dry_build_nixos_configuration() -> None:
    hostname = installer_variables['hostname']
    nix_dry_build_command = [ 'nix', ] + nixExperimentalFlags + [
        'build',
        '--dry-run',
        '--cores', '1',
        '--max-jobs', '1',
        '--print-build-logs',
        '--show-trace',
        '--trace-verbose',
        '--verbose',
        '.#nixosConfigurations.' + hostname + '.config.system.build.toplevel'
    ]
    debugPrint('Performing a dry build of `{}`. This may take a while.'.format(hostname))
    nix_dry_build_process = subprocess.run(nix_dry_build_command, stderr=subprocess.PIPE, text=True)

    if nix_dry_build_process.returncode != 0:
        errorPrint('The dry-build of `{hostname}` failed.')
        print('```\n{}\n```'.format(nix_dry_build_process.stderr))
        sys.exit(1)
    return

def get_target_disk_size() -> None:
    min_disk_size_limit = 64
    block_dev_name = installer_variables['target_disk'].split('/')
    target_disk_size_filepath = '/sys/block/' + block_dev_name[2] + '/size'
    target_disk_size_file = open(target_disk_size_filepath, 'r')
    target_disk_size = target_disk_size_file.readline()
    target_disk_size_file.close()
    target_disk_size = int(math.floor((float(target_disk_size) / 2 / 1024 / 1024)))

    if target_disk_size < min_disk_size_limit:
        errorPrint('The target disk `{}` is too small ({}G) for NixOS. A disk with the minimum size of {}G is required.'.format(installer_variables['target_disk'], target_disk_size, min_disk_size_limit))
        sys.exit(1)

    installer_variables['target_disk_size'] = target_disk_size
    return

def installer_pre_checks() -> None:
    update_flake_lockfile()
    fetch_git_repo_changes()
    dry_build_nixos_configuration()
    get_target_disk_size()
    return

def unmount_everything() -> None:
    mount_process = subprocess.run(['mount'], text=True, stdout=subprocess.PIPE)
    match_string = ' on ' + installer_variables['mount_path'] + ' type '
    if match_string in mount_process.stdout:
        unmount_command = [ 'umount', '--recursive', '--force', installer_variables['mount_path'] ]
        debugPrint('Unmounting recursively from `{}`'.format(installer_variables['mount_path']))
        subprocess.run(unmount_command, check=True)
    return

def generate_partition_sizes() -> None:
    target_disk_size = installer_variables['target_disk_size']
    varl_part_size = installer_variables['varl_part_size']
    assert varl_part_size < target_disk_size

    boot_part_start = 64
    boot_part_size = 1024

    root_part_start = boot_part_start + boot_part_size
    root_part_size = 1024
    if target_disk_size == 64:
        root_part_size *= 24
    else:
        root_part_size *= target_disk_size / 4

    home_part_start = root_part_start + root_part_size
    home_part_size = ((target_disk_size - varl_part_size) * 1024 ) - (boot_part_size + root_part_size)

    varl_part_start = home_part_start + home_part_size

    boot_part_sizes = [ boot_part_start, root_part_start - 1 ]
    root_part_sizes = [ root_part_start, home_part_start - 1 ]
    home_part_sizes = [ home_part_start, varl_part_start - 1 ]
    varl_part_sizes = [ varl_part_start, ]

    installer_variables['boot_part_sizes'] = boot_part_sizes
    installer_variables['root_part_sizes'] = root_part_sizes
    installer_variables['home_part_sizes'] = home_part_sizes
    installer_variables['varl_part_sizes'] = varl_part_sizes

    return

def get_partition_uuid(partition_mount_path) -> None:
    hostname_hardware_nix_filepath = 'nixos-configuration/systems/' + installer_variables['hostname'] + '/hardware-configuration.nix'
    match_pattern = 'fileSystems."/' + partition_mount_path + '" = {'
    with open(hostname_hardware_nix_filepath, 'r') as hostname_hardware_nix_file:
        line_num = 0
        matched_line_num = 0
        for line in hostname_hardware_nix_file:
            line_num += 1
            if matched_line_num == line_num:
                device_value = line.split()[2]
                unquoted_device_value = device_value.split('"')[1]
                partition_uuid = unquoted_device_value.split('/')[4]
                return partition_uuid

            if match_pattern in line:
                matched_line_num = line_num + 1

    errorPrint('Reached end of parsing {} and did not find any matches for mount path `{}`.'.format(hostname_hardware_nix_filepath, installer_variables['partition_mount_path']))
    sys.exit(1)

def partition_target_disk_nozfs() -> None:
    target_disk = installer_variables['target_disk']
    mount_path = installer_variables['mount_path']

    boot_part_dev = installer_variables['boot_part_dev']
    root_part_dev = installer_variables['root_part_dev']
    home_part_dev = installer_variables['home_part_dev']
    varl_part_dev = installer_variables['varl_part_dev']

    boot_part_sizes = installer_variables['boot_part_sizes']
    root_part_sizes = installer_variables['root_part_sizes']
    home_part_sizes = installer_variables['home_part_sizes']
    varl_part_sizes = installer_variables['varl_part_sizes']

    boot_part_uuid = get_partition_uuid('boot').replace('-','')
    root_part_uuid = get_partition_uuid('')
    home_part_uuid = get_partition_uuid('home')
    varl_part_uuid = get_partition_uuid('var')

    parted_command = [ 'parted', '--script', '--fix', target_disk,
        'mklabel', 'gpt',
        'mkpart', 'primary', 'fat32', '{}MiB'.format(boot_part_sizes[0]), '{}MiB'.format(boot_part_sizes[1]),
        'mkpart', 'primary', 'xfs',   '{}MiB'.format(root_part_sizes[0]), '{}MiB'.format(root_part_sizes[1]),
        'mkpart', 'primary', 'xfs',   '{}MiB'.format(home_part_sizes[0]), '{}MiB'.format(home_part_sizes[1]),
        'mkpart', 'primary', 'xfs',   '{}MiB'.format(varl_part_sizes[0]), '100%',
        'set', '1', 'esp', 'on',
    ]
    parted_process = subprocess.run(parted_command, stderr=subprocess.PIPE)
    if parted_process.returncode != 0:
        errorPrint('The partitioning script failed with the following error:\n```\n{}\n```'.format(parted_process.stderr))
        sys.exit(1)

    mkfs_boot_command = [ 'mkfs.fat', '-F', '32', '-n', 'nixboot', boot_part_dev, '-i', boot_part_uuid ]
    mkfs_root_command = [ 'mkfs.xfs', '-f', '-L', 'nixroot', root_part_dev, '-m', 'uuid=' + root_part_uuid ]
    mkfs_home_command = [ 'mkfs.xfs', '-f', '-L', 'nixhome', home_part_dev, '-m', 'uuid=' + home_part_uuid ]
    mkfs_varl_command = [ 'mkfs.xfs', '-f', '-L', 'nixvarp', varl_part_dev, '-m', 'uuid=' + varl_part_uuid ]
    mkfs_commands = [ mkfs_boot_command, mkfs_root_command, mkfs_home_command, mkfs_varl_command ]
    for mkfs_command in mkfs_commands:
        debugPrint('{}'.format(mkfs_command))
        process = subprocess.run(mkfs_command, stderr=subprocess.PIPE, stdout=subprocess.DEVNULL)
        if process.returncode != 0:
            errorPrint('The mkfs command `{}` command failed with the following error:\n```\n{}\n```'.format(mkfs_command, process.stderr))
            sys.exit(1)

    mount_root_command = [ 'mount', '-o', 'async,lazytime,relatime',            root_part_dev, mount_path + '/' ]
    mount_boot_command = [ 'mount', '-o', 'umask=077',               '--mkdir', boot_part_dev, mount_path + '/boot' ]
    mount_home_command = [ 'mount', '-o', 'async,lazytime,relatime', '--mkdir', home_part_dev, mount_path + '/home' ]
    mount_varl_command = [ 'mount', '-o', 'async,lazytime,relatime', '--mkdir', varl_part_dev, mount_path + '/var' ]
    mount_commands = [ mount_root_command, mount_boot_command, mount_home_command, mount_varl_command ]
    for mount_command in mount_commands:
        debugPrint('{}'.format(mount_command))
        process = subprocess.run(mount_command, stderr=subprocess.PIPE, stdout=subprocess.DEVNULL)
        if process.returncode != 0:
            errorPrint('The mount command `{}` command failed with the following error:\n```\n{}\n```'.format(mount_command, process.stderr))
            sys.exit(1)

    return

def partition_target_disk_zfs() -> None:
    if shutil.which('zfs') == None:
        errorPrint('ZFS userspace utilities were not detected. Not partitioning anything.')
        sys.exit(1)

    hostname = installer_variables['hostname']
    installer_variables['zpool_name'] = hostname + '-zpool'
    target_disk = installer_variables['target_disk']
    boot_part_sizes = installer_variables['boot_part_sizes']
    boot_part_dev = installer_variables['boot_part_dev']
    boot_part_uuid = get_partition_uuid('boot').replace('-','')

    parted_command = [ 'parted', '--script', '--fix', target_disk,
        'mklabel', 'gpt',
        'mkpart', 'primary', 'fat32', '{}MiB'.format(boot_part_sizes[0]), '{}MiB'.format(boot_part_sizes[1]),
        'set', '1', 'esp', 'on',
    ]
    parted_process = subprocess.run(parted_command, stderr=subprocess.PIPE)
    if parted_process.returncode != 0:
        errorPrint('The partitioning script failed with the following error:\n```\n{}\n```'.format(parted_process.stderr))
        sys.exit(1)

    mkfs_command = [ 'mkfs.fat', '-F', '32', '-n', 'nixboot', boot_part_dev, '-i', boot_part_uuid ]
    debugPrint('{}'.format(mkfs_command))
    mkfs_process = subprocess.run(mkfs_command, stderr=subprocess.PIPE, stdout=subprocess.DEVNULL, text=True)
    if mkfs_process.returncode != 0:
        errorPrint('The mkfs command `{}` command failed with the following error:\n```\n{}\n```'.format(mkfs_command, mkfs_process.stderr))
        sys.exit(1)

    zpool_create_command = [
        'zpool', 'create',
        '-o', 'ashift=12',
        '-o', 'autotrim=off',
        '-o', 'compatibility=off',
        '-o', 'listsnapshots=on',
        '-O', 'atime=off',
        '-O', 'checksum=fletcher4',
        '-O', 'compression=zstd-fast',
        '-O', 'primarycache=none',
        '-O', 'relatime=off',
        '-O', 'sync=standard',
        '-O', 'xattr=sa',
        '-O', 'acltype=posixacl',
        '-m', 'none',
        installer_variables['zpool_name'],
    ]

    subprocess.run([ 'zpool', 'import', '-f', '-N', installer_variables['zpool_name']])
    imported_zpools_command = [ 'zpool', 'list', '-H', '-o', 'name' ]
    imported_zpools_process = subprocess.run(imported_zpools_command, stdout=subprocess.PIPE, text=True)
    if installer_variables['zpool_name'] in imported_zpools_process.stdout:
        warnPrint('Destroying the zfs pool `{}`.'.format(installer_variables['zpool_name']))
        warnPrint('Press [Y/y] to destroy the zfs pool.')
        user_input = str(input())
        if user_input.lower() == 'y':
            subprocess.run(['zpool', 'destroy', '-f', installer_variables['zpool_name']], check=True)
        else:
            errorPrint('Cannot re-create your zfs pool without destroying the pre-existing one.')
            sys.exit(1)



    if installer_variables['hostname'] == 'chaturvyas':
        zpool_create_command[zpool_create_command.index('ashift=12')] = 'ashift=13'
        zpool_create_command += ['raidz1', 'nvme0n1', 'nvme1n1', 'nvme2n1', 'nvme3n1']
        debugPrint(zpool_create_command)
        zpool_create_process = subprocess.run(zpool_create_command, stderr=subprocess.PIPE, text=True)
        if zpool_create_process.returncode != 0:
            errorPrint("zpool creation failed\n```\n{}\n```".format(zpool_create_process.stderr))
            sys.exit(1)
    else:
        errorPrint('zpool creation for system `{}` is not handled automatically.'.format(installer_variables['hostname']))
        sys.exit(1)

    zpool_rootfs_size = None
    zpool_get_rootfs_size_command = [ 'zpool', 'list', '-H', '-o', 'size', '-p' ]
    zpool_get_rootfs_size_process = subprocess.run(zpool_get_rootfs_size_command, text=True, stdout=subprocess.PIPE)
    zpool_total_size = int(zpool_get_rootfs_size_process.stdout) / ( 1024 * 1024 * 1024 )
    zpool_rootfs_size = int(math.ceil(zpool_total_size / 4))

    zfs_create_root_command = [ 'zfs', 'create', '-u', '-o', 'mountpoint=/',     '-o', 'refreservation={}G'.format(zpool_rootfs_size), '{}/root'.format(installer_variables['zpool_name']), ]
    zfs_create_home_command = [ 'zfs', 'create', '-u', '-o', 'mountpoint=/home', '-o', 'checksum=sha512', '{}/home'.format(installer_variables['zpool_name']), ]
    zfs_create_nasd_command = [ 'zfs', 'create', '-u', '-o', 'mountpoint=/nas',  '-o', 'checksum=sha512', '-o', 'compression=zstd-19', '{}/nas'.format(installer_variables['zpool_name']), ]
    zfs_create_varl_command = [ 'zfs', 'create', '-u', '-o', 'mountpoint=/varl', '-o', 'checksum=off', '-o', 'compression=zstd-19', '-o', 'snapshot_limit=0', '-o', 'redundant_metadata=none', '-o', 'refquota={}G'.format(installer_variables['varl_part_size']), '{}/var'.format(installer_variables['zpool_name']), ]

    zfs_create_commands = [zfs_create_root_command, zfs_create_home_command, zfs_create_nasd_command, zfs_create_varl_command]

    for zfs_create_command in zfs_create_commands:
        debugPrint(zfs_create_command)
        process = subprocess.run(zfs_create_command, stderr=subprocess.PIPE)
        if process.returncode != 0:
            errorPrint('zfs creation failed\n```\n{}\n```'.format(process.stderr))
            sys.exit(1)

    subprocess.run(['zpool', 'export', installer_variables['zpool_name']], text=True, stderr=subprocess.PIPE, check=True)
    subprocess.run(['zpool', 'import', installer_variables['zpool_name'], '-R', installer_variables['mount_path']], text=True, stderr=subprocess.PIPE, check=True)
    subprocess.run(['mount', '-o', 'umask=077', '--mkdir', boot_part_dev, installer_variables['mount_path'] + '/boot'])
    return

def partition_target_disk() -> None:
    hostname = installer_variables['hostname']
    target_disk = installer_variables['target_disk']
    mount_path = installer_variables['mount_path']
    partition_suffix = ''

    hostname_hardware_nix_filepath = 'nixos-configuration/systems/' + hostname + '/hardware-configuration.nix'
    hostname_hardware_nix_file = open(hostname_hardware_nix_filepath, 'r')
    hostname_hardware_nix = hostname_hardware_nix_file.read()
    hostname_hardware_nix_file.close()

    if 'sd' in target_disk or 'vd' in target_disk:
        partition_suffix = ''
    elif 'mmcblk' in target_disk or 'nvme' in target_disk or 'loop' in target_disk:
        partition_suffix = 'p'
    else:
        errorPrint('Disk type is unsupported. Not sure how to partition.')
        sys.exit(1)
    installer_variables['partition_suffix'] = partition_suffix

    installer_variables['boot_part_dev'] = target_disk + partition_suffix + '1'
    installer_variables['root_part_dev'] = target_disk + partition_suffix + '2'
    installer_variables['home_part_dev'] = target_disk + partition_suffix + '3'
    installer_variables['varl_part_dev'] = target_disk + partition_suffix + '4'

    if 'fsType = "zfs"' in hostname_hardware_nix:
        installer_variables['zfs_in_use'] = True
        partition_target_disk_zfs()
    else:
        installer_variables['zfs_in_use'] = False
        partition_target_disk_nozfs()
    return

def installer_pre_setup() -> None:
    unmount_everything()
    generate_partition_sizes()
    partition_target_disk()
    return

def installer_run() -> None:
    debugPrint('Installing NixOS for system `{}`.'.format(installer_variables['hostname']))
    nixos_install_command = [ 'nixos-install', '--max-jobs', '1', '--cores', '1', '--show-trace', '--root', installer_variables['mount_path'], '--no-root-password', '--flake', '.#' + installer_variables['hostname'] ]
    nixos_install_process = subprocess.run(nixos_install_command, stdout=sys.stdout, stderr=sys.stderr)
    if nixos_install_process.returncode != 0:
        sys.exit(1)
    return


def mount_resolv_conf() -> None:
    resolv_conf_path = '/etc/resolv.conf'
    process = subprocess.run([ 'mount', '-o', 'bind', resolv_conf_path, installer_variables['mount_path'] + resolv_conf_path ], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    if process.returncode != 0:
        errorPrint('Could not mount the `resolv.conf` file to the mount path.')
        sys.exit(1)
    return

def pseudo_chroot_setup() -> None:
    nix_eval_command = [ 'nix', 'eval', '.#nixosConfigurations.' + installer_variables['hostname'] + '._module.specialArgs.nixosSystemConfig.coreConfig.systemUser.username', ]
    nix_eval_process = subprocess.run(nix_eval_command, stdout=subprocess.PIPE, text=True)
    host_user_username = nix_eval_process.stdout[1:-2]
    profile_file_src = 'scripts/installer/.profile'
    profile_file_dst = '{}/home/{}/.profile'.format(installer_variables['mount_path'], host_user_username)
    shutil.copy(profile_file_src, profile_file_dst)
    return

def installer_post() -> None:
    pseudo_chroot_setup()
    # `sync` 4 times because drive firmware lies
    debugPrint('Syncing disks, this may take a while or be stupid-fast.')
    for _ in range(0,4):
        subprocess.run(['sync'])
    subprocess.run(['umount', '-vR', installer_variables['mount_path']], stdout=sys.stdout, stderr=sys.stderr)
    if installer_variables['zfs_in_use']:
        subprocess.run(['zpool', 'export', installer_variables['zpool_name']], stdout=sys.stdout, stderr=sys.stderr)
    return

def memtotal_warning() -> None:
    meminfo_filepath = '/proc/meminfo'
    meminfo_file = open(meminfo_filepath, 'r')
    unparsed_meminfo_memtotal = meminfo_file.readline()
    memtotal = int(unparsed_meminfo_memtotal.split()[1]) / 1024 / 1024
    meminfo_file.close()

    memtotal_min = 4
    if memtotal < memtotal_min:
        warnPrint('Your system has {:.1f}GB of memory, which is less than {}GB. You might get an OOM-kill.'.format(memtotal, memtotal_min))
    return

if __name__ == '__main__':
    system_kernel = os.uname().sysname.lower()
    system_arch = os.uname().machine.lower()

    if system_kernel != 'linux':
        errorPrint(f'Platform `{system_kernel}` is unsupported.')
        sys.exit(1)

    if os.getuid() != 0:
        errorPrint('Please run this script with `sudo`.')
        sys.exit(1)

    if len(sys.argv) < 3:
        errorPrint(f'Insufficient arguments. `{sys.argv[0]} target-disk hostname`')
        sys.exit(1)

    memtotal_warning()
    installer_variables['target_disk'] = sys.argv[1]
    installer_variables['hostname'] = sys.argv[2]
    installer_variables['mount_path'] = '/mnt'
    installer_variables['varl_part_size'] = 6

    if not pathlib.Path(installer_variables['target_disk']).is_block_device():
        errorPrint(f'`{installer_variables['target_disk']}` is not a block device.')
        sys.exit(1)

    installer_pre_checks()
    installer_pre_setup()
    installer_run()
    installer_post()

    debugPrint('Installation complete.')
