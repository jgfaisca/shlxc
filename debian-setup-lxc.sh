#!/bin/bash
#
# setup debian for LXC containers
#
#
# Authors:
# Jose Faisca <jose.faisca@gmail.com>
#
# This work is licensed under the terms of the GNU GPL, version 2.  See
# the COPYING file in the top-level directory.

# default lxc configuration 
DEFAULT_CONF="/etc/lxc/default.conf"

# default linux bridge 
BRIDGE_NAME="lxcbr0"

do_install(){
pkg="$1" 
if apt-get -qq install $pkg; then
    echo "successfully installed package $pkg"
else
    echo "error installing package $pkg"
    exit 1
fi
}

# install lxc
do_install "lxc"

# install rsync
do_install "rsync"

# install dnsmasq
do_install "dnsmasq"

# install debootstrap
do_install "debootstrap"

# check qemu-user-static
do_install "qemu-user-static"

# install binfmt-support
do_install "binfmt-support"

# load binfmt_misc kernel module
lsmod | grep binfmt_misc
if [ $? -ne 0 ]; then
    modprobe binfmt_misc
fi

# check kernel configuration
lxc-checkconfig | grep missing
if [ $? -ne 0 ];then
   echo "WARNING: missing kernel configuration parameters" 1>&2
   lxc-checkconfig | grep missing
   read -n5 -rp "Press any key to continue..." key   
fi

# remove default lxc configuration
if [[ -s $DEFAULT_CONF ]]; then
 rm -f $DEFAULT_CONF
fi

# set new lxc default configuration
cat <<EOF > $DEFAULT_CONF
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = {$BRIDGE_NAME}
EOF

# mount the cgroup virtual filesystem
cat /etc/fstab | grep cgroup
if [ $? -ne 0 ]; then
   mkdir /cgroup
   echo "cgroup /sys/fs/cgroup cgroup defaults 0 0" >> /etc/fstab
   mount /sys/fs/cgroup
fi

echo "done!"

exit 0
