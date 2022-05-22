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

DEVICE_NAME=$(hostname)
read -p "Device name (default is '$DEVICE_NAME'): " DEVICE_NAME


# arguments
INSTALL_SHAIRPORT=true
INSTALL_RASPOTIFY=true
INSTALL_BLUETOOTH=true
 # fonte de como usar isso: https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
while (( "$#" )); do
  case "$1" in
    --no-shairport)
      INSTALL_SHAIRPORT=false
      shift
      ;;
    --no-spotify)
      INSTALL_RASPOTIFY=false
      shift
      ;;
    --no-bluetooth)
      INSTALL_BLUETOOTH=false
      shift
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      echo "Error: this script take no arguments $1" >&2
      exit 1
      ;;
  esac
done


# raspotify setup
if $INSTALL_RASPOTIFY; then
  OPTIONS_VALUE="--device /run/snapserver/snapfifo_raspotify"
  BACKEND_ARGS_VALUE="--backend pipe"

  RASPOTIFY_FILE="/etc/default/raspotify"

  echo -e "\n${GREEN}installing raspotify...${NC}"
  sudo apt-get -y install curl && curl -sL https://dtcooper.github.io/raspotify/install.sh | sh

  echo -e "\n${LIGHT_BLUE}configuring raspotify...${NC}"

  OPTIONS_CONF="OPTIONS=\"${OPTIONS_VALUE}\""
  BACKEND_CONF="BACKEND_ARGS=\"${BACKEND_ARGS_VALUE}\""
  DEVICE_NAME_CONF="DEVICE_NAME=\"${DEVICE_NAME}\""
  grep -q -e "^${OPTIONS_CONF}" "${RASPOTIFY_FILE}" || sudo sed -i "/#OPTIONS=/a ${OPTIONS_CONF}" "${RASPOTIFY_FILE}"
  grep -q -e "^${BACKEND_CONF}" "${RASPOTIFY_FILE}" || sudo sed -i "/#BACKEND_ARGS=/a ${BACKEND_CONF}" "${RASPOTIFY_FILE}"
  grep -q -e "^${DEVICE_NAME_CONF}" "${RASPOTIFY_FILE}" || sudo sed -i "/#DEVICE_NAME=/a ${DEVICE_NAME_CONF}" "${RASPOTIFY_FILE}"
fi

# shairport setup
if $INSTALL_SHAIRPORT; then
  SHAIRPORT_VERSION="3.3.8"
  echo -e "\n${YELLOW}building shairport-sync...${NC}"
  curl -sL https://github.com/mikebrady/shairport-sync/archive/$SHAIRPORT_VERSION.tar.gz | tar xz
  cd shairport-sync-$SHAIRPORT_VERSION/
  autoreconf -i -f
  ./configure 'CFLAGS=-O3' 'CXXFLAGS=-O3' --sysconfdir=/etc --with-pipe --with-systemd --with-avahi --with-ssl=openssl
  make

  echo -e "\n${GREEN}installing shairport-sync...${NC}"
  sudo make install
  cd ..
  rm -r shairport-sync-$SHAIRPORT_VERSION/
  sudo systemctl enable shairport-sync

  echo -e "\n${LIGHT_BLUE}configuring shairport-sync...${NC}"
  sudo cp ./etc/shairport-sync.conf /etc/shairport-sync.conf
  sed -i "s/<DEVICE_NAME>/$DEVICE_NAME/" /etc/shairport-sync.conf
fi

# bluetooth setup
if $INSTALL_BLUETOOTH; then
  if ! command -v bluealsa &> /dev/null; then
    echo -e "\n${RED}bluealsa could not be found${NC}"
    echo -e "${LIGHT_GRAY}skipping bluetooth instalation${NC}"
    INSTALL_BLUETOOTH=false
  else
    echo -e "\n${LIGHT_BLUE}configuring BlueAlsa...${NC}"
    bash ./scripts/config-bluetooth.sh "$DEVICE_NAME"
    mkdir -p /usr/local/share/sounds/bluetooth/
    cp ./files/bt-device-connected.wav /usr/local/share/sounds/bluetooth/device-connected.wav
    cp ./files/bt-device-disconnected.wav /usr/local/share/sounds/bluetooth/device-disconnected.wav
  fi
fi

# snapserver setup
echo -e "\n${GREEN}installing snapcast server...${NC}"
curl -k -L https://github.com/badaix/snapcast/releases/download/v0.25.0/snapserver_0.25.0-1_armhf.deb -o 'snapserver.deb' &&
sudo apt install ./snapserver.deb -y
rm -f snapserver.deb


echo -e "\n${LIGHT_BLUE}configuring snapserver...${NC}"
sudo cp ./etc/snapserver.conf /etc/snapserver.conf
sed -i '/\[Service\]/a RuntimeDirectory=snapserver' /lib/systemd/system/snapserver.service


echo -e "\n${CYAN}restarting raspotify, shairport-sync and snapcast services${NC}"
if $INSTALL_RASPOTIFY; then sudo systemctl restart raspotify.service; fi
if $INSTALL_SHAIRPORT; then sudo systemctl restart shairport-sync.service; fi
if $INSTALL_BLUETOOTH; then sudo systemctl restart bluealsa.service bluealsa-aplay.service; fi
sudo systemctl daemon-reload
sudo systemctl restart snapserver.service
