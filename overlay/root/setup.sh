#!/bin/sh

# install packages
apt-get update
apt-get -y install -o Dpkg::Options::="--force-confold" $(cat /root/packages)
update-initramfs -u

# create pxelinux links
ln -rsf /usr/lib/PXELINUX/pxelinux.0 /
ln -rsf /usr/lib/syslinux/modules/bios/ldlinux.c32 /
ln -rsf /usr/lib/SYSLINUX.EFI/efi32/syslinux.efi /
ln -rsf /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /syslinux64.efi

# update startup links
systemctl enable var.mount

# start systemd user instance at boot
# eq: loginctl enable-linger root
mkdir -p /var/lib/systemd/linger/
touch /var/lib/systemd/linger/root

# create / delete / clean files listed in /usr/lib/tmpfiles.d
# (this wont happen when starting with readonly root)
systemd-tmpfiles --create --remove --boot --exclude-prefix=/dev &> /dev/null
