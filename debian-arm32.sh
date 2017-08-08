#!/bin/sh
set -ex

if [ ! -e installer-vmlinuz ]; then
	wget -O installer-vmlinuz http://http.us.debian.org/debian/dists/jessie/main/installer-armhf/current/images/netboot/vmlinuz
fi

if [ ! -e installer-initrd.gz ]; then
	wget -O installer-initrd.gz http://http.us.debian.org/debian/dists/jessie/main/installer-armhf/current/images/netboot/initrd.gz
fi

if [ ! -e hda.qcow2 ]; then
	qemu-img create -f qcow hda.qcow2 10G
fi

qemu-system-arm -M virt -m 4096 \
	  -kernel installer-vmlinuz \
	    -initrd installer-initrd.gz \
	      -drive if=none,file=hda.qcow2,format=qcow,id=hd \
	        -device virtio-blk-device,drive=hd \
		  -netdev user,id=mynet \
		    -device virtio-net-device,netdev=mynet \
		      -nographic -no-reboot
