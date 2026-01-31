#!/bin/bash
# tecnico-master.sh - Menu Técnico Completo (TheDevBruno 2026)
REPO_DIR="$HOME/Downloads/Conexao_Bahiasul_Scripts_Rede"
UPDATE_URL="https://github.com/TheDevBruno/Conexao_Bahiasul_Scripts_Rede.git"

# 1. Git Update Auto
function update_repo() {
  if [ -d "$REPO_DIR" ]; then
    cd "$REPO_DIR" || return
    echo "🔄 Atualizando GitHub..."
    git stash --include-untracked 2>/dev/null
    git pull origin main || git reset --hard origin/main
    chmod +x *.sh
    echo "✅ Repo atualizado!"
  else
    git clone "$UPDATE_URL" "$REPO_DIR"
    cd "$REPO_DIR"
  fi
}

# 2. Reset DHCP (fim testes)
function reset_dhcp() {
  for iface in $(nmcli dev | grep ethernet | awk '{print $1}'); do
    nmcli con mod "$iface" ipv4.method auto
    nmcli con down "$iface" 2>/dev/null
    nmcli con up "$iface"
  done
  echo "🔄 DHCP restaurado!"
}

# 3. Menu Principal
update_repo
clear
while true; do
  CHOICE=$(whiptail --title "Técnico Rede - Conexão Bahia Sul" --menu "Escolha teste:" 18 60 8 \
    "1" "PPPoE Bahiasul24 + Speedtest" \
    "2" "Ubiquiti Antena 192.168.1.20" \
    "3" "WiFi Scan + Canais (LinSSID)" \
    "4" "Winbox Mikrotik" \
    "5" "Ping Completo + Relatório" \
    "6" "Config Teclado ABNT2" \
    "7" "Reset Total DHCP" \
    "0" "Sair" 3>&1 1>&2 2>&3)
  
  exitstatus=$?
  if [ $exitstatus = 1 ]; then break; fi

  case $CHOICE in
    1) cd "$REPO_DIR" && ./pppoe-bahiasul.sh ;;
    2) cd "$REPO_DIR" && ./ubiquiti-browser.sh ;;
    3) sudo apt install linssid -y && linssid & ;;
    4) wine ~/Downloads/winbox64.exe & ;;
    5) cd "$REPO_DIR" && ./relatorio-tecnico.sh ;;
    6) cd "$REPO_DIR" && ./fix-keycode105.sh ;;
    7) reset_dhcp ;;
    0) reset_dhcp && exit 0 ;;
  esac
  
  whiptail --msgbox "Teste concluído! DHCP resetado." 8 40
done
