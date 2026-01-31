cat > ~/Downloads/Conexao_Bahiasul_Scripts_Rede/ubiquiti-browser.sh << 'EOF'
#!/bin/bash
# Ubiquiti Browser - Chrome + IP MANTIDO (sem sudo + sem reset DHCP)

clear
echo "📡 Ubiquiti 192.168.1.20 - Configuração..."
echo "========================================"

# 1. Detecta interface ethernet
IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
echo "Interface: $IFACE"

# 2. Limpa conexões antigas
nmcli con del ubnt-temp 2>/dev/null
nmcli con del "$IFACE" 2>/dev/null

# 3. Cria conexão MANUAL 192.168.1.10/24
nmcli con add type ethernet ifname "$IFACE" con-name "ubnt-temp" \
  ipv4.method manual ipv4.addresses 192.168.1.10/24 ipv4.gateway 192.168.1.1

# 4. Ativa + mostra IP (feedback técnico)
echo ""
echo "🔧 IP 192.168.1.10 aplicado:"
nmcli con up ubnt-temp && sleep 3 || { echo "❌ Erro rede!"; exit 1; }
ip addr show "$IFACE" | grep inet

# 5. Testa antena
echo ""
if ping -c 2 192.168.1.20 >/dev/null 2>&1; then
  echo "✅ ANTENA ONLINE!"
  
  # 6. Fix Chrome sandbox SEM SUDO (timeout rápido)
  timeout 2 sudo chown root:root /opt/google/chrome/chrome-sandbox 2>/dev/null || true
  timeout 2 sudo chmod 4755 /opt/google/chrome/chrome-sandbox 2>/dev/null || true
  
  # 7. Chrome SEM SSL warnings
  echo "🌐 Chrome → 192.168.1.20 (ubnt/ubnt)"
  echo "💡 IP 192.168.1.10 MANTIDO até reset manual"
  echo ""
  google-chrome-stable \
    --no-sandbox \
    --disable-web-security \
    --ignore-certificate-errors \
    --disable-cert-error-top-level-navigation \
    http://192.168.1.20 &
    
  echo ""
  echo "✅ Chrome aberto! Configure a antena."
  echo "⚠️  IP 192.168.1.10 FICA ATIVO (reset no menu principal)"
  echo ""
  read -p "Pressione ENTER para voltar ao menu..."
  
else
  echo "❌ ANTENA OFFLINE!"
  echo "  - Cabo OK?"
  echo "  - Antena ligada?"
  read -p "Pressione ENTER para continuar..."
  exit 1
fi

echo ""
echo "✅ ubiquiti-browser.sh concluído!"
echo "🌐 IP 192.168.1.10 MANTIDO ATIVO"
echo "🔙 Volte ao ./tecnico-master.sh para reset DHCP"
EOF

chmod +x ~/Downloads/Conexao_Bahiasul_Scripts_Rede/ubiquiti-browser.sh
