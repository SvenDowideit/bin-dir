#!/bin/bash
set -ex
cd $HOME
# and lets log the output

echo "See the output of this script in ${HOME}/install.log"
exec &>> install.log

sudo apt-get update
sudo apt-get upgrade -yq
sudo apt-get install -yq vim git make build-essential curl \
					i3 meld

ADDPATH="export PATH=/usr/local/bin:\$PATH"
if  ! grep "^$ADDPATH$" ~/.bashrc ; then
	echo "$ADDPATH" >> .bashrc
fi

function github_install() {
	local repo="$1"			#for example, docker/machine
	local destination="$2"	#for example /usr/local/bin/docker-machine

	local url=$(curl -s https://api.github.com/repos/${repo}/releases/latest | grep browser_download_url  | cut -d '"' -f 4 | grep $(uname -s)-$(uname -m) | head -n 1)
	local version=$(echo "${url}" | sed 's|.*/releases/download/||' | sed 's|/.*||')
	if [[ ! -e "${destination}" || ! "$(${destination} version)" =~ ${version/v/} ]]; then
		sudo curl -L "${url}" -o "${destination}" 
		sudo chmod +x "${destination}"
	fi
}

github_install docker/machine /usr/local/bin/docker-machine
github_install docker/compose /usr/local/bin/docker-compose

# TODO: work out how to wait for the apt/dpkg lock
# this bit is redundant if we're creating with docker-machine, but that's not always the case.
if ! which docker ; then
	wget -O docker.install.sh https://get.docker.com
	chmod 755 ./docker.install.sh
	sudo ./docker.install.sh
fi
sudo adduser $(whoami) docker
sudo adduser debian docker || true

mkdir -p ~/.docker/cli-plugins/
github_install docker/buildx ~/.docker/cli-plugins/docker-buildx
docker buildx install

if [ ! -e bin ]; then
	git clone https://github.com/SvenDowideit/bin-dir
	mv bin-dir bin
fi
ADDPATH="export PATH=$HOME/bin:\$PATH"
if  ! grep "^$ADDPATH$" ~/.bashrc ; then
	echo "$ADDPATH" >> .bashrc
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
git config --global url.ssh://git@github.com/.insteadOf https://github.com/

# see if there's swap, if not set some up...
#if [ ! -e "/swap" ]; then
#	sudo dd if=/dev/zero of=/swap bs=1024 count=4096000
#	sudo mkswap /swap
#	sudo swapon /swap
#	sudo sh -s 'echo "/swap swap swap defaults 0 0" >> /etc/fstab'
#fi
