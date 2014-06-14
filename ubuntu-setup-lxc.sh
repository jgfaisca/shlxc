#!/bin/bash
# 
# setup ubuntu for LXC containers
#
# Authors:
# Jose Faisca <jose.faisca@gmail.com>
#
# This work is licensed under the terms of the GNU GPL, version 2.  See
# the COPYING file in the top-level directory.

# default lxc configuration 
DEFAULT_LXC_CONF="/etc/lxc/default.conf"
# default debian interfaces configuration
DEFAULT_NET_INTERFACES="/etc/network/interfaces"

# default linux bridge 
BRIDGE="lxcbr0"

do_install(){
pkg="$1" 
if apt-get -qq install $pkg; then
    echo "successfully installed package $pkg"
else
    echo "error installing package $pkg"
    exit 1
fi
}

# update
apt-get update

# install lxc
do_install "lxc"

# install lxc
do_install "lxc-templates"

# install lxc
do_install "lxctl"

# install rsync
do_install "rsync"

# remove dnsmasq
apt-get purge dnsmasq

# install debootstrap
do_install "debootstrap"

# install qemu-user-static
do_install "qemu-user-static"

# install qemu-system
do_install "qemu-system"

# install binfmt-support
do_install "binfmt-support"

# install bridge-utils
do_install "bridge-utils"

# load binfmt_misc kernel module
if ! lsmod | grep "binfmt_misc" > /dev/null 2> /dev/null; then
    echo "loading binfmt_misc kernel module"  	
    modprobe binfmt_misc
else
    echo "binfmt_misc kernel module is loaded" 	
fi

# check kernel configuration
if lxc-checkconfig | grep "missing" > /dev/null 2> /dev/null; then
   echo "WARNING: missing kernel configuration parameters"
   lxc-checkconfig | grep "missing"
else
   echo "all kernel configuration parameters are 'enabled'"
fi

echo "done!"

exit 0

