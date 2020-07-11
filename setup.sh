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


#raspotify setup

OPTIONS_VALUE="--device /tmp/snapfifo"
BACKEND_ARGS_VALUE="--backend pipe"
DEVICE_NAME_VALUE="Smarthome do gaba :)"

RASPOTIFY_FILE="/etc/default/raspotify"

echo -e "\n${GREEN}installing raspotify...${NC}"

curl -sL https://dtcooper.github.io/raspotify/install.sh | sh

echo -e "\n${LIGHT_BLUE}configuring raspotify...${NC}"

OPTIONS_CONF="OPTIONS=\"${OPTIONS_VALUE}\""
BACKEND_CONF="BACKEND_ARGS=\"${BACKEND_ARGS_VALUE}\""
DEVICE_NAME="DEVICE_NAME=\"${DEVICE_NAME_VALUE}\""
grep -q -e "^${OPTIONS_CONF}" "${RASPOTIFY_FILE}" || sudo sed -i "/#OPTIONS=/a ${OPTIONS_CONF}" "${RASPOTIFY_FILE}"
grep -q -e "^${BACKEND_CONF}" "${RASPOTIFY_FILE}" || sudo sed -i "/#BACKEND_ARGS=/a ${BACKEND_CONF}" "${RASPOTIFY_FILE}"
grep -q -e "^${DEVICE_NAME}" "${RASPOTIFY_FILE}" || sudo sed -i "/#DEVICE_NAME=/a ${DEVICE_NAME}" "${RASPOTIFY_FILE}"


#shairport setup

echo -e "\n${YELLOW}building shairport-sync...${NC}"
curl -sL https://github.com/mikebrady/shairport-sync/archive/3.3.7rc1.tar.gz | tar xz
cd shairport-sync-3.3.7rc1/
autoreconf -i -f
./configure --sysconfdir=/etc --with-pipe --with-systemd --with-convolution --with-mpris-interface --with-avahi --with-ssl=openssl
make

echo -e "\n${GREEN}installing shairport-sync...${NC}"
sudo make install
cd ..
rm -r shairport-sync-3.3.7rc1/
sudo systemctl enable shairport-sync

echo -e "\n${LIGHT_BLUE}configuring shairport-sync...${NC}"
sudo cp ./etc/shairport-sync.conf /etc/shairport-sync.conf


#snapserver setup

echo -e "\n${GREEN}installing snapcast server...${NC}"
curl -k -L https://github.com/badaix/snapcast/releases/download/v0.20.0/snapserver_0.20.0-1_armhf.deb -o 'snapserver.deb' &&
sudo dpkg -i snapserver.deb
rm -f snapserver.deb


echo -e "\n${LIGHT_BLUE}configuring snapserver...${NC}"
sudo sed -i "0,/^stream.*/s//first_mark_point_stream/" /etc/snapserver.conf
sudo sed -i "s/^stream.*//g" /etc/snapserver.conf

sudo sed -i "s/^first_mark_point_stream/# raspotify pipe stream\\n# shairport pipe stream/g" /etc/snapserver.conf

value="stream = pipe:///tmp/snapfifo?name=Spotify&sampleformat=44100:16:2"
sudo sed -i  "/# raspotify pipe stream/a ${value}" /etc/snapserver.conf
value="stream = pipe:///tmp/snapfifo_shairport?name=ShairportSync&sampleformat=44100:16:2"
sudo sed -i  "/# shairport pipe stream/a ${value}" /etc/snapserver.conf


#snapclient setup

echo -e "\n${GREEN}installing snapcast client...${NC}"
curl -k -L https://github.com/badaix/snapcast/releases/download/v0.20.0/snapclient_0.20.0-1_armhf.deb -o 'snapclient.deb' &&
sudo dpkg -i snapclient.deb
rm -f snapclient.deb

echo -e "\n${LIGHT_BLUE}configuring snapclient (only tested on raspberry pi 4)${NC}"
echo 'SNAPCLIENT_OPTS="${SNAPCLIENT_OPTS} -s Headphones"' | sudo tee -a /etc/default/snapclient

echo -e "\n${CYAN}restarting raspotify, shairport-sync and snapcast services${NC}"
sudo systemctl restart raspotify.service
sudo systemctl restart shairport-sync.service
sudo systemctl restart snapserver.service
sudo systemctl restart snapclient.service
