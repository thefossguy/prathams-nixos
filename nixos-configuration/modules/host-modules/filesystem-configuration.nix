{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  commonMountOptions = [
    "relatime"
    "lazytime"
  ];
  hardenedMountOptions = [
    "nodev"
    "nosuid"
  ];
  bootMountOptions =
    commonMountOptions
    ++ hardenedMountOptions
    ++ [
      "noexec"
      "umask=0077"
    ];
  rootMountOptions = commonMountOptions ++ hardenedMountOptions;
  homeMountOptions = commonMountOptions ++ hardenedMountOptions;
  varlMountOptions = commonMountOptions ++ hardenedMountOptions;

  addAsyncOption = mountPath: lib.optionals (config.fileSystems."${mountPath}".fsType != "zfs") [ "async" ];
in
{
  fileSystems."/boot" = {
    fsType = "vfat";
    options = bootMountOptions ++ addAsyncOption "/boot";
  };

  fileSystems."/" = {
    fsType = "xfs";
    options = rootMountOptions ++ addAsyncOption "/";
  };

  fileSystems."/home" = {
    fsType = "xfs";
    options = homeMountOptions ++ addAsyncOption "/home";
  };

  fileSystems."/var" = {
    fsType = "xfs";
    options = varlMountOptions ++ addAsyncOption "/var";
  };

  boot.initrd.systemd.services.rollback-root = {
    description = "Rollback rootfs to blank snapshot";
    wantedBy = [ "initrd.target" ];
    before = [ "sysroot.mount" ];
    after = [
      "systemd-udev-settle.service"
      "luks-unlock.service"
    ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";

    script =
      let
        commonPkgs = with pkgs; [
          coreutils-full
          util-linux
        ];
        rootFileSystem = config.fileSystems."/".fsType;
        rollbackScript = {
          btrfs =
            let
              fsProgs = commonPkgs ++ [ pkgs.btrfs-progs ];
              tempMountPath = "/btrfs/rollback";
              rootfsSubvolumeName = builtins.elemAt (builtins.filter (
                fsOpt: (builtins.match "subvol=@.*" fsOpt) != null
              ) config.fileSystems."/".options) 0;
              rootfsSubvolumeStrippedName = builtins.substring 7 (builtins.stringLength rootfsSubvolumeName - 7) rootfsSubvolumeName;
              emptySnapshotName = "fresh";
            in
            ''
              export PATH=${lib.makeBinPath (builtins.map (pkg: pkg.out or pkg) fsProgs)}:$PATH

              mkdir -vp ${tempMountPath}
              mount -o ${rootfsSubvolumeName} ${config.fileSystems."/".device} ${tempMountPath}
              if [ -d ${tempMountPath}/${rootfsSubvolumeStrippedName}${emptySnapshotName} ]; then
                  btrfs subvolume delete ${tempMountPath}/${rootfsSubvolumeStrippedName}
                  btrfs subvolume snapshot ${tempMountPath}/${rootfsSubvolumeStrippedName}${emptySnapshotName} ${tempMountPath}/${rootfsSubvolumeStrippedName}
              else
                  echo 'rollback-root: @fresh snapshot not found, aborting rollback' >&2
              fi
              umount -vR ${tempMountPath}
            '';
          zfs = null;
          xfs = "# intentionally left empty; snapshotting (and therefore rollbacks) are unsupported on XFS";
        };
      in
      rollbackScript.${rootFileSystem};
  };
}
