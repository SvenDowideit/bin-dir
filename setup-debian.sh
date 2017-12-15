#!/bin/sh
set -ex
cd $HOME
# and lets log the output
exec &>> install.log

if [ ! -e "/usr/local/bin/docker-compose" ]; then

	sudo curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
	sudo chmod 755 /usr/local/bin/docker-compose
	echo "export PATH=/usr/local/bin:$PATH" >> .bashrc
fi

# curl -s https://api.github.com/repos/boxbilling/boxbilling/releases/latest | grep browser_download_url | cut -d '"' -f 4
if [ ! -e "/usr/local/bin/docker-machine" ]; then
	sudo curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m` -o /usr/local/bin/docker-machine 
	sudo chmod +x /usr/local/bin/docker-machine
fi

# TODO: work out how to wait for the apt/dpkg lock
# this bit is redundant if we're creating with docker-machine, but that's not always the case.
if ! which docker ; then
	wget -O docker.install.sh https://get.docker.com
	chmod 755 ./docker.install.sh
	sudo ./docker.install.sh
fi
sudo adduser $(whoami) docker

sudo apt-get update
sudo apt-get upgrade -yq
sudo apt-get install -yq vim git make build-essential

if [ ! -e "bin" ]; then
	git clone https://github.com/SvenDowideit/bin-dir
	mv bin-dir bin
	echo "export PATH=$HOME/bin:$PATH" >> .bashrc
fi

