#!/bin/sh

ARCH="amd64"
DISTRO="buster"
MIRROR="http://ftp.debian.org/debian/"

DIR=$PWD
TARGET_DIR=${DIR}/target
CORES=$(getconf _NPROCESSORS_ONLN)
IP_ADDRESS=$(ip route get 1 | awk '{print $NF;exit}')

check_host () {
    if [ ! -f /etc/debian_version ] ; then
    echo "This script must be executed on a Debian based system."
    exit 1
    fi
}

check_dpkg () {
    LC_ALL=C dpkg --list | awk '{print $2}' | grep "^${pkg}$" >/dev/null || deb_pkgs="${deb_pkgs}${pkg} "
}

check_packages () {
    unset deb_pkgs
    pkg="binfmt-support"
    check_dpkg
    pkg="qemu"
    check_dpkg
    pkg="qemu-user-static"
    check_dpkg
    pkg="debootstrap"
    check_dpkg
    pkg="systemd-container"
    check_dpkg
    pkg="lzop"
    check_dpkg

    if [ "${deb_pkgs}" ] ; then
    echo "Missing dependencies, please run:"
    echo "-----------------------------"
    echo "sudo apt-get update"
    echo "sudo apt-get install ${deb_pkgs}"
    echo "-----------------------------"
    exit 2
    fi
}

# check if root
if [ `whoami` != 'root' ]; then
    echo "Script must be run as root."
    exit 3
fi

# create debian system in target directory
if [ ! -d ${TARGET_DIR} ] ; then
    check_host
    check_packages
    mkdir ${TARGET_DIR}
    qemu-debootstrap --arch ${ARCH} ${DISTRO} ${TARGET_DIR} ${MIRROR}
fi

# copy overlay
cp -PR ${DIR}/overlay/* ${TARGET_DIR}/

# update pxe config
sed -i -e "s~IP_ADDRESS~${IP_ADDRESS}~g" ${TARGET_DIR}/pxelinux.cfg/default
sed -i -e "s~TARGET_DIR~${TARGET_DIR}~g" ${TARGET_DIR}/pxelinux.cfg/default

# enable autologin
sed -i -e 's/ExecStart=.*/ExecStart=\/sbin\/agetty -a root --noclear %I $TERM/g' ${TARGET_DIR}/lib/systemd/system/getty@.service

# execute internal setup.sh
systemd-nspawn -D ${TARGET_DIR} root/setup.sh
