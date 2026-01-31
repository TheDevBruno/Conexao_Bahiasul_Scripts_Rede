cat > ~/Downloads/Conexao_Bahiasul_Scripts_Rede/ubiquiti-browser.sh << 'EOF'
#!/bin/bash
echo "📡 Ubiquiti 192.168.1.20 - Configuração Visual..."

# 1. Detecta interface
IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
echo "Interface: $IFACE"

# 2. Remove conexão antiga (se existir)
nmcli con del ubnt-temp 2>/dev/null
nmcli con del "$IFACE" 2>/dev/null

# 3. CRIA conexão MANUAL 192.168.1.10/24
nmcli con add type ethernet ifname "$IFACE" con-name "ubnt-temp" \
  ipv4.method manual ipv4.addresses 192.168.1.10/24 ipv4.gateway 192.168.1.1

# 4. MOSTRA configuração para técnico VER
echo ""
echo "🔧 Configuração aplicada:"
nmcli con show ubnt-temp
ip addr show "$IFACE" | grep inet
echo ""
echo "⏳ Aguardando ativação (3s)..."
nmcli con up ubnt-temp && sleep 3 || { echo "❌ Erro ativação!"; exit 1; }

# 5. Testa antena + feedback visual
echo "🧪 Testando ping 192.168.1.20..."
if ping -c 2 192.168.1.20 >/dev/null 2>&1; then
  echo "✅ ANTENA ONLINE!"
  echo "🌐 Abrindo Firefox 192.168.1.20 (ubnt/ubnt)"
  firefox http://192.168.1.20 &
else
  echo "❌ ANTENA OFFLINE!"
  echo "   - Cabo conectado?"
   echo "   - Antena ligada?"
fi

# 6. Aguarda técnico (NÃO auto-reset)
read -p "✅ Configure antena → Pressione Enter quando terminar..."

# 7. Reset DHCP
echo "🔄 Restaurando DHCP..."
nmcli con del ubnt-temp
nmcli dev disconnect "$IFACE" 2>/dev/null
sleep 2
nmcli dev connect "$IFACE"
echo "✅ DHCP ativo!"
EOF

chmod +x ~/Downloads/Conexao_Bahiasul_Scripts_Rede/ubiquiti-browser.sh
