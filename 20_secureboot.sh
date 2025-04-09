#!/bin/sh

# shim ?
apk add efivar dpkg #-dev nspr-dev util-linux-dev nss-dev
wget 'https://launchpad.net/ubuntu/+archive/primary/+files/shim-signed_1.59+15.8-0ubuntu2_amd64.deb'
dpkg -x shim-signed_1.59+15.8-0ubuntu2_amd64.deb shim
#mv /mnt/boot/efi/EFI/BOOT/BOOTX64.EFI /mnt/boot/efi/EFI/BOOT/grubx64.efi
#cp shim/usr/lib/shim/shimx64.efi.signed.latest /mnt/boot/efi/EFI/BOOT/BOOTX64.EFI
#mkdir /mnt/boot/efi/EFI/ubuntu
#cp /mnt/boot/efi/EFI/alpine/grubx64.efi /mnt/boot/efi/EFI/ubuntu/
#cp shim/usr/lib/shim/mmx64.efi /mnt/boot/efi/EFI/BOOT/

# shim key??
apk add openssl sbsigntool
openssl req -newkey rsa:2048 -nodes -keyout /mnt/boot/efi/MOK.key -new -x509 -sha256 -days 3650 -subj "/CN=my Machine Owner Key/" -out /mnt/boot/efi/MOK.crt -addext "extendedKeyUsage=codeSigning,1.3.6.1.4.1.2312.16.1.2"
openssl x509 -outform DER -in /mnt/boot/efi/MOK.crt -out /mnt/boot/efi/MOK.cer
#sbsign --key /mnt/boot/efi/MOK.key --cert /mnt/boot/efi/MOK.crt --output /mnt/boot/vmlinuz-virt /mnt/boot/vmlinuz-virt
#sbsign --key /mnt/boot/efi/MOK.key --cert /mnt/boot/efi/MOK.crt --output /mnt/boot/efi/EFI/boot/grubx64.efi /mnt/boot/efi/EFI/boot/grubx64.efi
#sbsign --key /mnt/boot/efi/MOK.key --cert /mnt/boot/efi/MOK.crt --output /mnt/boot/efi/EFI/ubuntu/grubx64.efi /mnt/boot/efi/EFI/ubuntu/grubx64.efi
