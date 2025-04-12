#!/bin/sh

echo 'Unmounting partitions'
umount /mnt/tmp
umount -l /mnt/dev
umount -l /mnt/proc
umount -l /mnt/sys
umount /mnt/boot/efi
umount /mnt/boot
umount /mnt
vgchange -a n
cryptsetup close lvmcrypt
