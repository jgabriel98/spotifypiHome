#!/bin/bash -e

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

bash config-bluetooth.sh "$1"
exit 0
cp pihome-stream-fifo-to-server /usr/local/bin/pihome-stream-fifo-to-server

cat << 'EOF' > /etc/systemd/system/pihome-client-bt.service
[Unit]
Description=snapcast client bluetooth feedback
After=bluealsa-aplay.service snapclient.service
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=5
User=root
ExecStart=/bin/bash /usr/local/bin/pihome-stream-fifo-to-server "/tmp/snapfifo_bluetooth"

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload

# Bluetooth udev script
cat <<'EOF' > /usr/local/bin/bluetooth-udev
#!/bin/bash
if [[ ! $NAME =~ ^\"([0-9A-F]{2}[:-]){5}([0-9A-F]{2})\"$ ]]; then exit 0; fi

action=$(expr "$ACTION" : "\([a-zA-Z]\+\).*")

if [ "$action" = "add" ]; then
    bluetoothctl discoverable off
    # play connect sound
    aplay -q /usr/local/share/sounds/bluetooth/device-connected.wav
    systemctl start pihome-client-bt.service
fi

if [ "$action" = "remove" ]; then
    # play disconnect sound
    aplay -q /usr/local/share/sounds/bluetooth/device-disconnected.wav
    bluetoothctl discoverable on
    systemctl stop pihome-client-bt.service
fi
EOF
chmod 755 /usr/local/bin/bluetooth-udev

