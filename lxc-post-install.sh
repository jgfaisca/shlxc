#!/bin/bash

# ubuntu/debian post-install lxc configuration  

# Create essential device nodes used by lxc
rm -f /dev/null
mknod -m 666 /dev/null c 1 3
mknod -m 666 /dev/zero c 1 5
mknod -m 666 /dev/urandom c 1 9
ln -s /dev/urandom /dev/random
mknod -m 600 /dev/console c 5 1
mknod -m 660 /dev/tty1 c 4 1
chown root:tty /dev/tty1

# Create essential directories.
mkdir -p /dev/shm
chmod 1777 /dev/shm
mkdir -p /dev/pts
chmod 755 /dev/pts

#Copy profile settings from skeleton directory

mknod -m 660 /dev/tty1 c 4 1
chown root:tty /dev/tty1

# Create essential directories.
mkdir -p /dev/shm
chmod 1777 /dev/shm
mkdir -p /dev/pts
chmod 755 /dev/pts

# Copy profile settings from skeleton directory
cp -a /etc/skel/. /root/.

# Create necessary files for networking support 
cat > /etc/resolv.conf << END
# Google public DNS
nameserver 8.8.8.8
nameserver 8.8.4.4
END

cat > /etc/hosts << END
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
127.0.1.1   centos6
END

cat > /etc/sysconfig/network << END
NETWORKING=yes
HOSTNAME=centos6
END

cat > /etc/sysconfig/network-scripts/ifcfg-eth0  << END
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
END

# Create an minimal /etc/fstab 
cat > /etc/fstab << END 
/dev/root  /          rootfs   defaults        0 0
none       /dev/shm   tmpfs    nosuid,nodev    0 0
END

# Create lxc compatibility init script 
cat > /etc/init/lxc-sysinit.conf << END
start on startup
env container
pre-start script
        if [ "x$container" != "xlxc" -a "x$container" != "xlibvirt" ]; then
                stop;
        fi
        initctl start tty TTY=console
        rm -f /var/lock/subsys/*
        rm -f /var/run/*.pid
        telinit 3
        exit 0;
end script
END

echo "done!!"
exit 0
