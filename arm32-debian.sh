#!/bin/sh
set -ex

# see https://translatedcode.wordpress.com/2016/11/03/installing-debian-on-qemus-32-bit-arm-virt-board/

if [ ! -e installer-vmlinuz ]; then
	wget -O installer-vmlinuz http://http.us.debian.org/debian/dists/jessie/main/installer-armhf/current/images/netboot/vmlinuz
fi

if [ ! -e installer-initrd.gz ]; then
	wget -O installer-initrd.gz http://http.us.debian.org/debian/dists/jessie/main/installer-armhf/current/images/netboot/initrd.gz
fi

if [ ! -e hda.qcow2 ]; then
	qemu-img create -f qcow hda.qcow2 10G

	qemu-system-arm -M virt -m 4096 \
		-kernel installer-vmlinuz \
		-initrd installer-initrd.gz \
		-drive if=none,file=hda.qcow2,format=qcow,id=hd \
		-device virtio-blk-device,drive=hd \
		-netdev user,id=mynet \
		-device virtio-net-device,netdev=mynet \
		-nographic -no-reboot
	# TODO: copy out the vmlinz and initrd
	virt-copy-out -a hda.qcow2 /boot/vmlinuz-3.16.0-4-armmp-lpae /boot/initrd.img-3.16.0-4-armmp-lpae .
else
	qemu-system-arm -M virt -m 4096 \
	  -kernel vmlinuz-* \
	  -initrd initrd.img-* \
	  -append 'root=/dev/vda2' \
	  -drive if=none,file=hda.qcow2,format=qcow,id=hd \
	  -device virtio-blk-device,drive=hd \
	  -netdev user,id=mynet \
	  -device virtio-net-device,netdev=mynet \
	  -nographic
fi
