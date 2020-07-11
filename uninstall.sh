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

echo -e "\n${YELLOW}removing ${LIGHT_BLUE}shairport${NC}"

echo -e "\n${WHITE}building ${LIGHT_BLUE}shairport${WHITE} makefile${NC}"
if command -v shairport-sync &> /dev/null; then
	curl -sL https://github.com/mikebrady/shairport-sync/archive/3.3.7rc1.tar.gz | tar xz
	cd shairport-sync-3.3.7rc1/
	autoreconf -i -f
	./configure --sysconfdir=/etc --with-pipe --with-systemd --with-convolution --with-mpris-interface --with-avahi --with-ssl=openssl
	
	echo -e "\n${YELLOW}runing make uninstall for ${LIGHT_BLUE}shairport${NC}"
	sudo make uninstall
	rm -r shairport-sync-3.3.7rc1/

	echo -e "\n${YELLOW}cleaning ${LIGHT_BLUE}shairport${YELLOW}configuration files${NC}"
	sudo systemctl stop shairport-sync.service
	sudo systemctl disable shairport-sync.service
	sudo rm /etc/systemd/system/shairport-sync.service
	sudo rm /lib/systemd/system/shairport-sync.service
	sudo rm /etc/init.d/shairport-sync

else
	echo -e "\n${LIGHT_BLUE}shairport${WHITE} was not installed"
fi