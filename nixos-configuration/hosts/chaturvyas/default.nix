{ config, ... }:

let
  zpoolName = "${config.networking.hostName}-zpool";
  datasetName = "nix-everything";
  zfsHelperScriptFromScratch = ''
    # **SET "LBA FORMAT" FIRST**
    # 1. Check what LBA Format is being used
    #sudo nvme id-ns -H </dev/nvme> | grep 'LBA Format'
    # 2. Find the "best" format
    #sudo nvme id-ns -H </dev/nvme> | grep 'LBA Format' | grep 'Best'
    # 2. Use the "best" format
    #sudo nvme format --lbaf=<the "best" LBA format> --force </dev/nvme>

    # in case you want to import a zpool for destroying
    #sudo zpool import -N "${zpoolName}"

    # get the options specified in `zpool create -o` with `man 7 zpoolprops`
    sudo zpool create \
        -o ashift=12 \
        -o autotrim=off \
        -o compatibility=off \
        -o listsnapshots=on \
        -O atime=off \
        -O checksum=fletcher4 \
        -O compression=zstd-fast \
        -O primarycache=none \
        -O relatime=off \
        -O sync=always \
        -O xattr=sa \
        -m none \
        ${zpoolName} raidz1 nvme0n1 nvme1n1 nvme2n1 nvme3n1

    # get the options specified in `zfs create <option=value>` with `man 7 zfsprops`
    sudo zfs create \
        -o mountpoint=/nix \
        -o recordsize=64K \
        -u \
        ${zpoolName}/${datasetName}

    # Or just mount (from installer)
    sudo zpool export "${zpoolName}"
    sudo zpool import "${zpoolName}" -R /mnt
  '';
in

{
  imports = [
    ../../includes/zfs/default.nix
    ../../systemd-services/git-sync.nix
  ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3A4D-C659";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/044c375e-e89f-4531-9d58-d4b6650f6774";
    fsType = "xfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/f1a133b4-5d19-46a0-b80f-f118ec067567";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/0dc6547c-757c-4dbc-aa54-47f44e9c2598";
    fsType = "xfs";
  };

  fileSystems."/nix" = {
    device = "${zpoolName}/${datasetName}";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  environment.etc."zfsHelperScriptFromScratch".text = zfsHelperScriptFromScratch;
}
