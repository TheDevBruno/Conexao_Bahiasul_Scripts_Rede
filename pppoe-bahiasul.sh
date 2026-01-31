#!/bin/bash
IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
echo "🌐 PPPoE Bahiasul24 - $(date)"
nmcli con del pppoe-bahiasul 2>/dev/null
nmcli con add type pppoe ifname "$IFACE" con-name pppoe-bahiasul username bahiasul24 password bahiasul24
nmcli con up pppoe-bahiasul && sleep 5
nmcli con show pppoe-bahiasul | grep GENERAL
ping -c 3 8.8.8.8
speedtest-cli --simple
