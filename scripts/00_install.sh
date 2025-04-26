#!/bin/sh

setup-hostname openfortivpn
setup-timezone Europe/Paris
setup-keymap fr fr

root_device=/dev/sda
efs_part=/dev/sda1
cryptfs_part=/dev/sda2

if [ -b "/dev/nvme0n1" ]; then
    root_device=/dev/nvme0n1
    efs_part="$root_device"p1
    cryptfs_part="$root_device"p2
fi

apk add --no-cache sfdisk lvm2 cryptsetup e2fsprogs parted mkinitfs dosfstools blkid
parted --align optimal --script "$root_device" \
    mklabel gpt \
    mkpart primary fat32 0% 100M \
    name 1 esp \
    set 1 esp on \
    mkpart primary ext4 100M 100% \
    name 2 crypto-luks

dd if=/dev/urandom of="$cryptfs_part" bs=1M count=1

#"cryptsetup -vq -c aes-xts-plain64 -s 256 --hash sha512 --pbkdf argon2id --pbkdf-force-iterations 4 --pbkdf-memory 65536 --pbkdf-parallel 4 --use-random luksFormat /dev/sda2
# GRUB does not support argon2 and by default the sha512 module is not loaded
# https://www.gnu.org/software/grub/manual/grub/grub.pdf page 82
echo "__LUKS__" | cryptsetup -vq --type luks1 -c aes-xts-plain64 -s 256 --hash sha256 --pbkdf pbkdf2 --iter-time 300 --use-random luksFormat "$cryptfs_part"
echo "__LUKS__" | cryptsetup open "$cryptfs_part" lvmcrypt

pvcreate /dev/mapper/lvmcrypt
vgcreate vg0 /dev/mapper/lvmcrypt
lvcreate -L 64M vg0 -n boot
lvcreate -l 100%FREE vg0 -n root
lvscan

mkfs.ext4 /dev/vg0/root
mkfs.ext4 /dev/vg0/boot
mkfs.fat -F32 -n EFI "$efs_part"

mount -t ext4 /dev/vg0/root /mnt/
mkdir -v /mnt/boot
mount -t ext4 /dev/vg0/boot /mnt/boot
mkdir -v /mnt/boot/efi
mount -t vfat -o iocharset=iso8859-15 "$efs_part" /mnt/boot/efi

mkdir -p /etc/default && echo 'GRUB_ENABLE_CRYPTODISK=y' >> /etc/default/grub
#"sed -i s/virtio/cryptsetup/ /etc/mkinitfs/mkinitfs.conf<enter><wait>",
sed -i -e '/^features=/ s/\"$/ cryptsetup cryptkey kms\"/' /etc/mkinitfs/mkinitfs.conf

setup-disk -m sys /mnt

sed -i -e '/^features=/ s/\"$/ cryptkey kms\"/' /mnt/etc/mkinitfs/mkinitfs.conf
sed -i -e '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\"$/ cryptkey\"/' /mnt/etc/default/grub
touch /mnt/crypto_keyfile.bin
chmod 600 /mnt/crypto_keyfile.bin
dd bs=512 count=4 if=/dev/urandom of=/mnt/crypto_keyfile.bin
echo "__LUKS__" | cryptsetup luksAddKey --iter-time 300 "$cryptfs_part" /mnt/crypto_keyfile.bin
mkinitfs -c /mnt/etc/mkinitfs/mkinitfs.conf -b /mnt/ $(ls /mnt/lib/modules/)
# removing second LUKS key from rootfs, so the only copy remaining would be in the initramfs
rm /mnt/crypto_keyfile.bin

mount -t proc /proc /mnt/proc
mount --rbind /dev /mnt/dev
mount --make-rslave /mnt/dev
mount --rbind /sys /mnt/sys
mount --bind /tmp /mnt/tmp
