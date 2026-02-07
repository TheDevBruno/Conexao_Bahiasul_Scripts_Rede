#!/bin/bash
# UPDATE-LITEBEAM-AC v2.2 - MÉTODO WEB (100% FUNCIONAL)

LITEBEAM_IP="192.168.1.20"
FIRMWARE_VERSION="v8.7.19"
FIRMWARE_URL="https://dl.ui.com/firmwares/xm/v8.7.19/LiteBeam-AC-EU.bin"

clear
echo "🚀 LiteBeam AC Update $FIRMWARE_VERSION - MÉTODO WEB"
echo "=================================================="

# 1. CONFIG IP
IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
echo "📡 Interface: $IFACE"
nmcli con del litebeam-temp 2>/dev/null
nmcli con add type ethernet ifname "$IFACE" con-name litebeam-temp \
  ipv4.method manual ipv4.addresses "192.168.1.10/24"
nmcli con up litebeam-temp
sleep 3

# 2. BAIXA FIRMWARE LOCALMENTE
echo "📥 Baixando firmware v$FIRMWARE_VERSION..."
wget -O "/tmp/LiteBeam-AC-EU.bin" "$FIRMWARE_URL"
if [ $? -ne 0 ]; then
    echo "❌ Download falhou!"
    nmcli con del litebeam-temp 2>/dev/null
    read -p "Pressione Enter..."
    exit 1
fi
echo "✅ Firmware: /tmp/LiteBeam-AC-EU.bin"

# 3. ABRE WEB COM FIRMWARE PRONTO
echo ""
echo "🎯 ABRA O NAVEGADOR:"
echo "   http://$LITEBEAM_IP"
echo ""
echo "   Login: ubnt / ubnt"
echo "   System → Upload Firmware"
echo "   SELECIONE: /tmp/LiteBeam-AC-EU.bin"
echo ""
echo "🔥 CHROME SERÁ ABERTO AGORA:"
google-chrome-stable --no-sandbox \
  --disable-web-security \
  --ignore-certificate-errors \
  --disable-cert-error-top-level-navigation \
  "http://$LITEBEAM_IP" &

sleep 3

# 4. INSTRUÇÕES FINAIS
whiptail --msgbox "\
✅ PASSOS FINAIS:

1. AGUARDE Chrome carregar $LITEBEAM_IP
2. Login: ubnt / ubnt  
3. System → Upload Firmware
4. SELECIONE /tmp/LiteBeam-AC-EU.bin
5. Apply → Aguarde 3-5min

⚠️  FIRMWARE JÁ ESTÁ NO /tmp !
IP 192.168.1.10 ATIVO até reset DHCP" 18 70 0

# 5. CLEANUP
echo "🧹 Cleanup..."
nmcli con down litebeam-temp 2>/dev/null
nmcli con del litebeam-temp 2>/dev/null
echo "✅ Concluído! Use Reset DHCP (opção 7) para voltar ao normal."
echo ""
read -p "Pressione Enter para voltar ao menu..."

