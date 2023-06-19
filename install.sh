#!/usr/bin/env bash

if [[ ${EUID} -ne 0 ]]; then
    >&2 echo "$0: please run this script as root"
    exit 1
fi


if ! ping -c 1 google.com > /dev/null; then
    >&2 echo "$0: not connected to the network"
    exit 1
fi

if [[ -z $1 || -z $2 || -z $3 ]]; then
    >&2 echo "$0: missing arg(s) for 'OS drive', 'hostname' and 'disk partition layout'"
    exit 1
fi

OS_DRIVE=$1
NETWORKING_HOSTNAME=$2
PARTITION_LAYOUT_TYPE=$3

if [[ ${PARTITION_LAYOUT_TYPE} == "desktop" ]]; then
    PARTITION_LAYOUT_TYPE="$(pwd)/scripts/desktop-partitions.sh"
elif [[ ${PARTITION_LAYOUT_TYPE} == "rpi" ]]; then
    if [[ $(command -v wget &> /dev/null) ]]; then
        >&2 echo "$0: binary 'wget' not found"
        exit 1
    fi
    PARTITION_LAYOUT_TYPE="$(pwd)/scripts/raspberry-pi-partitions.sh"
elif [[ ${PARTITION_LAYOUT_TYPE} == "virt"  ]]; then
    PARTITION_LAYOUT_TYPE="$(pwd)/scripts/virt-partitions.sh"
else
    >&2 echo "$0: invalid arg for 'disk partition layout'; possible values are 'desktop', 'rpi', 'virt'"
    exit 1
fi

umount -R /mnt &> /dev/null

# partition, format and mount
${PARTITION_LAYOUT_TYPE} ${OS_DRIVE}

# prepare installation
mkdir -p /mnt/etc/nixos
nixos-generate-config --root /mnt
cp -v nixos-configuration/*.nix /mnt/etc/nixos/

# generate 'networking.hostId' for ZFS
# and other host-specific configurations
./scripts/deviation.sh ${NETWORKING_HOSTNAME}

# install nixos
nixos-install --no-root-password

mkdir -vp /mnt/home/pratham/.config/fish
cat << EOF > /mnt/home/pratham/.config/fish/config.fish
# get dotfiles
git clone --depth 1 --bare https://git.thefossguy.com/thefossguy/dotfiles.git $HOME/.dotfiles
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout -f
rm -rf $HOME/.dotfiles

# generate SSH keys
mkdir $HOME/.ssh
chmod 700 $HOME/.ssh
pushd $HOME/.ssh
ssh-keygen -t ed25519 -f ssh
ssh-keygen -t ed25519 -f git
ssh-keygen -t ed25519 -f virt
ssh-keygen -t ed25519 -f zfs
popd
EOF

# done!
umount -R /mnt
