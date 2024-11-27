{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
    username = nixosSystemConfig.coreConfig.systemUser.username;
    homeDir = "/home/${username}";
    dotfilesDir = "${homeDir}/.dotfiles";
    actuallyUsesZfs = (
      (config.fileSystems."/".fsType == "zfs") ||
      (config.fileSystems."/home".fsType == "zfs") ||
      (config.fileSystems."/var".fsType == "zfs")
    );
in {
  system.activationScripts.dotfilesSetup.text = ''
    if [[ ! -d ${dotfilesDir} ]]; then
        su -c 'git clone --bare https://gitlab.com/thefossguy/dotfiles.git ${dotfilesDir}' ${username}
        su -c 'git --git-dir=${dotfilesDir} --work-tree=${homeDir} --checkout -f' ${username}
    fi
  '';

  system.activationScripts.addZfsPermissions.text = if actuallyUsesZfs then ''
    ${config.boot.kernelPackages.zfs.userspaceTools.outPath}/bin/zfs allow -u ${username} diff,rollback,mount,snapshot,send,hold "${config.networking.hostName}-zpool"
  '' else "";
}
