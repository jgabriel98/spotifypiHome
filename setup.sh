#!/bin/bash

OPTIONS_VALUE="--device /tmp/snapfifo"
BACKEND_ARGS_VALUE="--backend pipe"

RASPOTIFY_FILE="/etc/default/raspotify"

echo 'installing raspotify...'
curl -sL https://dtcooper.github.io/raspotify/install.sh | sh

echo 'configuring raspotify...'

OPTIONS_CONF="OPTIONS=\"${OPTIONS_VALUE}\""
BACKEND_CONF="BACKEND_ARGS=\"${BACKEND_ARGS_VALUE}\""
grep -q -e "^${OPTIONS_CONF}" "${RASPOTIFY_FILE}" || sed -i "/#OPTIONS=/a ${OPTIONS_CONF}" "${RASPOTIFY_FILE}"
grep -q -e "^${BACKEND_CONF}" "${RASPOTIFY_FILE}" || sed -i "/#BACKEND_ARGS=/a ${BACKEND_CONF}" "${RASPOTIFY_FILE}"


echo 'installing snapcast server...'
curl -k -L https://github.com/badaix/snapcast/releases/download/v0.19.0/snapserver_0.19.0-1_armhf.deb -o 'snapserver.deb' &&
sudo dpkg -i snapserver.deb
rm -f snapserver.deb

echo 'installing snapcast client...'
curl -k -L https://github.com/badaix/snapcast/releases/download/v0.19.0/snapclient_0.19.0-1_armhf.deb -o 'snapclient.deb' &&
sudo dpkg -i snapclient.deb
rm -f snapclient.deb


echo 'configuring snapserver...'
value="stream = pipe:///tmp/snapfifo?name=Spotify&sampleformat=44100:16:2"
sed -i "s/^stream.*/# raspotify pipe stream/g" /etc/snapserver.conf
sed -i  "/# raspotify pipe stream/a ${value}" /etc/snapserver.conf

echo 'restarting mopidy and snapcast services'
sudo systemctl restart raspotify.service
sudo systemctl restart snapserver.service
sudo systemctl restart snapclient.service
