#!/bin/bash
set -ex
cd $HOME
# and lets log the output
exec &>> install.log

sudo apt-get update
sudo apt-get upgrade -yq
sudo apt-get install -yq vim git make build-essential curl

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
sudo adduser debian docker || true

if ! -e "~/.docker/cli-plugins/docker-buildx"; then
	BUILDX_VERSION=$(curl https://github.com/docker/buildx/releases/latest | sed 's/.*tag\///' | sed 's/".*//')
	curl -L https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64 \
	-o ~/.docker/cli-plugins/docker-buildx
	chmod a+x ~/.docker/cli-plugins/docker-buildx
	docker buildx install
fi

sudo apt-get update
sudo apt-get upgrade -yq
sudo apt-get install -yq vim git make build-essential

if [ ! -e bin ]; then
	git clone https://github.com/SvenDowideit/bin-dir
	mv bin-dir bin
	echo "export PATH=$HOME/bin:$PATH" >> .bashrc
fi

# add vscode
if ! which code ; then
	curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
	sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
	sudo apt-get install apt-transport-https
	sudo apt-get update
	sudo apt-get install code # or code-insiders
fi

if [[ "$(git config --global user.email)" == "" ]]; then
  git config --global user.email "SvenDowideit@home.org.au"
  git config --global user.name "Sven Dowideit"
fi

# see if there's swap, if not set some up...
#if [ ! -e "/swap" ]; then
#	sudo dd if=/dev/zero of=/swap bs=1024 count=4096000
#	sudo mkswap /swap
#	sudo swapon /swap
#	sudo sh -s 'echo "/swap swap swap defaults 0 0" >> /etc/fstab'
#fi
