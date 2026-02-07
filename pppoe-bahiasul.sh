#!/bin/bash
# PPPoE BAHIASUL24 - TESTE VELOCIDADE

# Detecta interface
IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
MAIN_NET=$(nmcli con show | grep -v pppoe | grep -i ethernet | head -1 | awk '{print $1}')

clear
echo "======================================="
echo "🌐 PPPoE BAHIASUL24 - TESTE VELOCIDADE"
echo "Notebook Técnico - Linux Mint"
echo "Interface: $IFACE"
echo "======================================="

# 1. RECRIA CONEXAO PPPoE
echo "🔄 Recriando conexão PPPoE..."
nmcli con del pppoe-bahiasul 2>/dev/null
nmcli con add type pppoe ifname "$IFACE" con-name pppoe-bahiasul username bahiasul24 password bahiasul24

# 2. ATIVANDO E VALIDANDO
echo "📡 Conectando PPPoE..."
nmcli con up pppoe-bahiasul && sleep 5

if [ $? -ne 0 ]; then
    echo "❌ Falha ao conectar PPPoE!"
    read -p "Pressione Enter para sair..."
    exit 1
fi

echo "✅ PPPoE conectado com sucesso!"
nmcli con show pppoe-bahiasul | grep GENERAL
sleep 10

# 3. DESATIVANDO CONEXAO PRINCIPAL
echo "🔌 Desativando conexão principal..."
[ -n "$MAIN_NET" ] && nmcli con down "$MAIN_NET" 2>/dev/null
sleep 10

# 4. TESTE DE PING (120x)
echo "======================================="
echo "🏓 Teste PING backup DNS (120 tentativas)"
ping -c 120 8.8.8.8

# 5. SPEEDTEST - TESTE DE VELOCIDADE
echo "======================================="
if command -v speedtest-cli >/dev/null; then
    echo "⚡ Executando Speedtest CLI..."
    speedtest-cli --simple
elif command -v speedtest >/dev/null; then
    echo "⚡ Executando Speedtest Oficial..."
    speedtest --simple
else
    echo "❌ Nenhum speedtest encontrado!"
    echo "sudo apt install speedtest-cli"
fi

# 6. RECONECTA REDE PRINCIPAL
echo "🔄 Reativando conexão principal..."
[ -n "$MAIN_NET" ] && nmcli con up "$MAIN_NET" 2>/dev/null || true
sleep 3

echo "======================================="
echo "✅ TESTE CONCLUÍDO!"
echo "======================================="
read -n 1 -p "Pressione Enter para sair..."

