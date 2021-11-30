#!/bin/bash

# Colors definition
NC='\033[0m' # No Color
WHITE='\033[1;37m'
BLACK='\033[0;30m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
LIGHT_BLUE='\033[1;34m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_CYAN='\033[1;36m'
LIGHT_GRAY='\033[0;37m'
DARK_GRAY='\033[1;30m'

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

if command -v snapclient &> /dev/null; then
	echo -e "\n${YELLOW}removing ${LIGHT_BLUE}snapclient${NC}"
	sudo apt remove --purge snapclient -y
else
	echo -e "\n${LIGHT_BLUE}snapclient${WHITE} was not installed"
fi

if command -v snapserver &> /dev/null; then
	echo -e "\n${YELLOW}removing ${LIGHT_BLUE}snapserver${NC}"
	sudo apt remove --purge snapserver -y
else
	echo -e "\n${LIGHT_BLUE}snapserver${WHITE} was not installed"
fi

if command -v librespot &> /dev/null; then
	echo -e "\n${YELLOW}removing ${LIGHT_BLUE}raspotify${NC}"
	sudo apt remove --purge raspotify -y
else
	echo -e "\n${LIGHT_BLUE}raspotify${WHITE} was not installed"
fi

if command -v bluealsa-aplay &> /dev/null; then
	echo -e "\n${ORANGE}removing* ${LIGHT_BLUE}bluealsa${NC}"
	sudo apt remove --purge bluealsa -y
	sudo rm -r /etc/systemd/system/bthelper@.service.d
	sudo mv /etc/bluetooth/main.conf.custom_bak  /etc/bluetooth/main.conf
	sudo mv /etc/systemd/system/bt-agent.service.custom_bak /etc/systemd/system/bt-agent.service
	sudo mv /lib/modprobe.d/aliases.conf.custom_bak /lib/modprobe.d/aliases.conf
	#sudo rm /etc/systemd/system/bluealsa.service.d/override.conf && sudo rm -d /etc/systemd/system/bluealsa.service.d/
	sudo sed -i '/# spotifypiHome config for bluealsa/,/# end/d' /etc/alsa/conf.d/20-bluealsa.conf
else
	echo -e "\n${LIGHT_BLUE}bluealsa${WHITE} was not installed"
fi

if command -v shairport-sync &> /dev/null; then
	SHAIRPORT_VERSION="3.3.8"
	echo -e "\n${YELLOW}removing ${LIGHT_BLUE}shairport${NC}"
	echo -e "\n${WHITE}building ${LIGHT_BLUE}shairport${WHITE} makefile${NC}"
	curl -sL https://github.com/mikebrady/shairport-sync/archive/$SHAIRPORT_VERSION.tar.gz | tar xz
	cd shairport-sync-$SHAIRPORT_VERSION/
	autoreconf -i -f
	./configure --sysconfdir=/etc --with-pipe --with-systemd --with-avahi --with-ssl=openssl

	echo -e "\n${YELLOW}runing make uninstall for ${LIGHT_BLUE}shairport${NC}"
	sudo make uninstall
	rm -r shairport-sync-$SHAIRPORT_VERSION/

	echo -e "\n${YELLOW}cleaning ${LIGHT_BLUE}shairport${YELLOW}configuration files${NC}"
	sudo systemctl stop shairport-sync.service
	sudo systemctl disable shairport-sync.service
	sudo rm /etc/systemd/system/shairport-sync.service
	sudo rm /lib/systemd/system/shairport-sync.service
	sudo rm /etc/init.d/shairport-sync

else
	echo -e "\n${LIGHT_BLUE}shairport${WHITE} was not installed"
fi
