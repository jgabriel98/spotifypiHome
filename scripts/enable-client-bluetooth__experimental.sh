#!/bin/bash -e
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

THIS_PATH=`pwd`

DEVICE_NAME=$(hostname)
read -p "Device name (default is '$DEVICE_NAME'): " DEVICE_NAME

#apt install -y --no-install-recommends bluealsa

bash config-bluetooth-client.sh "$DEVICE_NAME"

mkdir -p /usr/local/share/sounds/bluetooth/
cp ../files/bt-device-connected.wav /usr/local/share/sounds/bluetooth/device-connected.wav
cp ../files/bt-device-disconnected.wav /usr/local/share/sounds/bluetooth/device-disconnected.wav

sudo systemctl restart bluealsa.service bluealsa-aplay.service
