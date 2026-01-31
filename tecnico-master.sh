#!/bin/bash
# tecnico-master.sh - V4 Sintaxe Fix (TheDevBruno 2026)
REPO_DIR="$HOME/Downloads/Conexao_Bahiasul_Scripts_Rede"

# Cores
RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' NC='\033[0m'

# Cria pasta/repo
mkdir -p "$REPO_DIR"
cd "$REPO_DIR" || exit 1

# AUTO-CRIA scripts (só se não existirem)
[ ! -f pppoe-bahiasul.sh ] && cat > pppoe-bahiasul.sh << 'EOF'
#!/bin/bash
IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
nmcli con del pppoe-bahiasul 2>/dev/null
nmcli con add type pppoe ifname "$IFACE" con-name pppoe-bahiasul \
  username bahiasul24 password bahiasul24
nmcli con up pppoe-bahiasul
sleep 5
echo "=== PPPoE $(date) ==="
nmcli con show pppoe-bahiasul | grep GENERAL
ping -c 3 8.8.8.8
speedtest-cli --simple
EOF

[ ! -f ubiquiti-browser.sh ] && cat > ubiquiti-browser.sh << 'EOF'
#!/bin/bash
IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
nmcli con mod "$IFACE" ipv4.method manual ipv4.addresses 192.168.1.10/24
nmcli con up "$IFACE"
sleep 2
ping -c 2 192.168.1.20 && firefox http://192.168.1.20 || echo "Antena offline!"
EOF

chmod +x *.sh 2>/dev/null

# Reset DHCP
reset_dhcp() {
  IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
  [ -n "$IFACE" ] && nmcli con mod "$IFACE" ipv4.method auto && nmcli con up "$IFACE"
  echo -e "${GREEN}DHCP restaurado!${NC}"
}

# Menu principal
clear
while true; do
  IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
  CHOICE=$(whiptail --title "Técnico Rede V4 - $IFACE" \
    --menu "Scripts AUTO-CRIADOS!" 20 70 7 \
    "1" "PPPoE Bahiasul24 + Speedtest" \
    "2" "Ubiquiti 192.168.1.20" \
    "3" "WiFi Scan LinSSID" \
    "4" "Winbox Mikrotik" \
    "5" "Ping + Relatório" \
    "6" "Reset DHCP" \
    "0" "Sair" 3>&1 1>&2 2>&3)

  [ $? != 0 ] && reset_dhcp && exit 0

  case $CHOICE in
    1)
      sudo apt install speedtest-cli -y 2>/dev/null
      ./pppoe-bahiasul.sh
      read -p "Enter para continuar..."
      ;;
    2)
      ./ubiquiti-browser.sh
      read -p "Enter para continuar..."
      ;;
    3)
      sudo apt install linssid -y 2>/dev/null
      pkexec linssid &
      read -p "Enter para continuar..."
      ;;
    4)
      [ -f ~/Downloads/winbox64.exe ] && wine ~/Downloads/winbox64.exe & \
        || zenity --error --text="Winbox não encontrado!"
      read -p "Enter para continuar..."
      ;;
    5)
      echo "=== $(date) ===" > ~/Desktop/relatorio.txt
      ping -c 3 8.8.8.8 >> ~/Desktop/relatorio.txt
      speedtest-cli --simple >> ~/Desktop/relatorio.txt 2>/dev/null
      xdg-open ~/Desktop/relatorio.txt
      read -p "Enter para continuar..."
      ;;
    6)
      reset_dhcp
      read -p "Enter para continuar..."
      ;;
    0)
      reset_dhcp
      exit 0
      ;;
  esac
done
