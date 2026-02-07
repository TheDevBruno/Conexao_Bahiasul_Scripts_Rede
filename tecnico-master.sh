#!/bin/bash
# TECNICO-MASTER v1.3 - CORRIGIDO + LiteBeam AC (ORDEM ESPECÍFICA)

# 1. REPO_DIR PRIMEIRO (CORREÇÃO CRÍTICA)
REPO_DIR="$HOME/Downloads/Conexao_Bahiasul_Scripts_Rede"

# 2. AUTO-UPDATE GIT
echo "🔄 Verificando atualizações do serviço..."
if [ -d "$REPO_DIR/.git" ]; then
    cd "$REPO_DIR"
    git fetch origin main > /dev/null 2>&1
    if [ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ]; then
        echo "📥 Atualizando do GitHub..."
        git pull origin main
        chmod +x *.sh
        echo "✅ Repositório atualizado!"
        sleep 1
    else
        echo "✅ Já está atualizado!"
    fi
    cd - > /dev/null
else
    echo "⚠️  $REPO_DIR não encontrado!"
fi

clear

while true; do
  IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
  [ -z "$IFACE" ] && IFACE="N/A"
  
  CHOICE=$(whiptail --title "Técnico Rede v1.3 - $IFACE" --menu "Escolha:" 18 60 7 \
    "1" "Teste de usuario PPPoE Bahiasul24" \
    "2" "Configuração da Antena Ubiquiti 192.168.1.20" \
    "3" "Atualizar LiteBeam AC (v8.7.19 SSH AUTO)" \
    "4" "Analizar canais da rede WiFi Scan" \
    "5" "Acessar Winbox Mikrotik" \
    "6" "Teste de Ping 8.8.8.8" \
    "7" "Resetar DHCP Reset" \
    "0" "Sair" 3>&1 1>&2 2>&3)

  [ $? != 0 ] && break
  
  case $CHOICE in
    1) 
      if [ -f "$REPO_DIR/pppoe-bahiasul.sh" ]; then
        cd "$REPO_DIR" && ./pppoe-bahiasul.sh
      else
        whiptail --msgbox "❌ pppoe-bahiasul.sh não encontrado!" 10 50
      fi
      ;;
    2) 
      if [ -f "$REPO_DIR/ubiquiti-browser.sh" ]; then
        cd "$REPO_DIR" && ./ubiquiti-browser.sh
      else
        whiptail --msgbox "❌ ubiquiti-browser.sh não encontrado!" 10 50
      fi
      ;;
    # OPÇÃO 3 - LITEBEAM AC (NOVA)
    3) 
      if [ -f "$HOME/update-litebeam-ac.sh" ]; then
        clear
        echo "🔄 Executando LiteBeam AC v8.7.19 SSH AUTO..."
        bash "$HOME/update-litebeam-ac.sh"
      else
        whiptail --msgbox "❌ update-litebeam-ac.sh não encontrado em ~/\nCrie primeiro!" 12 60
      fi
      ;;
    4) pkexec linssid & ;;
    5) 
      if [ -f "$HOME/Downloads/winbox64.exe" ]; then
        wine ~/Downloads/winbox64.exe &
      else
        whiptail --msgbox "❌ winbox64.exe não encontrado!" 10 50
      fi
      ;;
    6) ping -c 5 8.8.8.8 | tee ~/Desktop/ping-relatorio.txt ;;
    7) 
      IFACE_RESET=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
      if [ -n "$IFACE_RESET" ]; then
        nmcli con mod "$IFACE_RESET" ipv4.method auto
        nmcli con up "$IFACE_RESET" 2>/dev/null
        whiptail --msgbox "✅ DHCP resetado: $IFACE_RESET" 10 50
      else
        whiptail --msgbox "❌ Interface ethernet não encontrada!" 10 50
      fi
      ;;
    0) break ;;
  esac
  
  read -p "Pressione Enter para continuar..."
done

