#!/bin/bash
# TECNICO-MASTER v2.0 - Refatorado com seleção numérica e fullscreen

REPO_DIR="$HOME/Downloads/Conexao_Bahiasul_Scripts_Rede"

# Verificação e update Git
echo "🔄 Verificando atualizações..."
if [ -d "$REPO_DIR/.git" ]; then
    cd "$REPO_DIR" || { echo "❌ Erro: $REPO_DIR não encontrado"; exit 1; }
    git fetch origin main > /dev/null 2>&1
    if [ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ]; then
        echo "📥 Atualizando..."
        git pull origin main
        chmod +x *.sh 2>/dev/null
        echo "✅ Atualizado!"
        sleep 1
    else
        echo "✅ Já atualizado!"
    fi
    cd - > /dev/null
fi

# Função para mostrar menu
show_menu() {
    clear
    IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
    [ -z "$IFACE" ] && IFACE="N/A"
    
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║           🛠️  TÉCNICO REDE v2.0 - $IFACE            ║"
    echo "╠══════════════════════════════════════════════════════╣"
    echo "║  Digite o número da opção e pressione ENTER:         ║"
    echo "║                                                      ║"
    echo "║  1) 🧪 Teste PPPoE Bahiasul24                        ║"
    echo "║  2) 📡 Ubiquiti 192.168.1.20                         ║"
    echo "║  3) 📶 WiFi Scan (linssid)                           ║"
    echo "║  4) 🎛️  Winbox Mikrotik                             ║"
    echo "║  5) 📡 Ping 8.8.8.8 x3                               ║"
    echo "║  6) 🔄 Reset DHCP Auto                               ║"
    echo "║  0) 🚪 SAIR (fecha terminal)                         ║"
    echo "║                                                      ║"
    echo "╚══════════════════════════════════════════════════════╝"
    read -p "Opção: " CHOICE
}

# Loop principal
while true; do
    show_menu
    
    case $CHOICE in
        1)
            if [ -f "$REPO_DIR/pppoe-bahiasul.sh" ]; then
                cd "$REPO_DIR" && ./pppoe-bahiasul.sh
            else
                echo "❌ pppoe-bahiasul.sh não encontrado!"
                sleep 2
            fi
            ;;
        2)
            if [ -f "$REPO_DIR/ubiquiti-browser.sh" ]; then
                cd "$REPO_DIR" && ./ubiquiti-browser.sh
            else
                echo "❌ ubiquiti-browser.sh não encontrado!"
                sleep 2
            fi
            ;;
        3) pkexec linssid & ;;
        4) wine ~/Downloads/winbox64.exe & ;;
        5) ping -c 3 8.8.8.8 | tee ~/Desktop/ping-relatorio.txt ;;
        6)
            IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
            if [ -n "$IFACE" ]; then
                nmcli con mod "$IFACE" ipv4.method auto
                nmcli con up "$IFACE" 2>/dev/null
                echo "✅ DHCP resetado para $IFACE"
                sleep 2
            else
                echo "❌ Nenhuma interface ethernet encontrada"
                sleep 2
            fi
            ;;
        0)
            clear
            echo "👋 Até logo! Fechando terminal..."
            sleep 1
            exit 0
            ;;
        *)
            echo "❌ Opção inválida! Digite 0-6."
            sleep 2
            ;;
    esac
done
