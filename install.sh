#!/bin/sh

DIR=$PWD
TARGET_DIR=${DIR}/target
IMAGES_DIR=${DIR}/images
IP_NETMASK=`ip -o -f inet addr show scope global | awk '{print $4}'`
IP_BROADCAST=`ip -o -f inet addr show scope global | awk '{print $6}'`

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
    pkg="dnsmasq"
    check_dpkg
    pkg="nfs-kernel-server"
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

# install packages
check_host
check_packages

# place dnsmasq config
cp -b ${DIR}/config/dnsmasq.conf /etc/
sed -i -e "s~IP_BROADCAST~${IP_BROADCAST}~g" /etc/dnsmasq.conf
sed -i -e "s~TARGET_DIR~${TARGET_DIR}~g" /etc/dnsmasq.conf
echo "updated /etc/dnsmasq.conf, restarting dnsmasq ..."
systemctl restart dnsmasq

# place nfs-kernel-server config
cp -b ${DIR}/config/exports /etc/
sed -i -e "s~IP_NETMASK~${IP_NETMASK}~g" /etc/exports
sed -i -e "s~TARGET_DIR~${TARGET_DIR}~g" /etc/exports
sed -i -e "s~IMAGES_DIR~${IMAGES_DIR}~g" /etc/exports
mkdir -p ${IMAGES_DIR}
echo "updated /etc/exports, restarting nfs-kernel-server ..."
systemctl restart nfs-kernel-server
