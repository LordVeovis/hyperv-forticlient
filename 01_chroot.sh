#!/bin/sh

source /etc/profile
export PS1="[chroot] $PS1"

/usr/libexec/rc/bin/einfo Generating GRUB config
apk add grub grub-efi efibootmgr lvm2 cryptsetup blkid
echo 'GRUB_ENABLE_CRYPTODISK=y' >> /etc/default/grub
install -m 0755 /tmp/05_users /etc/grub.d/05_users
sed -i -e 's/\(title.*CLASS\}\)/\1 --unrestricted/' /etc/grub.d/10_linux
grub-mkconfig -o /boot/grub/grub.cfg

/usr/libexec/rc/bin/einfo Enabling Hyper-V guest tools
apk add --no-cache hvtools
rc-update add hv_fcopy_daemon default
rc-update add hv_kvp_daemon default
rc-update add hv_vss_daemon default

/usr/libexec/rc/bin/einfo Configuring firewall
apk add --no-cache iproute2 nftables
install -m 0540 -o root -g root /tmp/nftables.nft /etc/nftables.nft
rc-update add nftables boot
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/forwarding.conf

/usr/libexec/rc/bin/einfo Installing OpenfortiVPN
echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories
apk add --no-cache openfortivpn@edge
install -m 0440 -o root -g root /tmp/openfortivpn.conf /etc/openfortivpn/config
chmod u+s /usr/bin/openfortivpn
echo 'ppp_async' >> /etc/modules
sed -ie 's!^\(tty1::respawn:\).*!\1/usr/bin/openfortivpn!' /etc/inittab

/usr/libexec/rc/bin/einfo Disable ipv6
sed -ie '/ipv6/d' /etc/modules

/usr/libexec/rc/bin/einfo Disabling SSH server
rc-update del sshd default

#/usr/libexec/rc/bin/einfo Creating hardened user
#vpnuser=vpn
#ln -s bash /bin/rbash
#adduser -D -s /usr/bin/openfortivpn $vpnuser
#echo "$vpnuser:" | chpasswd -e
#echo 'export PATH=$HOME/bin' > /home/$vpnuser/.bashrc
#install -m 0640 -o root -g root /tmp/10-bashrc.sh /etc/profile.d/10-bashrc.sh
#install -d -m 0440 -o root -g root /home/$vpnuser/bin
#ln -s /usr/bin/openfortivpn /home/$vpnuser/bin/

/usr/libexec/rc/bin/einfo Locking root user
echo 'root:__ROOT_PWD__' | chpasswd
deluser packer
