#!/bin/bash
IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
echo "📡 Ubiquiti 192.168.1.20"
nmcli con mod "$IFACE" ipv4.method manual ipv4.addresses 192.168.1.10/24
nmcli con up "$IFACE" && sleep 2
if ping -c 2 192.168.1.20; then
  firefox http://192.168.1.20 &
else
  echo "❌ Antena offline!"
fi
