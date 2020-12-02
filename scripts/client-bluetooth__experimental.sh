#!/bin/bash -e
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

apt install -y --no-install-recommends bluealsa

bash config-bluetooth.sh $(hostname)
mkdir -p /usr/local/share/sounds/bluetooth/
cp ../files/bt-device-connected.wav /usr/local/share/sounds/bluetooth/device-connected.wav
cp ../files/bt-device-disconnected.wav /usr/local/share/sounds/bluetooth/device-disconnected.wav

sudo systemctl restart bluealsa.service bluealsa-aplay.service
