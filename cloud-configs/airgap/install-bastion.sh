#!/bin/bash -ex
exec &>> /var/log/install.log

if blkid | grep RANCHER_STATE; then
	# don't re-format
	echo "DONE"
	exit
fi

INSTALL_DISK="/dev/vda"
if ! fdisk -l $INSTALL_DISK; then
	INSTALL_DISK="/dev/sda"
fi

(
cat << EOF
#cloud-init
rancher:
  services_include:
    pihole: true
    http-proxy: true
    registry-mirror: true
  password: rancher
  environment:
    # for pihole
    ServerIP: 10.11.11.1
    WEBPASSWORD: rancher
  network:
    interfaces:
      # the airgapped private network
      eth1:
        addresses:
        - 10.11.11.1/24
    #    gateway: 10.11.11.1
    #dns:
    #  nameservers:
    #  - 11.11.11.1
  repositories:
    roast:
      url: https://roastlink.github.io/
  # note: these are sven's home registies
  docker:
    registry_mirror: "http://10.10.10.23:5555"
    insecure_registry:
    - 10.10.10.23:5000
    - arian:5000
  system_docker:
    registry_mirror: "http://10.10.10.23:5555"
    insecure_registry:
    - 10.10.10.23:5000
    - arian:5000
ssh_authorized_keys:
- ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4lT2u93xi+ghKV/zmkSDLqDzGOVb0iZnmh3H6+jJuAiEJwrQ7a33nL9CYVhvlE+dvszVqJT5Q2VHexiuzguqCeaoQvn9preuIc0vvSVlxUwBRtNjKGPO5SmcDgiPKLqeLNgkKWBWaseZR/GdrXlnUD8snnatBtSh2mx1cwVJr0XdyTAtnCS5eyONzpBFpHZ7/dzzeSqjG3SAXwj/x41WDJE4bBNXlGOCJ1RYk9Z5HYH/fGt5B6V34hy/EKe9Wl4yaDdlL+JTXHWGTEhPL/+yaUM6SZT92XFq/H562t8EIAL15KX8FtOv4Q/U9ByZP8xcSir/VIKoGIfMdeRtZobSDvM0caEMUp6lI+5ErmynVExVtroSPdjVdX3q7Onuqcp6JvBFVngAcviuCZDCXuFfF9ikB1axBTGTQlCAebCBPapyBF8z6RFDROHmm5CeV3RozsHEaRqNzPBoG5Tz9Z3mmDE/i2ihLpET67dpQVI8H3/r4puNwtttHh93BmPR9ZB80iLf4Oim/y1joI7UQwc+TJg6eMBZMUWeR8dVhIXFgohiEfvuSUfs7j67V9IzzIefaRGKEv1bBnTYaOlD/KbPXOxYazZAm00wx6DvEfiKxwCOanbN0z+TMyi5WxCum7pSCUZ9+M767aPzRBipQokpBJTLuq5Tn+XAOU49AIt0a3Q==
  SvenDowideit@home.org.au
EOF
) > cloud-init.yml

sudo ros install -f \
	-d $INSTALL_DISK \
	--cloud-config cloud-init.yml \
	--no-reboot \
	--append "rancher.autologin=tty1"

echo "Install done"

# mount the newly installed partition, so we can customise and then save the log
sudo mount ${INSTALL_DISK}1 /mnt

echo "Rebooting"

# save the log files
mkdir -p /mnt/var/log/install/
cp -r /var/log/* /mnt/var/log/install/

# reboot --kexec is a v1.1.0 feature that will boot straight into the just created disk, without rebooting the hardware
# if you're using a pre-v1.1.0 version and have booted from cdrom/usb, you'll need to either eject the media, or have put the HD earlier in the boot order
reboot --kexec
