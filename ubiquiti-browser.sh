#!/bin/bash
# Ubiquiti Browser - PING INICIAL + IP MANTIDO (sem sudo)

clear
echo "📡 Ubiquiti 192.168.1.20 - Verificação inicial..."
echo "========================================"

# 1. Detecta interface ethernet
IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
echo "Interface: $IFACE"

# 🔥 PING INICIAL (ANTES da configuração)
echo ""
echo "🏓 Teste INICIAL 192.168.1.20 (rede atual)..."
if ping -c 3 192.168.1.20 >/dev/null 2>&1; then
    echo "✅ UBIQUITI ATIVO na rede atual!"
else
    echo "⚠️  UBIQUITI OFFLINE ou rede diferente"
fi
echo ""

# 2. Limpa conexões antigas (comentado para segurança)
# nmcli con del ubnt-temp 2>/dev/null
# nmcli con del "$IFACE" 2>/dev/null

# 3. Cria conexão MANUAL 192.168.1.10/24
echo "🔧 Configurando IP 192.168.1.10..."
nmcli con add type ethernet ifname "$IFACE" con-name "ubnt-temp" \\
  ipv4.method manual ipv4.addresses 192.168.1.10/24 ipv4.gateway 192.168.1.1

# 4. Ativa + mostra IP
echo ""
echo "🔧 IP 192.168.1.10 aplicado na placa de rede:"
nmcli con up ubnt-temp && sleep 3 || { echo "❌ Erro rede!"; exit 1; }
ip addr show "$IFACE" | grep inet

# 5. PING FINAL (DEPOIS da configuração)
echo ""
echo "🏓 Teste FINAL 192.168.1.20 (com IP 192.168.1.10)..."
if ping -c 3 192.168.1.20 >/dev/null 2>&1; then
    echo "✅ ANTENA ONLINE!"

    # 6. Chrome SEM SSL warnings
    echo "🌐 Chrome → 192.168.1.20 (ubnt/ubnt)"
    echo "💡 IP FIXO 192.168.1.10 na placa de rede até reset DHCP"
    echo ""
    google-chrome-stable \\
      --no-sandbox \\
      --disable-web-security \\
      --ignore-certificate-errors \\
      --disable-cert-error-top-level-navigation \\
      http://192.168.1.20 &

    echo ""
    echo "✅ Chrome aberto! Configure a antena."
    echo "⚠️  IP 192.168.1.10 FICA ATIVO (reset no menu principal)"
    echo ""
    read -p "Pressione ENTER para voltar ao menu..."

else
    echo "❌ ANTENA OFFLINE após configuração!"
    echo "  - Resete a antena"
    echo "  - Cabo e Fonte OK?"
    echo "  - Antena ligada?"
    read -p "Pressione ENTER para continuar e teste novamente..."
    exit 1
fi

echo ""
echo "✅ ubiquiti-browser.sh concluído!"
echo "🌐 IP NA PLACA MANTIDO ATIVO"
echo "🔙 Volte ao ./tecnico-master.sh para reset DHCP"

