#!/bin/sh

set -ex

# ===| Install shim from Ubuntu Noble |========================================
apk add dpkg zstd lsblk mokutil sbsigntool
wget 'https://launchpad.net/ubuntu/+archive/primary/+files/shim-signed_1.58+15.8-0ubuntu1_amd64.deb'
dpkg -x shim-signed_1.58+15.8-0ubuntu1_amd64.deb _shim
install _shim/usr/lib/shim/shimx64.efi.signed.latest /mnt/boot/efi/EFI/boot/bootx64.efi
install _shim/usr/lib/shim/mmx64.efi /mnt/boot/efi/EFI/boot/


# ===| Install GRUB2 from Ubuntu Noble |=======================================
wget 'http://launchpadlibrarian.net/755896961/grub-efi-amd64-signed_1.202.2+2.12-1ubuntu7.1_amd64.deb'
dpkg -x grub-efi-amd64-signed_1.202.2+2.12-1ubuntu7.1_amd64.deb _grub
install -D _grub/usr/lib/grub/x86_64-efi-signed/grubx64.efi.signed /mnt/boot/efi/EFI/boot/grubx64.efi

# ===| Copy the Alpine's grub.cfg to /boot/efi/EFI/boot/ |=====================
crypt_uuid=$(lsblk -o uuid -nd /dev/sda2)
install -D /mnt/boot/grub/grub.cfg /mnt/boot/efi/EFI/boot/grub.cfg
sed -i -e '/insmod/d' -e '/load_video/d' -e '/initrd/a \\tboot' /mnt/boot/efi/EFI/boot/grub.cfg

# ===| Generating MOK key |====================================================
openssl req -newkey rsa:2048 -nodes -keyout MOK.key -new -x509 -sha256 -days 3650 -subj "/CN=my Machine Owner Key/O=Kveer/" -out MOK.crt -addext "extendedKeyUsage=codeSigning,1.3.6.1.4.1.2312.16.1.1"
sbsign --key MOK.key --cert MOK.crt --output /mnt/boot/vmlinuz-virt /mnt/boot/vmlinuz-virt
openssl x509 -in MOK.crt -out /mnt/boot/efi/MOK.crt -outform DER
echo -e "sdfghjkl\nsdfghjkl" | mokutil -i /mnt/boot/efi/MOK.crt

# ===| Cleaning |==============================================================
rm MOK.key
rm -R shim* _shim* grub* _grub*
