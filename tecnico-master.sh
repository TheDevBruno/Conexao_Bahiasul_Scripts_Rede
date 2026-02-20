#!/bin/bash
# TECNICO-MASTER v2.1 - Fullscreen + Seleção Numérica

REPO_DIR="$HOME/Downloads/Conexao_Bahiasul_Scripts_Rede"

# MAXIMIZAR TELA AUTOMATICAMENTE (Linux Mint)
tput smkx          # Modo teclado normal
clear
resize -s 40 120   # Força tamanho grande
wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz 2>/dev/null || true

# Verificação e update Git
echo "🔄 Verificando atualizações..."
if [ -d "$REPO_DIR/.git" ]; then
    cd "$REPO_DIR" || { echo "❌ Erro: $REPO_DIR não encontrado"; sleep 2; return_menu; }
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

# Função Menu
return_menu() { read -p $'\nPressione ENTER para voltar ao menu...'; }

show_menu() {
    clear
    tput cup 0 0       # Cursor canto superior
    IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
    [ -z "$IFACE" ] && IFACE="N/A"
    
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║           🛠️  TÉCNICO REDE v2.1 - $IFACE            ║"
    echo "╠══════════════════════════════════════════════════════╣"
    echo "║  Digite o NÚMERO da opção e pressione ENTER:         ║"
    echo "║                                                      ║"
    echo "║  1) 🧪 Teste PPPoE Bahiasul24                        ║"
    echo "║  2) 📡 Configurar Antena Ubiquiti 192.168.1.20       ║"
    echo "║  3) 📶 Analisar Canais rede WiFi Scan (linssid)      ║"
    echo "║  4) 🎛️  Abrir Winbox Mikrotik                        ║"
    echo "║  5) 📡 Fazer teste de Ping 8.8.8.8 x3                 ║"
    echo "║  6) 🔄 Resetar IP DHCP Auto                           ║"
    echo "║  0) 🚪 SAIR (FECHA TERMINAL COMPLETO)                 ║"
    echo "║                                                      ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo ""
    read -p "👉 Opção: " CHOICE
}

# Loop Principal - FULLSCREEN MANTIDO
while true; do
    show_menu
    
    case $CHOICE in
        1)
            if [ -f "$REPO_DIR/pppoe-bahiasul.sh" ]; then
                cd "$REPO_DIR" && ./pppoe-bahiasul.sh
            else
                echo "❌ pppoe-bahiasul.sh não encontrado em $REPO_DIR"
                sleep 3
            fi
            return_menu
            ;;
        2)
            if [ -f "$REPO_DIR/ubiquiti-browser.sh" ]; then
                cd "$REPO_DIR" && ./ubiquiti-browser.sh
            else
                echo "❌ ubiquiti-browser.sh não encontrado!"
                sleep 3
            fi
            return_menu
            ;;
        3) 
            pkexec linssid & 
            return_menu
            ;;
        4) 
            wine ~/Downloads/winbox64.exe & 
            return_menu
            ;;
        5) 
            echo "📊 Teste de Ping 8.8.8.8 (salvo em ~/Desktop/ping-relatorio.txt)"
            ping -c 3 8.8.8.8 | tee ~/Desktop/ping-relatorio.txt
            return_menu
            ;;
        6)
            IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
            if [ -n "$IFACE" ]; then
                echo "🔄 Resetando DHCP para $IFACE..."
                nmcli con mod "$IFACE" ipv4.method auto 2>/dev/null
                nmcli con up "$IFACE" 2>/dev/null
                echo "✅ DHCP AUTO ativado!"
                sleep 2
            else
                echo "❌ Nenhuma interface ethernet encontrada"
                sleep 2
            fi
            return_menu
            ;;
        0)
            clear
            tput cup 5 20
            echo "🌟 OBRIGADO Técnico Bahiasul!"
            echo "👋 Até a próxima visita!"
            sleep 2
            exit 0
            ;;
        *)
            echo "❌ Opção inválida! Use 0,1,2,3,4,5 ou 6"
            sleep 2
            ;;
    esac
done
