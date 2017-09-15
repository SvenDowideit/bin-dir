
# RancherOS airgap demo setup

Set up an airgap like virtual network with nodes that can only get files and images from the internet using the dual-homed bastion host.

All hosts will be configured only using docker-machine to VMWare ESXi (initially), a cloud-init file, and whatever service definitions and images that references.

Initially, I'm going to use my roastlink services repo

## Bastion host

Minimally runs:
* DNS / DNS proxy (pi-hole)
* HTTP Proxy
* Registry mirror
* each vm is given a static IP (using vmware guest-info)

Optionally runs:
* DHCP server for the isolated network (pi-hole)
* local registry server
* Reverse proxy - so external users can access apps running on the inner network
* web server for config / services files
* apt-cacher-ng
* non-amd64?

## nodes on airgapped network

can Only talk to the services on the Bastion, and each other.
