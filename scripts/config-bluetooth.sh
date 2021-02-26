#!/bin/bash -e

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi


DEVICE_NAME="$1"

# Bluetooth settings
cp -n /etc/bluetooth/main.conf  /etc/bluetooth/main.conf.custom_bak
cat > /etc/bluetooth/main.conf << EOF
[General]
Name = ${DEVICE_NAME}
Class = 0x200414
DiscoverableTimeout = 0
[Policy]
AutoEnable=true
EOF

# add this user to the bluetooth group -> not necessary anymore, since whe can just run bluetoothctl with sudo
#sudo usermod -G bluetooth -a "$USER"
# Ensure that name get changed
BT_MAC=`sudo bluetoothctl list | grep '[default]' | grep -o  "..:..:..:..:..:.."`
if grep '^Name' /var/lib/bluetooth/$BT_MAC/settings; then
  sed -i "s/Name.*/Name = $DEVICE_NAME/" /var/lib/bluetooth/$BT_MAC/settings
else
  echo "Name = ${DEVICE_NAME}" >> /var/lib/bluetooth/$BT_MAC/settings
fi

# Make Bluetooth discoverable after initialisation
mkdir -p /etc/systemd/system/bthelper@.service.d
cat <<'EOF' > /etc/systemd/system/bthelper@.service.d/override.conf
[Service]
Type=oneshot
ExecStartPost=/usr/bin/bluetoothctl discoverable on
ExecStartPost=/bin/hciconfig %I piscan
ExecStartPost=/bin/hciconfig %I sspmode 1
EOF

cp -n /etc/systemd/system/bt-agent.service /etc/systemd/system/bt-agent.service.custom_bak 2>/dev/null
cat <<'EOF' > /etc/systemd/system/bt-agent.service
[Unit]
Description=Bluetooth Agent
Requires=bluetooth.service
After=bluetooth.service
[Service]
ExecStart=/usr/bin/bt-agent --capability=NoInputNoOutput
RestartSec=5
Restart=always
KillSignal=SIGUSR1
[Install]
WantedBy=multi-user.target
EOF
systemctl enable bt-agent.service

# ALSA settings
cp -n /lib/modprobe.d/aliases.conf /lib/modprobe.d/aliases.conf.custom_bak
sed -i.orig 's/^options snd-usb-audio index=-2$/#options snd-usb-audio index=-2/' /lib/modprobe.d/aliases.conf

# BlueALSA
mkdir -p /etc/systemd/system/bluealsa.service.d
cat <<'EOF' > /etc/systemd/system/bluealsa.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/bluealsa -i hci0 -p a2dp-sink
RestartSec=5
Restart=always
EOF

# append config: redirect BlueAlsa to pipe
if grep -q "# spotifypiHome config for bluealsa" /etc/alsa/conf.d/20-bluealsa.conf; then
    sed -i '/# spotifypiHome config for bluealsa/,/# end/d' /etc/alsa/conf.d/20-bluealsa.conf
fi
cat << 'EOF' >> /etc/alsa/conf.d/20-bluealsa.conf
# spotifypiHome config for bluealsa
pcm.fifo {
    type plug
    slave.pcm rate44100Hz
}
pcm.rate44100Hz {
    type rate
    slave {
        pcm writeFile # Direct to the plugin which will write to a file
        format S16_LE
        rate 44100
    }
}
pcm.writeFile {
    type file
    slave.pcm null
    file "/tmp/snapfifo_bluetooth"
    format "raw"
}
# end
EOF

cp -n /etc/systemd/system/bluealsa-aplay.service /etc/systemd/system/bluealsa-aplay.service.custom_bak 2>/dev/null
cat <<'EOF' > /etc/systemd/system/bluealsa-aplay.service
[Unit]
Description=BlueALSA aplay
Requires=bluealsa.service
After=bluealsa.service sound.target
[Service]
Type=simple
User=root
ExecStartPre=/bin/sleep 2
ExecStart=/usr/bin/bluealsa-aplay -d fifo --pcm-buffer-time=250000 00:00:00:00:00:00
RestartSec=5
Restart=always
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable bluealsa-aplay

# Bluetooth udev script
cat <<'EOF' > /usr/local/bin/bluetooth-udev
#!/bin/bash
if [[ ! $NAME =~ ^\"([0-9A-F]{2}[:-]){5}([0-9A-F]{2})\"$ ]]; then exit 0; fi

action=$(expr "$ACTION" : "\([a-zA-Z]\+\).*")

if [ "$action" = "add" ]; then
    bluetoothctl discoverable off
    # play connect sound
    aplay -q /usr/local/share/sounds/bluetooth/device-connected.wav
fi

if [ "$action" = "remove" ]; then
    # play disconnect sound
    aplay -q /usr/local/share/sounds/bluetooth/device-disconnected.wav
    bluetoothctl discoverable on
fi
EOF
chmod 755 /usr/local/bin/bluetooth-udev

cat <<'EOF' > /etc/udev/rules.d/99-bluetooth-udev.rules
SUBSYSTEM=="input", GROUP="input", MODE="0660"
KERNEL=="input[0-9]*", RUN+="/usr/local/bin/bluetooth-udev"
EOF
