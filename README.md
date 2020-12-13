# Netboot-Linux: Clonezilla

Creates a network-bootable Debian-Linux installation in a single folder on any Debian-Linux host system.
Will respond to PXE broadcasts on the LAN without interfering with existing DHCP servers.
The Clonezilla branch has clients start clonezilla configured to read or write partition images to a remote directory.

Features:
- PXE boot files hosted by dnsmasq in proxy mode
- Root filesystem mounted readonly over NFS
- Var filesystem mounted read/write using overlayfs
- Images directory mounted over NFS

# Configure

1) Architecture and distro can be configured setup.sh:

```
ARCH="amd64"
DISTRO="buster"
MIRROR="http://ftp.debian.org/debian/"
```

The architecture does not need to match the host architecture.

2) Additional packages can be installed by adding the to the package list:

```
overlay/root/packages
```

Default is a minimum install with only Clonezilla and its dependencies.

# Install

1) Clone this repository to a Debian based host system

2) Change architecture, distro and packages as desired (see config)

3) Run 'make'

The bootable installation will be created in subdirectory 'target'.

4) Run 'make install'

The host system will be configured:
- Config for dnsmasq will be placed, to respond to received network boot DHCP broadcasts (as proxy only).
- Config for nfs-kernel-server will be placed, to allow mounting the target filesystem over NFS. Also the local subdirectory 'images' is created and mounted for use by Clonezilla.
