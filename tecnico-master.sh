#!/bin/bash
REPO_DIR="$HOME/Downloads/Conexao_Bahiasul_Scripts_Rede"
clear
while true; do
  IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
  CHOICE=$(whiptail --title "Técnico Rede v1.0 - $IFACE" --menu "Escolha:" 18 60 7 \
    "1" "PPPoE Bahiasul24" \
    "2" "Ubiquiti 192.168.1.20" \
    "3" "WiFi Scan" \
    "4" "Winbox" \
    "5" "Relatório" \
    "6" "DHCP Reset" \
    "0" "Sair" 3>&1 1>&2 2>&3)
  
  [ $? != 0 ] && break
  case $CHOICE in
    1) sudo apt install speedtest-cli -y; cd "$REPO_DIR" && ./pppoe-bahiasul.sh ;;
    2) cd "$REPO_DIR" && ./ubiquiti-browser.sh ;;
    3) sudo apt install linssid -y && pkexec linssid & ;;
    4) wine ~/Downloads/winbox64.exe & ;;
    5) ping -c 3 8.8.8.8 | tee ~/Desktop/relatorio.txt ;;
    6) nmcli dev | grep ethernet | head -1 | awk '{print $1}' | xargs -I {} nmcli con mod {} ipv4.method auto ;;
    0) break ;;
  esac
  read -p "Enter..."
done
